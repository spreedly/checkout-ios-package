// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Spreedly",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Individual framework products for modular consumption
        .library(
            name: "SpreedlyCore",
            targets: ["SpreedlyCore"]
        ),
        .library(
            name: "SpreedlySecurity", 
            targets: ["SpreedlySecurity"]
        ),
        .library(
            name: "SpreedlyUI",
            targets: ["SpreedlyUI"]
        ),

        // All-in-one product
        .library(
            name: "Spreedly",
            targets: ["SpreedlyCore", "SpreedlySecurity", "SpreedlyUI"]
        ),
    ],
    targets: [
        // Binary targets for pre-built frameworks
        .binaryTarget(
            name: "SpreedlyCore",
            url: "https://github.com/spreedly/checkout-ios-package/releases/download/v1.0.0/SpreedlyCore-universal.zip",
            checksum: "replace-with-actual-checksum"
        ),
        .binaryTarget(
            name: "SpreedlySecurity",
            url: "https://github.com/spreedly/checkout-ios-package/releases/download/v1.0.0/SpreedlySecurity-universal.zip",
            checksum: "replace-with-actual-checksum"
        ),
        .binaryTarget(
            name: "SpreedlyUI",
            url: "https://github.com/spreedly/checkout-ios-package/releases/download/v1.0.0/SpreedlyUI-universal.zip",
            checksum: "replace-with-actual-checksum"
        )
    ]
) 