// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "checkout-ios-package",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
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
    dependencies: [
        .package(url: "https://github.com/DataDog/dd-sdk-ios", from: "3.1.0"),
        .package(url: "https://bitbucket.org/forter-mobile/forter-ios.git", from: "2.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .binaryTarget(
            name: "SpreedlyCore", 
            path: "./Frameworks/SpreedlyCore.xcframework"
        ),
        .binaryTarget(name: "SpreedlySecurity", path: "./Frameworks/SpreedlySecurity.xcframework"),
        .binaryTarget(name: "SpreedlyUI", path: "./Frameworks/SpreedlyUI.xcframework"),
    ]
)
