// Copyright (c) 2022 Bob
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import ArgumentParser
import Foundation
import TSCBasic

public extension AbsolutePath {
    func fileOwner() throws -> String {
        let attributes = try FileManager.default.attributesOfItem(atPath: pathString)
        return attributes[.ownerAccountName] as! String
    }

    /// need root privilege to change file owner
    func changeFileOwner(to name: String) throws {
        try FileManager.default.setAttributes([.ownerAccountName: name], ofItemAtPath: pathString)
    }

    func exist() -> Bool {
        return FileManager.default.fileExists(atPath: pathString)
    }

    func isFile() -> Bool {
        return localFileSystem.isFile(self)
    }

    func isDirectory() -> Bool {
        return localFileSystem.isDirectory(self)
    }

    func size() -> UInt64 {
        return try! localFileSystem.getFileInfo(self).size
    }

    init(expandingTilde path: String) {
        if path.first == "~" {
            self.init(localFileSystem.homeDirectory, String(path.dropFirst(2)))
        } else {
            self.init(path)
        }
    }
}

extension AbsolutePath: ExpressibleByArgument {
    public init?(argument: String) {
        if let cwd = localFileSystem.currentWorkingDirectory {
            self.init(argument, relativeTo: cwd)
        } else {
            guard let path = try? AbsolutePath(validating: argument) else {
                return nil
            }
            self = path
        }
    }

    public static var defaultCompletionKind: CompletionKind {
        .directory
    }
}
