// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Routing",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Routing",
            targets: ["Routing"]
        )
    ],
    targets: [
        .target(name: "Routing"),
        .testTarget(
            name: "RoutingTests",
            dependencies: ["Routing"]
        )
    ]
)
