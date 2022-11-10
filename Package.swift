// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LaunchDarkly+Combine",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .watchOS(.v6),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "LaunchDarkly+Combine",
            targets: ["LaunchDarkly+Combine"]),
    ],
    dependencies: [
        .package(name: "LaunchDarkly", url: "https://github.com/launchdarkly/ios-client-sdk.git", .upToNextMajor(from: Version(7, 1, 0)))
    ],
    targets: [
        .target(
            name: "LaunchDarkly+Combine",
            dependencies: ["LaunchDarkly"],
            path: "Sources")
    ]
)
