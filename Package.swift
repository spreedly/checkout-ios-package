// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "checkout-ios-package",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Core modules (always needed)
        .library(name: "SpreedlyCore", targets: ["SpreedlyCore"]),
        .library(name: "SpreedlySecurity", targets: ["SpreedlySecurity"]),
        .library(name: "SpreedlyUI", targets: ["SpreedlyUI"]),
        // Gateway modules (optional — merchants add only what they use)
        .library(name: "SpreedlyStripeAPM", targets: ["SpreedlyStripeAPM"]),
        .library(name: "SpreedlyStripeRadar", targets: ["SpreedlyStripeRadar"]),
        // SpreedlyBraintree and SpreedlyPayPal both link PPRiskMagnes dynamically, so each
        // product also vends SpreedlyRiskSupport to bring PayPalRisk into the consumer's graph.
        .library(name: "SpreedlyBraintree", targets: ["SpreedlyBraintree", "SpreedlyRiskSupport"]),
        .library(name: "SpreedlyPayPal", targets: ["SpreedlyPayPal", "SpreedlyRiskSupport"]),
        .library(name: "SpreedlyClickToPay", targets: ["SpreedlyClickToPay"]),
    ],
    dependencies: [
        // PPRiskMagnes moved out of braintree_ios into this shared package in Braintree 7.11.0,
        // and paypal-ios 3.1.0 uses the same one. Both upstreams pin `exact: "5.6.0"`, so this
        // must match exactly or the graph becomes unsatisfiable.
        .package(url: "https://github.com/paypal/paypal-risk-ios", exact: "5.6.0"),
    ],
    targets: [
        .binaryTarget(name: "SpreedlyCore", path: "./Frameworks/SpreedlyCore.xcframework"),
        .binaryTarget(name: "SpreedlySecurity", path: "./Frameworks/SpreedlySecurity.xcframework"),
        .binaryTarget(name: "SpreedlyUI", path: "./Frameworks/SpreedlyUI.xcframework"),
        .binaryTarget(name: "SpreedlyStripeAPM", path: "./Frameworks/SpreedlyStripeAPM.xcframework"),
        .binaryTarget(name: "SpreedlyStripeRadar", path: "./Frameworks/SpreedlyStripeRadar.xcframework"),
        .binaryTarget(name: "SpreedlyBraintree", path: "./Frameworks/SpreedlyBraintree.xcframework"),
        .binaryTarget(name: "SpreedlyPayPal", path: "./Frameworks/SpreedlyPayPal.xcframework"),
        .binaryTarget(name: "SpreedlyClickToPay", path: "./Frameworks/SpreedlyClickToPay.xcframework"),

        // A `.binaryTarget` cannot declare dependencies, so PPRiskMagnes cannot be attached to the
        // Braintree/PayPal xcframeworks directly. This shim carries that dependency instead: any
        // product vending it pulls PayPalRisk in, and SwiftPM embeds the dynamic
        // PPRiskMagnes.framework into the consuming app. Without it, both frameworks link
        // @rpath/PPRiskMagnes.framework with nothing supplying it and the app fails at launch
        // with "Library not loaded".
        .target(name: "SpreedlyRiskSupport",
                dependencies: [.product(name: "PayPalRisk", package: "paypal-risk-ios")],
                path: "Sources/SpreedlyRiskSupport"),
    ]
)
