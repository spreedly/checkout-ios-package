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
- **Backend API**: Your server must generate signature parameters (see [Server-Side Requirements](#server-side-requirements))

### Installation Checklist

Follow these steps in order:

- [ ] **Step 1**: Add SDK via Swift Package Manager (see [Installation](#installation))
- [ ] **Step 2**: Add Forter3DS dependency (if using 3DS authentication)
- [ ] **Step 3**: Import required modules in your code
- [ ] **Step 4**: Initialize SDK at app launch
- [ ] **Step 5**: Configure SDK with credentials (from your backend)
- [ ] **Step 6**: Implement payment form UI
- [ ] **Step 7**: Subscribe to payment results
- [ ] **Step 8**: Handle payment results

### Step-by-Step Implementation

#### Step 1: Add SDK via Swift Package Manager

1. In Xcode: **File → Add Package Dependencies**
2. Enter URL: `https://github.com/spreedly/checkout-ios-sdk.git`
3. Select version (e.g., "Up to Next Major Version" from "1.0.0")
4. Choose these products:
   - ✅ `SpreedlyCore` (required)
   - ✅ `SpreedlySecurity` (required)
   - ✅ `SpreedlyUI` (required for UI components)

#### Step 2: Add Forter3DS (If Using 3DS)

**Only if you need 3DS authentication:**

1. In Xcode: **File → Swift Packages → Add Package Dependency**
2. Enter URL: `https://bitbucket.org/forter-mobile/forter-ios.git`
3. Select `Forter3DS` product
4. Add to your app target
5. Set to **"Embed & Sign"** in Frameworks settings

> **Skip this step if you're not using 3DS authentication.**

#### Step 3: Import Modules

Add imports at the top of your Swift files:

```swift
import SpreedlyCore      // Core payment processing
import SpreedlySecurity  // Security features (automatic)
import SpreedlyUI        // UI components (if using UI)
```

#### Step 4: Initialize SDK at App Launch

**In your AppDelegate or SwiftUI App:**

```swift
import UIKit
import SpreedlyCore

// For UIKit apps
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, 
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize SDK early in app lifecycle
        Spreedly.initializeSDK()
        return true
    }
}

// For SwiftUI apps
@main
struct MyApp: App {
    init() {
        // Initialize SDK early in app lifecycle
        Spreedly.initializeSDK()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

> **⚠️ Important**: `initializeSDK()` alone is **NOT sufficient**. You must also call `setup(config:)` with credentials.

#### Step 5: Configure SDK with Credentials

**You MUST call `setup(config:)` before making any payment requests.**

Your backend must provide these credentials (see [Server-Side Requirements](#server-side-requirements)):

```swift
import SpreedlyCore

// Call this AFTER you receive credentials from your backend
func configureSDK(credentials: ServerCredentials) {
    let config = SpreedlyConfig(
        environmentKey: credentials.environmentKey,      // REQUIRED
        forterSiteId: credentials.forterSiteId,          // REQUIRED for 3DS
        certificateToken: credentials.certificateToken, // REQUIRED
        nonce: credentials.nonce,                       // REQUIRED
        signature: credentials.signature,                // REQUIRED
        timestamp: credentials.timestamp                 // REQUIRED
    )
    
    Spreedly.setup(config: config)
}
```

**Example: Fetching credentials from your backend:**

```swift
func setupSpreedlySDK() {
    // Fetch credentials from your backend
    fetchCredentialsFromBackend { [weak self] credentials in
        guard let self = self else { return }
        
        let config = SpreedlyConfig(
            environmentKey: credentials.environmentKey,
            forterSiteId: credentials.forterSiteId,
            certificateToken: credentials.certificateToken,
            nonce: credentials.nonce,
            signature: credentials.signature,
            timestamp: credentials.timestamp
        )
        
        Spreedly.setup(config: config)
        
        // Now SDK is ready for payment operations
        print("SDK configured successfully")
    }
}
```

#### Step 6: Implement Payment Form UI

**SwiftUI Example:**

```swift
import SwiftUI
import SpreedlyUI
import SpreedlyCore
import Combine

struct CheckoutView: View {
    @State private var showCheckout = false
    @State private var paymentResult: PaymentResult?
    @State private var cancellable: AnyCancellable?
    
    var body: some View {
        VStack {
            Button("Show Checkout") {
                showCheckout = true
            }
            
            if let result = paymentResult, result.isSuccess {
                Text("Payment Successful!")
                    .foregroundColor(.green)
                if let token = result.token {
                    Text("Token: \(token)")
                }
            }
        }
        .sheet(isPresented: $showCheckout) {
            CardFormDropIn(
                yearFormat: .fourDigit,
                nameDisplayMode: .separateFields,
                onProcessingResult: { processingResult in
                    if processingResult.isProcessing {
                        print("Payment processing...")
                    } else if processingResult.isValidationFailed {
                        print("Validation failed: \(processingResult.invalidFields)")
                    }
                }
            )
            .screenPrevention()  // Required: Protect sensitive data
        }
        .onAppear {
            // ⚠️ CRITICAL: Subscribe BEFORE showing form
            cancellable = Spreedly.shared().subscribeToPaymentResults { result in
                paymentResult = result
                
                if result.isSuccess {
                    showCheckout = false
                    print("Payment successful! Token: \(result.token ?? "N/A")")
                } else if result.isFailure {
                    showCheckout = false
                    if let details = result.failureDetails {
                        print("Payment failed: \(details.getDescription())")
                    }
                }
            }
        }
        .onDisappear {
            cancellable?.cancel()  // Clean up subscription
        }
    }
}
```

#### Step 7: Subscribe to Payment Results

**⚠️ CRITICAL**: Always subscribe to results **BEFORE** presenting the payment form.

```swift
// ✅ CORRECT: Subscribe first
var cancellable: AnyCancellable?
cancellable = Spreedly.shared().subscribeToPaymentResults { result in
    // Handle result
}
// Now show form
showCheckout = true

// ❌ WRONG: Showing form before subscribing
showCheckout = true
cancellable = Spreedly.shared().subscribeToPaymentResults { result in
    // May miss the result!
}
```

#### Step 8: Handle Payment Results

```swift
Spreedly.shared().subscribeToPaymentResults { result in
    if result.isSuccess {
        // ✅ Payment successful
        let token = result.token ?? ""
        // Send token to your backend for transaction processing
        sendTokenToBackend(token: token)
        
    } else if result.isFailure {
        // ❌ Payment failed
        if let details = result.failureDetails {
            // Show error to user
            showError(details.getDescription())
            
            // Handle specific error types
            switch details.errorType {
            case .apiError:
                if details.apiError == .validationError {
                    // Handle validation errors
                    for error in details.validationErrors {
                        highlightField(error.field, message: error.message)
                    }
                }
            case .networkError:
                // Handle network errors (implement retry)
                retryPayment()
            case .unknownError:
                // Handle unknown errors
                showGenericError()
            }
        }
    }
}
```

### Server-Side Requirements

Your backend **MUST** provide these credentials for SDK configuration:

```swift
struct ServerCredentials {
    let environmentKey: String      // Your Spreedly environment key
    let forterSiteId: String?       // Forter Site ID (if using 3DS)
    let certificateToken: String   // Certificate token from Spreedly
    let nonce: String              // Unique nonce (generated server-side)
    let signature: String          // Cryptographic signature (generated server-side)
    let timestamp: String          // Unix timestamp
}
```

**Your backend must:**
1. Generate a unique `nonce` for each request
2. Generate a `signature` using your Spreedly credentials
3. Provide current `timestamp`
4. Return all values to your iOS app

**Reference**: See [Spreedly API Documentation](https://docs.spreedly.com/) for signature generation details.

### Complete Working Example

Here's a complete, working example from scratch:

```swift
import SwiftUI
import SpreedlyCore
import SpreedlyUI
import Combine

@main
struct MyApp: App {
    init() {
        // Step 1: Initialize SDK
        Spreedly.initializeSDK()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var showCheckout = false
    @State private var paymentToken: String?
    @State private var cancellable: AnyCancellable?
    
    var body: some View {
        VStack(spacing: 20) {
            if let token = paymentToken {
                Text("Payment Token: \(token)")
                    .foregroundColor(.green)
            }
            
            Button("Start Payment") {
                // Step 2: Configure SDK (in real app, fetch from backend)
                configureSDK()
                
                // Step 3: Show checkout
                showCheckout = true
            }
        }
        .sheet(isPresented: $showCheckout) {
            CheckoutView(onComplete: { token in
                paymentToken = token
                showCheckout = false
            })
        }
    }
    
    func configureSDK() {
        // In production, fetch these from your backend
        let config = SpreedlyConfig(
            environmentKey: "your_environment_key",
            forterSiteId: "your_forter_site_id",  // Optional if not using 3DS
            certificateToken: "your_certificate_token",
            nonce: "your_nonce",
            signature: "your_signature",
            timestamp: "\(Int(Date().timeIntervalSince1970))"
        )
        Spreedly.setup(config: config)
    }
}

struct CheckoutView: View {
    let onComplete: (String) -> Void
    @State private var cancellable: AnyCancellable?
    
    var body: some View {
        CardFormDropIn(
            yearFormat: .fourDigit,
            nameDisplayMode: .separateFields,
            onProcessingResult: { result in
                print("Processing: \(result.isProcessing)")
            }
        )
        .screenPrevention()
        .onAppear {
            // Subscribe BEFORE form is shown
            cancellable = Spreedly.shared().subscribeToPaymentResults { result in
                if result.isSuccess, let token = result.token {
                    onComplete(token)
                }
            }
        }
        .onDisappear {
            cancellable?.cancel()
        }
    }
}
```

For complete integration instructions with all features, see the [Integration Guide](INTEGRATION_GUIDE.md).

## Installation

> **For Senior Engineers**: This section covers installation via Swift Package Manager (SPM), which is the recommended method. If you're using CocoaPods or manual integration, see the [Integration Guide](INTEGRATION_GUIDE.md).

### Option 1: Swift Package Manager (Recommended)

**Why SPM?**
- Native iOS dependency management
- Automatic version resolution
- No additional tools required
- Works seamlessly with Xcode

**Installation Steps:**

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

**Verification:**
After adding packages, verify in Xcode:
1. Open your project settings
2. Go to "Frameworks, Libraries, and Embedded Content"
3. Verify you see:
   - `SpreedlyCore` (Embed & Sign)
   - `SpreedlySecurity` (Embed & Sign)
   - `SpreedlyUI` (Embed & Sign)
   - `Forter3DS` (Embed & Sign) - only if using 3DS

**Common SPM Issues:**

**Issue: "No such module 'SpreedlyCore'"**
- **Solution**: Clean build folder (Cmd+Shift+K), then rebuild
- **Solution**: Close and reopen Xcode
- **Solution**: Verify package is added in Project Settings → Package Dependencies

**Issue: "Package resolved but not found"**
- **Solution**: File → Packages → Reset Package Caches
- **Solution**: Delete `~/.swiftpm` folder and rebuild

**Issue: "Forter3DS not found at runtime"**
- **Solution**: Ensure Forter3DS is set to "Embed & Sign" (not just "Link")
- **Solution**: Verify Forter3DS is added to your app target (not just SDK target)

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

## Module Overview

### What Each Module Does

| Module | Purpose | When to Import |
|--------|---------|----------------|
| **SpreedlyCore** | Core payment processing, API communication, 3DS handling | Always required |
| **SpreedlySecurity** | Encryption, secure storage, screen prevention | Automatically included (no direct import needed) |
| **SpreedlyUI** | Payment form components, validation, theming | Required for UI components |

### Module Dependencies

```
Your App
  ├── SpreedlyUI (if using UI components)
  │     └── SpreedlyCore (automatic)
  │           └── SpreedlySecurity (automatic)
  └── SpreedlyCore (if using programmatic API)
        └── SpreedlySecurity (automatic)
```

**Key Points:**
- `SpreedlySecurity` is automatically included - you don't need to import it directly
- If you import `SpreedlyUI`, you automatically get `SpreedlyCore`
- You can use `SpreedlyCore` alone if you're building custom UI

### Implementation Checklist by Module

#### Using SpreedlyUI (Recommended for most merchants)

- [ ] Import `SpreedlyUI` and `SpreedlyCore`
- [ ] Initialize SDK at app launch
- [ ] Configure SDK with credentials
- [ ] Add `CardFormDropIn` or `SPLTextField` components
- [ ] Subscribe to payment results
- [ ] Apply `.screenPrevention()` modifier
- [ ] Handle payment results

#### Using SpreedlyCore Only (Advanced - Custom UI)

- [ ] Import `SpreedlyCore`
- [ ] Initialize SDK at app launch
- [ ] Configure SDK with credentials
- [ ] Build your own UI for collecting card data
- [ ] Use `SecureValueContainer` to store card data
- [ ] Call `createCreditCard()` with collected data
- [ ] Subscribe to payment results
- [ ] Handle payment results

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
| **3DS Challenge** | `DoChallengeIfNeeded` | `DoChallengeIfNeededViewController` |

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

**Q: Do I need to import all three modules?**  
A: No. If you use `SpreedlyUI`, you automatically get `SpreedlyCore`. `SpreedlySecurity` is always included automatically. You only need to explicitly import what you use directly.

**Q: What happens if I don't add Forter3DS?**  
A: The SDK will work fine, but 3DS authentication won't be available. If a payment requires 3DS, you'll get an error. The SDK handles the absence gracefully.

**Q: Can I use the SDK without UI components?**  
A: Yes, you can use `SpreedlyCore` directly and build your own UI. You'll need to use `SecureValueContainer` to store card data securely.

**Q: Why do I need to subscribe to results BEFORE showing the form?**  
A: Payment processing happens asynchronously. If you subscribe after showing the form, you might miss the result callback. Always subscribe first, then show the UI.

**Q: Do I need to call setup() every time?**  
A: No, but you must call it at least once before making payment requests. You can call it once at app startup after fetching credentials from your backend.

**Q: What if my backend doesn't provide credentials immediately?**  
A: That's fine. Call `initializeSDK()` early, then call `setup(config:)` when credentials are available. Don't show payment forms until after `setup()` is called.

---

For detailed integration instructions, troubleshooting, and security best practices, please refer to the [Integration Guide](INTEGRATION_GUIDE.md).

