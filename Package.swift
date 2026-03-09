// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "checkout-ios-package",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        // Core modules (always needed)
        .library(name: "SpreedlyCore", targets: ["SpreedlyCore"]),
        .library(name: "SpreedlySecurity", targets: ["SpreedlySecurity"]),
        .library(name: "SpreedlyUI", targets: ["SpreedlyUI"]),
        // Gateway modules (optional — merchants add only what they use)
        .library(name: "SpreedlyStripeAPM", targets: ["SpreedlyStripeAPM"]),
        .library(name: "SpreedlyBraintree", targets: ["SpreedlyBraintree"]),
        // All-in-one (core only — gateways are always opt-in)
        .library(name: "Spreedly", targets: ["SpreedlyCore", "SpreedlySecurity", "SpreedlyUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/DataDog/dd-sdk-ios", from: "3.1.0")
    ],
    targets: [
        .binaryTarget(name: "SpreedlyCore", path: "./Frameworks/SpreedlyCore.xcframework"),
        .binaryTarget(name: "SpreedlySecurity", path: "./Frameworks/SpreedlySecurity.xcframework"),
        .binaryTarget(name: "SpreedlyUI", path: "./Frameworks/SpreedlyUI.xcframework"),
        .binaryTarget(name: "SpreedlyStripeAPM", path: "./Frameworks/SpreedlyStripeAPM.xcframework"),
        .binaryTarget(name: "SpreedlyBraintree", path: "./Frameworks/SpreedlyBraintree.xcframework"),
    ]
)
