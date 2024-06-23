// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-testing-backwards-compat",
    products: [
        .library(name: "Example", targets: ["Example"]),
    ],
    dependencies: [
        // Normal package dependencies
    ],
    targets: [
        .target(name: "Example"),
        .testTarget(
            name: "ExampleTests",
            dependencies: [
                .target(name: "Example"),
            ]
        )
    ]
)
