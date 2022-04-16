// Copyright (c) 2022 Bob
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import ArgumentParser
import Foundation
import TSCBasic

struct Options: ParsableArguments {
    @Option(
        name: [.customLong("suffix")],
        help: "Log file suffix"
    )
    var suffix: String = ".log"

    @Option(
        name: [.customShort("M"), .customLong("MB")],
        help: "MB size for every log file"
    )
    var mb: Int?

    @Option(
        name: [.customShort("K"), .customLong("KB")],
        help: "KB size for every log file"
    )
    var kb: Int?

    @Option(
        name: [.customShort("B"), .customLong("B")],
        help: "Byte size for every log file"
    )
    var b: Int?

    @Option(
        name: [.customShort("L"), .customLong("line")],
        help: "Line count for every log file "
    )
    var line: Int?

    @Option(
        name: [.customLong("max")],
        help: "Max count of log files to keep"
    )
    var max: Int?

    @Option(
        name: .customLong("output"),
        help: "Output directory"
    )
    var output: AbsolutePath?

    @Flag(
        name: [.customLong("verbose")],
        help: "Verbose print log to stdout "
    )
    var verbose = false

    func toDumpOptions() -> DumpOptions {
        var size = Int.max
        if let mb = mb {
            size = mb * 1024 * 1024
        } else if let kb = kb {
            size = kb * 1024
        } else if let b = b {
            size = b
        }
        let line = self.line ?? Int.max
        let output = self.output ?? localFileSystem.currentWorkingDirectory!
        return DumpOptions(suffix: suffix, size: size, line: line, max: max, output: output, verbose: verbose)
    }
}
