// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "logrotate",
    platforms: [.macOS(.v11)],
    products: [
        .executable(
            name: "logrotate",
            targets: ["logrotate"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.2"),
        .package(url: "https://github.com/apple/swift-tools-support-core.git", .revision("492fe8dbf50c6f906444dbc227d3edb35ab0f4a7")),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.39.0"),
    ],
    targets: [
        .executableTarget(
            name: "logrotate",
            dependencies: [
                .product(name: "TSCBasic", package: "swift-tools-support-core"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "ObjcSource",
            ]
        ),
        .testTarget(
            name: "logrotateTests",
            dependencies: ["logrotate"]
        ),
        .target(
            name: "ObjcSource",
            dependencies: []
        ),
    ]
)
