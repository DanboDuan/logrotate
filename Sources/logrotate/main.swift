// Copyright (c) 2022 Bob
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import ArgumentParser
import NIOPosix
import ObjcSource
import TSCBasic

struct Main: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "logrotate",
        abstract: "log rotate tool for macOS base on NIO",
        version: Version.currentVersion()
    )

    @OptionGroup()
    var options: Options

    func run() throws {
        let options = options.toDumpOptions()
        if options.verbose {
            print("logroate directory:", options.output.pathString)
        }
        let threadPool = NIOThreadPool(numberOfThreads: 2)
        let fileIO = NonBlockingFileIO(threadPool: threadPool)
        threadPool.start()
        let handler = DumpHandler(
            fileIO: fileIO,
            options: options
        )
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 2)
        let bootstrap = NIOPipeBootstrap(group: group).channelInitializer { channel in
            channel.pipeline.addHandlers([
                handler,
            ])
        }
        let channel = try bootstrap.withPipes(inputDescriptor: STDIN_FILENO, outputDescriptor: STDOUT_FILENO).wait()
        try channel.closeFuture.wait()
        try group.syncShutdownGracefully()
    }
}

Main.main()
