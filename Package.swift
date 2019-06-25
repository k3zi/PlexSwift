// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PlexSwift",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "PlexSwift",
            targets: ["PlexSwift"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/gcharita/XMLMapper.git",
            .upToNextMajor(from: "1.5.3")
        ),
    ],
    targets: [
        .target(
            name: "PlexSwift",
            dependencies: ["XMLMapper"]
        ),
        .testTarget(
            name: "PlexSwiftTests",
            dependencies: ["PlexSwift"]
        ),
    ]
)
