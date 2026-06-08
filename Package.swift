// swift-tools-version: 6.0
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
        .library(name: "SpreedlyStripeRadar", targets: ["SpreedlyStripeRadar"]),
        .library(name: "SpreedlyBraintree", targets: ["SpreedlyBraintree"]),
    ],
    targets: [
        .binaryTarget(name: "SpreedlyCore", path: "./Frameworks/SpreedlyCore.xcframework"),
        .binaryTarget(name: "SpreedlySecurity", path: "./Frameworks/SpreedlySecurity.xcframework"),
        .binaryTarget(name: "SpreedlyUI", path: "./Frameworks/SpreedlyUI.xcframework"),
        .binaryTarget(name: "SpreedlyStripeAPM", path: "./Frameworks/SpreedlyStripeAPM.xcframework"),
        .binaryTarget(name: "SpreedlyStripeRadar", path: "./Frameworks/SpreedlyStripeRadar.xcframework"),
        .binaryTarget(name: "SpreedlyBraintree", path: "./Frameworks/SpreedlyBraintree.xcframework"),
    ]
)
