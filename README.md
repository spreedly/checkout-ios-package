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
end
```

Then run:
```bash
pod install
```

### Option 3: Manual Framework Integration

1. Download frameworks from GitHub releases
2. Drag and drop `.framework` files into your Xcode project
3. Link frameworks in your target's build phases
4. Import modules in your Swift files

## Documentation

### Integration Guide

For complete integration instructions, see the [Integration Guide](INTEGRATION_GUIDE.md) which covers:

- Complete setup instructions for Express Checkout and Hosted Fields
- Step-by-step integration examples in Swift and Objective-C
- Advanced configuration and customization options
- Error handling and best practices
- Security best practices
- Troubleshooting guide
- Complete API reference

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

---

For detailed integration instructions, troubleshooting, and security best practices, please refer to the [Integration Guide](INTEGRATION_GUIDE.md).

