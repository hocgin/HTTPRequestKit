// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "HttpRequest",
  platforms: [
    .iOS(.v14),
    .macOS(.v10_15),
    .tvOS(.v10),
    .watchOS(.v3)
  ],
  products: [
    .library(name: "HttpRequest", targets: ["HttpRequest"]),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "HttpRequest",
      dependencies: []),
    .testTarget(
      name: "HttpRequestTests",
      dependencies: ["HttpRequest"]),
  ]
)
