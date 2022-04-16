// Copyright (c) 2022 Bob
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import Foundation
import NIOCore
import NIOPosix
import TSCBasic

struct DumpOptions {
    let suffix: String
    let size: Int
    let line: Int
    let max: Int?
    let output: AbsolutePath
    let verbose: Bool
    let dateFormatter = DateFormatter()

    public init(suffix: String, size: Int, line: Int, max: Int?, output: AbsolutePath, verbose: Bool) {
        self.suffix = suffix
        self.size = size
        self.line = line
        self.max = max
        self.output = output
        self.verbose = verbose
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
    }

    func file() -> AbsolutePath {
        let current = dateFormatter.string(from: Date())
        return output.appending(component: current.appending(suffix))
    }
}

final class State {
    var size: Int
    var line: Int
    let futureFileHandle: EventLoopFuture<NIOFileHandle>
    let path: String
    var fileHandle: NIOFileHandle?
    var writeFuture: EventLoopFuture<Void>?

    public init(size: Int, line: Int, futureFileHandle: EventLoopFuture<NIOFileHandle>, path: String, fileHandle: NIOFileHandle? = nil, writeFuture: EventLoopFuture<Void>? = nil) {
        self.size = size
        self.line = line
        self.futureFileHandle = futureFileHandle
        self.path = path
        self.fileHandle = fileHandle
        self.writeFuture = writeFuture
    }

    func close(context: ChannelHandlerContext) -> EventLoopFuture<Void> {
        return futureFileHandle.flatMap { _ in
            /// close file
            let future: EventLoopFuture<Void> = self.writeFuture!.flatMap {
                try? self.fileHandle?.close()
                return context.eventLoop.makeSucceededVoidFuture()
            }

            return future
        }
    }
}

final class DumpHandler: ChannelInboundHandler {
    public typealias InboundIn = ByteBuffer
    public typealias OutboundOut = ByteBuffer

    let fileIO: NonBlockingFileIO
    let options: DumpOptions
    var state: State?
    var files: [AbsolutePath] = []
    var closingState = [String: State]()

    public init(fileIO: NonBlockingFileIO, options: DumpOptions) {
        self.fileIO = fileIO
        self.options = options
    }

    func newState(context: ChannelHandlerContext) -> State {
        let path = options.file()
        let futureFileHandle = fileIO.openFile(
            path: path.pathString,
            mode: .write,
            flags: .allowFileCreation(),
            eventLoop: context.eventLoop
        )
        if let max = options.max, max > 0 {
            if files.count >= max {
                let first = files.removeFirst()
                try? localFileSystem.removeFileTree(first)
            }
            files.append(path)
        }

        return State(size: 0, line: 0, futureFileHandle: futureFileHandle, path: path.pathString, fileHandle: nil, writeFuture: nil)
    }

    func nextState(context: ChannelHandlerContext) -> State {
        if let state = state {
            if state.line < options.line,
               state.size < options.size {
                return state
            }

            closingState[state.path] = state

            state.close(context: context).whenComplete { [self] _ in
                self.closingState.removeValue(forKey: state.path)
            }
        }

        return newState(context: context)
    }

    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let state = nextState(context: context)
        let buffer = unwrapInboundIn(data)
        state.size += buffer.readableBytes
        if buffer.readableBytesView.firstIndex(of: UInt8(ascii: "\n")) != nil {
            state.line += 1
        }
        self.state = state
        state.futureFileHandle.whenSuccess { handle in
            state.fileHandle = handle
            state.writeFuture = self.fileIO.write(
                fileHandle: handle,
                buffer: buffer,
                eventLoop: context.eventLoop
            )
        }
        if options.verbose {
            context.channel.writeAndFlush(wrapOutboundOut(buffer), promise: nil)
        }
    }

    public func channelActive(context _: ChannelHandlerContext) {
        if options.output.isFile() {
            try! localFileSystem.removeFileTree(options.output)
        }
        if !options.output.exist() {
            try! localFileSystem.createDirectory(options.output, recursive: true)
        }
    }

    public func channelInactive(context: ChannelHandlerContext) {
        _ = state?.close(context: context)
    }
}
