// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JellyfishClientSdk",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "JellyfishClientSdk",
            targets: ["JellyfishClientSdk"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.6.0"),
        .package(url: "https://github.com/jellyfish-dev/membrane-webrtc-ios.git", branch: "jellyfish"),
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "3.0.0"),
        .package(name: "Mockingbird", url: "https://github.com/birdrides/mockingbird.git", .upToNextMinor(from: "0.20.0")),

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "JellyfishClientSdk",
            dependencies: [
                .product(name: "MembraneRTC", package: "membrane-webrtc-ios"),
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "Starscream", package: "Starscream"),
            ]),
        .testTarget(name: "JellyfishClientSdkTests", dependencies: ["JellyfishClientSdk", "Mockingbird"]),
    ]
)
