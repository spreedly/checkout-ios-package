# Spreedly iOS SDK

> **⚠️ BETA - Not for Production Use**
> 
> This SDK is currently in beta. Do not use in production environments until a stable release is available.

A modern iOS SDK for integrating Spreedly payment processing into iOS applications. Built with Swift, SwiftUI, and following iOS best practices.

## Table of Contents

1. [Features](#features)
2. [Compatibility](#compatibility)
3. [Quick Start](#quick-start)
4. [Installation](#installation)
5. [Documentation](#documentation)
6. [Support](#support)

## Features

- **Secure Payment Processing**: Tokenized payment method creation with Spreedly's secure infrastructure
- **3DS Authentication**: Built-in support for Strong Customer Authentication (SCA) with automatic transaction completion
- **Modern UI**: Built with SwiftUI for a native iOS experience
- **Flexible Integration**: Support for both Drop-in Checkout and Hosted Fields
- **Additional Fields Support**: Pass billing and shipping information directly to payment processing
- **Customizable Styling**: Extensive theming and customization options
- **Comprehensive Validation**: Real-time form validation with error handling
- **Screen Protection**: Built-in screenshot and screen recording prevention for PCI DSS compliance
- **Swift & Objective-C Support**: Full support for both Swift and Objective-C projects

## Compatibility

### iOS Requirements

| Component             | Minimum Version | Recommended Version | Maximum Tested Version |
|-----------------------|-----------------|---------------------|------------------------|
| **iOS Version**       | 13.0            | 18.0                | 26.0.1                 |
| **Deployment Target** | 13.0            | 18.0                | 26.0.1                 |
| **Swift Version**     | 5.10            | 5.10                | 6.2                    |

### Supported iOS Versions

The SDK is tested and supported on the following iOS versions:

- ✅ **iOS 13.0** - Full compatibility
- ✅ **iOS 14.0** - Full compatibility
- ✅ **iOS 15.0** - Full compatibility
- ✅ **iOS 16.0** - Full compatibility
- ✅ **iOS 17.0** - Full compatibility
- ✅ **iOS 18.0** - Full compatibility
- ✅ **iOS 26.0.1** - Tested and verified

### Device Support

The SDK supports all iOS devices running iOS 13.0 or later:

- **iPhone**: iPhone 6s and newer
- **iPad**: iPad Air 2 and newer
- **iPod touch**: 7th generation and newer

### Architecture Support

- **arm64**: Native support for all modern iOS devices
- **x86_64**: Simulator support for Intel Macs and Apple chip
- **Universal Binaries**: Pre-built frameworks support both architectures

### Legacy iOS Support

- **iOS 12 and earlier**: Not supported
- **Pre-SwiftUI apps**: UIKit support is available with all the UI components

## Quick Start

### Prerequisites

- **Xcode**: 16.1 or newer
- **iOS**: 13.0 or later
- **Spreedly Account**: For API credentials

### Basic Setup

1. **Add the SDK to your project** using Swift Package Manager or CocoaPods (see Installation section)

2. **Initialize the SDK** in your app:

> **⚠️ Important**: You **MUST** call `Spreedly.setup(config:)` with `environmentKey`, `forterSiteId` (for 3DS), and signature parameters before making payment requests. `Spreedly.initializeSDK()` alone is **NOT sufficient**.

```swift
import SpreedlyCore
import SpreedlyUI

// Step 1: Basic initialization at app launch
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    Spreedly.initializeSDK()  // Creates SDK instance (not sufficient alone)
    return true
}

// Step 2: MANDATORY - Configure with credentials before payment
// You MUST call this with environmentKey, forterSiteId, and signature parameters
// See Integration Guide for complete example
```

3. **Use the Express Checkout** component:

```swift
import SwiftUI
import SpreedlyUI

struct CheckoutView: View {
    @State private var showCheckout = false
    
    var body: some View {
        Button("Show Checkout") {
            showCheckout = true
        }
        .sheet(isPresented: $showCheckout) {
            CardFormDropIn(
                onProcessingResult: { result in
                    if result.isSuccess {
                        print("Payment successful!")
                        showCheckout = false
                    }
                },
                onError: { error in
                    print("Error: \(error)")
                    showCheckout = false
                }
            )
        }
    }
}
```

For complete integration instructions, see the [Integration Guide](INTEGRATION_GUIDE.md).

## Installation

### Option 1: Swift Package Manager (Recommended)

1. **Add Package Dependency** in Xcode:
   - File → Add Package Dependencies
   - Enter repository URL: `https://github.com/spreedly/checkout-ios-sdk.git`
   - Select version requirements
   - Choose the modules you need:
     - `SpreedlyCore` - Core functionality
     - `SpreedlySecurity` - Security features
     - `SpreedlyUI` - UI components

2. **Add to Package.swift** (if using Package.swift):

```swift
dependencies: [
    .package(url: "https://github.com/spreedly/checkout-ios-sdk.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "SpreedlyCore", package: "SpreedlySDK"),
            .product(name: "SpreedlySecurity", package: "SpreedlySDK"),
            .product(name: "SpreedlyUI", package: "SpreedlySDK")
        ]
    )
]
```

#### ⚠️ Required: Add Forter3DS Dependency (For 3DS Authentication)

**Important:** If you plan to use 3DS (Three-Domain Secure) authentication, you **must** add the Forter3DS package as a direct dependency to your app target.

**Why is this needed?**

`SpreedlyCore` dynamically links to Forter3DS for 3DS authentication, but doesn't declare it as a transitive dependency. Since Forter3DS is a dynamic framework, it must be embedded in your app bundle. Swift Package Manager doesn't automatically embed transitive dynamic dependencies, so you must add it directly.

**How to add:**

1. **In Xcode:**
   - File → Swift Packages → Add Package Dependency
   - Enter repository URL: `https://bitbucket.org/forter-mobile/forter-ios.git`
   - Set the dependency rule to "Up to Next Major Version"
   - On the "Choose Package" screen, verify that `Forter3DS` is selected and press "Add Package"
   - Add `Forter3DS` product to your app target
   - Set to "Embed & Sign" in "Frameworks, Libraries, and Embedded Content"
   
   Reference: [Forter 3DS iOS SDK Documentation](https://docs.forter.com/3ds-ios-sdk)

2. **In Package.swift:**
```swift
dependencies: [
    .package(url: "https://github.com/spreedly/checkout-ios-sdk.git", from: "1.0.0"),
    .package(url: "https://bitbucket.org/forter-mobile/forter-ios.git", from: "2.1.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "SpreedlyCore", package: "SpreedlySDK"),
            .product(name: "SpreedlySecurity", package: "SpreedlySDK"),
            .product(name: "SpreedlyUI", package: "SpreedlySDK"),
            .product(name: "Forter3DS", package: "forter-ios")  // Required for 3DS
        ]
    )
]
```

**Note:** Skip this if you're not using 3DS authentication. The SDK handles the absence gracefully.

### Option 2: CocoaPods

Add to your `Podfile`:

```ruby
target 'YourApp' do
  use_frameworks!

  # All modules
  pod 'Spreedly', '~> 1.0'

  # Or specific modules
  # pod 'Spreedly/Core', '~> 1.0'
  # pod 'Spreedly/Security', '~> 1.0'
  # pod 'Spreedly/UI', '~> 1.0'
  
  # ⚠️ Required for 3DS Authentication
  # If you plan to use 3DS authentication, add Forter3DS:
  # Reference: https://docs.forter.com/3ds-ios-sdk
  pod 'forter3ds', :git => 'https://bitbucket.org/forter-mobile/forter-ios.git'
end
```

Then run:
```bash
pod install
```

#### ⚠️ Required: Add Forter3DS Dependency (For 3DS Authentication)

**Important:** If you plan to use 3DS (Three-Domain Secure) authentication, you **must** add the Forter3DS pod to your Podfile.

**Why is this needed?**

`SpreedlyCore` dynamically links to Forter3DS for 3DS authentication, but doesn't declare it as a transitive dependency. Since Forter3DS is a dynamic framework, it must be embedded in your app bundle. CocoaPods doesn't automatically embed transitive dynamic dependencies, so you must add it directly.

**Technical Details:**

The Forter3DS package uses pre-compiled `.xcframework` binaries that are dynamically linked by default. Because these are pre-compiled binaries, the linking type cannot be changed to static linking. The package includes:
- Pre-compiled `.xcframework` files via `.binaryTarget`
- `.library` products that default to dynamic linking
- Multiple binary targets: `Forter3DS`, `ThreeDS_SDK`, and `FTR3DSCommon`

Since static linking is not possible with pre-compiled binaries, the framework must be added as a direct dependency to ensure it's embedded in your app bundle.

**Forter3DS SDK Dependencies:**

The Forter3DS SDK includes the following external libraries (already embedded in the SDK):
- **ASN1Decoder**: Certificate parsing in ASN1 structure
- **SwCrypt**: Crypto library for JWS validation (used only in iOS 10 devices)
- **GMEllipticCurveCrypto**: Security framework used for elliptic curve keys crypto library

For more details, see the [Forter 3DS iOS SDK Documentation](https://docs.forter.com/3ds-ios-sdk).

**Note:** Skip this if you're not using 3DS authentication. The SDK handles the absence gracefully.

### Option 3: Manual Framework Integration

1. Download frameworks from GitHub releases
2. Drag and drop `.framework` files into your Xcode project
3. Link frameworks in your target's build phases
4. Import modules in your Swift files

## Documentation

### Integration Guide

For complete integration instructions, see the [Integration Guide](INTEGRATION_GUIDE.md) which covers:

- Complete setup instructions for Express Checkout and Hosted Fields
- **3DS Authentication**: Complete guide to Strong Customer Authentication (SCA) integration
- Step-by-step integration examples in Swift and Objective-C
- Advanced configuration and customization options
- Error handling and best practices
- Security best practices
- Troubleshooting guide
- Complete API reference

### API Reference

- **[MERCHANT_API_REFERENCE.md](MERCHANT_API_REFERENCE.md)** - Complete API reference for all merchant-facing classes
- **[SWIFTUI_VS_OBJECTIVEC_CLASSES.md](SWIFTUI_VS_OBJECTIVEC_CLASSES.md)** - Quick reference for SwiftUI vs Objective-C/UIKit classes

### Merchant-Facing Components

| Component | SwiftUI | UIKit/Objective-C |
|-----------|---------|-------------------|
| **Complete Payment Form** | `CardFormDropIn` | `CardFormDropInViewController` |
| **Individual Field** | `SPLTextField` | `SPLTextFieldViewController` |
| **CVV Recaching** | `SpreedlyCVVRecachingView` | `CVVRecachingViewController` |
| **3DS Challenge** | `DoChallengeIfNeeded` | `ThreeDSChallengeViewController` |

### Additional Resources

- **Spreedly API Documentation**: [docs.spreedly.com](https://docs.spreedly.com/)
- **Package Verification**: See [PACKAGE_VERIFICATION.md](PACKAGE_VERIFICATION.md) for security verification instructions
- **Privacy Requirements**: See [PLATFORM_PRIVACY_REQUIREMENTS.md](PLATFORM_PRIVACY_REQUIREMENTS.md) for privacy compliance information

## Support

### Getting Help

- **Integration Guide**: [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) - Comprehensive integration documentation
- **Spreedly Documentation**: [docs.spreedly.com](https://docs.spreedly.com/) - API documentation and guides
- **Support Portal**: [spreedly.com/support](https://spreedly.com/support/) - Customer support
- **GitHub Issues**: Report bugs and request features

### Common Questions

**Q: What iOS version is required?**  
A: iOS 13.0 or later is required.

**Q: Does it work with Objective-C?**  
A: Yes, the SDK has full Objective-C support. See the Integration Guide for examples.

**Q: Is the SDK secure?**  
A: Yes, the SDK includes built-in security features including screen protection, secure token handling, and PCI DSS compliance features. See the Integration Guide for security best practices.

**Q: How do I customize the UI?**  
A: The SDK supports extensive theming. See the Integration Guide for customization options.

**Q: How does 3DS authentication work?**  
A: The SDK automatically handles 3DS challenges when required. When your backend indicates 3DS is needed, present the challenge UI and the SDK will handle the authentication flow, including automatic transaction completion and status checking. See the Integration Guide for complete 3DS integration details.

---

For detailed integration instructions, troubleshooting, and security best practices, please refer to the [Integration Guide](INTEGRATION_GUIDE.md).

