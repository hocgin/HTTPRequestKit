// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HTTPRequestKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(name: "HTTPRequestKit", targets: ["HTTPRequestKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "HTTPRequestKit",
            dependencies: []),
        .testTarget(
            name: "HTTPRequestTests",
            dependencies: ["HTTPRequestKit"]),
    ])
