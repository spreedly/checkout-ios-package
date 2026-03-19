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
        .library(name: "SpreedlyBraintree", targets: ["SpreedlyBraintree"]),
        // All-in-one (core only — gateways are always opt-in)
        .library(name: "Spreedly", targets: ["SpreedlyCore", "SpreedlySecurity", "SpreedlyUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/DataDog/dd-sdk-ios.git", from: "3.1.0"),
        .package(url: "https://github.com/stripe/stripe-ios-spm.git", from: "25.0.0"),
        .package(url: "https://github.com/braintree/braintree_ios.git", from: "7.0.0"),
        .package(url: "https://bitbucket.org/forter-mobile/forter-ios.git", from: "2.1.0")
    ],
    targets: [
        // Wrapper targets that combine the binary frameworks with their required dependencies
        .target(
            name: "SpreedlyCore",
            dependencies: [
                "SpreedlyCoreBinary",
                .product(name: "DatadogCore", package: "dd-sdk-ios"),
                .product(name: "DatadogLogs", package: "dd-sdk-ios"),
                .product(name: "Forter3DS", package: "forter-ios", condition: .when(platforms: [.iOS]))
            ]
        ),
        .target(
            name: "SpreedlySecurity",
            dependencies: ["SpreedlySecurityBinary"]
        ),
        .target(
            name: "SpreedlyUI",
            dependencies: [
                "SpreedlyUIBinary",
                "SpreedlyCore",
                "SpreedlySecurity"
            ]
        ),
        .target(
            name: "SpreedlyStripeAPM",
            dependencies: [
                "SpreedlyStripeAPMBinary",
                "SpreedlyCore",
                .product(name: "StripePaymentSheet", package: "stripe-ios-spm")
            ]
        ),
        .target(
            name: "SpreedlyBraintree",
            dependencies: [
                "SpreedlyBraintreeBinary",
                "SpreedlyCore",
                .product(name: "BraintreeCore", package: "braintree_ios"),
                .product(name: "BraintreePayPal", package: "braintree_ios"),
                .product(name: "BraintreeVenmo", package: "braintree_ios"),
                .product(name: "BraintreeDataCollector", package: "braintree_ios")
            ]
        ),

        // The actual binary targets
        .binaryTarget(name: "SpreedlyCoreBinary", path: "./Frameworks/SpreedlyCore.xcframework"),
        .binaryTarget(name: "SpreedlySecurityBinary", path: "./Frameworks/SpreedlySecurity.xcframework"),
        .binaryTarget(name: "SpreedlyUIBinary", path: "./Frameworks/SpreedlyUI.xcframework"),
        .binaryTarget(name: "SpreedlyStripeAPMBinary", path: "./Frameworks/SpreedlyStripeAPM.xcframework"),
        .binaryTarget(name: "SpreedlyBraintreeBinary", path: "./Frameworks/SpreedlyBraintree.xcframework"),
    ]
)
