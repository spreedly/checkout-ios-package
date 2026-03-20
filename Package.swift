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
        .library(name: "SpreedlyCore", targets: ["SpreedlyCore", "SpreedlyCoreDeps"]),
        .library(name: "SpreedlySecurity", targets: ["SpreedlySecurity"]),
        .library(name: "SpreedlyUI", targets: ["SpreedlyUI"]),
        // Gateway modules (optional — merchants add only what they use)
        .library(name: "SpreedlyStripeAPM", targets: ["SpreedlyStripeAPM", "SpreedlyStripeAPMDeps"]),
        .library(name: "SpreedlyBraintree", targets: ["SpreedlyBraintree", "SpreedlyBraintreeDeps"]),
        // All-in-one (core only — gateways are always opt-in)
        .library(name: "Spreedly", targets: ["SpreedlyCore", "SpreedlySecurity", "SpreedlyUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/DataDog/dd-sdk-ios.git", from: "3.1.0"),
        .package(url: "https://github.com/stripe/stripe-ios-spm.git", from: "25.0.0"),
        .package(url: "https://github.com/braintree/braintree_ios.git", from: "7.0.0"),
    ],
    targets: [
        .binaryTarget(name: "SpreedlyCore", path: "./Frameworks/SpreedlyCore.xcframework"),
        .target(
            name: "SpreedlyCoreDeps",
            dependencies: [
                .product(name: "DatadogCore", package: "dd-sdk-ios"),
                .product(name: "DatadogLogs", package: "dd-sdk-ios"),
            ]
        ),
        .binaryTarget(name: "SpreedlySecurity", path: "./Frameworks/SpreedlySecurity.xcframework"),
        .binaryTarget(name: "SpreedlyUI", path: "./Frameworks/SpreedlyUI.xcframework"),
        .binaryTarget(name: "SpreedlyStripeAPM", path: "./Frameworks/SpreedlyStripeAPM.xcframework"),
        .target(
            name: "SpreedlyStripeAPMDeps",
            dependencies: [
                .product(name: "StripePaymentSheet", package: "stripe-ios-spm"),
            ]
        ),
        .binaryTarget(name: "SpreedlyBraintree", path: "./Frameworks/SpreedlyBraintree.xcframework"),
        .target(
            name: "SpreedlyBraintreeDeps",
            dependencies: [
                .product(name: "BraintreeCore", package: "braintree_ios"),
                .product(name: "BraintreePayPal", package: "braintree_ios"),
                .product(name: "BraintreeVenmo", package: "braintree_ios"),
                .product(name: "BraintreeDataCollector", package: "braintree_ios"),
            ]
        ),
    ]
)
