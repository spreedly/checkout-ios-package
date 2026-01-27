# Spreedly iOS SDK Integration Guide

This comprehensive guide covers everything you need to integrate the Spreedly iOS SDK into your iOS application.

## Quick Reference

- **[MERCHANT_API_REFERENCE.md](MERCHANT_API_REFERENCE.md)** - Complete API reference for all merchant-facing classes
- **[SWIFTUI_VS_OBJECTIVEC_CLASSES.md](SWIFTUI_VS_OBJECTIVEC_CLASSES.md)** - Quick reference for SwiftUI vs Objective-C/UIKit classes

## Merchant-Facing Components Summary

| Component | SwiftUI | UIKit/Objective-C | Purpose |
|-----------|---------|-------------------|---------|
| **Complete Payment Form** | `CardFormDropIn` | `CardFormDropInViewController` | Full checkout form with all fields |
| **Individual Field** | `SPLTextField` | `SPLTextFieldViewController` | Single form field component |
| **CVV Recaching** | `SpreedlyCVVRecachingView` | `CVVRecachingViewController` | Collect CVV to recache payment method |
| **3DS Challenge** | `DoChallengeIfNeeded` | `DoChallengeIfNeededViewController` | Present 3DS authentication challenge |

**Note:** All UIKit/Objective-C classes are wrappers around SwiftUI components, providing the same functionality with Objective-C compatible APIs.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Basic Setup](#basic-setup)
4. [Express Checkout Integration](#express-checkout-integration)
5. [Individual Field Integration](#individual-field-integration)
6. [Custom Form Integration](#custom-form-integration)
7. [Additional Fields Integration](#additional-fields-integration)
8. [CVV Recaching](#cvv-recaching)
9. [3DS Authentication](#3ds-authentication)
10. [Advanced Features](#advanced-features)
11. [Screen Prevention and Security](#screen-prevention-and-security)
12. [Logging System](#logging-system)
13. [Error Handling](#error-handling)
14. [Memory Management and Cancellables](#memory-management-and-cancellables)
15. [Testing](#testing)
16. [Objective-C Integration](#objective-c-integration)
17. [Troubleshooting](#troubleshooting)
18. [Security Best Practices](#security-best-practices)
19. [Best Practices](#best-practices)
20. [Support Resources](#support-resources)

## Prerequisites

Before integrating the Spreedly iOS SDK, ensure you have:

- **iOS 13.0+** deployment target
- **Xcode 16.1+** for development
- **Swift 5.10+** for Swift projects
- **Spreedly Account** with API credentials
- **Valid Environment Key** from Spreedly dashboard

### Required Credentials

You'll need the following from your Spreedly account:

**Note:** The following is an example structure showing the types of credentials you'll need. You should implement your own credential management system:

```swift
// Example: Structure showing required credential types
// This is NOT an SDK class - implement your own credential management
struct ExampleCredentials {
    let environmentKey: String      // Your Spreedly environment key
    let token: String              // API token for authentication
    let nonce: String              // Unique nonce for each request
    let timestamp: String          // Current timestamp
    let certificateToken: String   // Certificate token for security
    let signature: String          // Generated signature
}
```

## Installation

### Option 1: Swift Package Manager (Recommended)

1. **Add Package Dependency** in Xcode:

   - File → Add Package Dependencies
   - Enter repository URL: `https://github.com/spreedly/checkout-ios-sdk.git`
   - Select version requirements
   - Choose the modules you need

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

**Important:** If you plan to use 3DS (Three-Domain Secure) authentication, you **must** add the Forter3DS package as a direct dependency to your app target. This is required because `SpreedlyCore` dynamically links to Forter3DS but doesn't declare it as a transitive dependency.

**Why is this needed?**

- `SpreedlyCore` uses Forter3DS for 3DS authentication flows
- Forter3DS is dynamically linked (not statically compiled into SpreedlyCore)
- Dynamic frameworks must be embedded in the app bundle at runtime
- Swift Package Manager doesn't automatically embed transitive dynamic dependencies
- Without this dependency, your app will crash on real devices with: `dyld: Library not loaded: @rpath/Forter3DS.framework/Forter3DS`

**How to add Forter3DS via Swift Package Manager:**

Reference: [Forter 3DS iOS SDK Documentation](https://docs.forter.com/3ds-ios-sdk)

1. **In Xcode:**
   - File → Swift Packages → Add Package Dependency
   - Enter repository URL: `https://bitbucket.org/forter-mobile/forter-ios.git`
   - Set the dependency rule to "Up to Next Major Version"
   - On the "Choose Package" screen, verify that `Forter3DS` is selected and press "Add Package"
   - Add `Forter3DS` product to your app target
   - Ensure it's set to "Embed & Sign" in your target's "Frameworks, Libraries, and Embedded Content"

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

**Note:** If you're not using 3DS authentication, you can skip adding Forter3DS. The SDK will gracefully handle the absence of Forter3DS and show an appropriate message if 3DS is required.

### Option 2: Manual Framework Integration

1. **Download frameworks** from GitHub releases
2. **Drag and drop** `.framework` files into your Xcode project
3. **Link frameworks** in your target's build phases
4. **Import modules** in your Swift files

### Option 3: CocoaPods

```ruby
# Podfile
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

#### ⚠️ Required: Add Forter3DS Dependency (For 3DS Authentication)

**Important:** If you plan to use 3DS (Three-Domain Secure) authentication, you **must** add the Forter3DS pod to your Podfile. This is required because `SpreedlyCore` dynamically links to Forter3DS but doesn't declare it as a transitive dependency.

**Why is this needed?**

- `SpreedlyCore` uses Forter3DS for 3DS authentication flows
- Forter3DS is dynamically linked (not statically compiled into SpreedlyCore)
- Dynamic frameworks must be embedded in the app bundle at runtime
- CocoaPods doesn't automatically embed transitive dynamic dependencies
- Without this dependency, your app will crash on real devices with: `dyld: Library not loaded: @rpath/Forter3DS.framework/Forter3DS`

**Technical Details:**

The Forter3DS package uses pre-compiled `.xcframework` binaries with dynamic linking by default. Because these are pre-compiled binaries, the linking type cannot be changed to static linking. The package structure includes:
- `.binaryTarget` with pre-compiled `.xcframework` files
- `.library` products that default to dynamic linking (not static)
- Multiple binary targets: `Forter3DS`, `ThreeDS_SDK`, and `FTR3DSCommon`

Since static linking is not possible with pre-compiled binaries, the framework must be added as a direct dependency to ensure it's embedded in your app bundle.

**Forter3DS SDK Dependencies:**

The Forter3DS SDK includes the following external libraries (already embedded in the SDK):
- **ASN1Decoder**: Certificate parsing in ASN1 structure
- **SwCrypt**: Crypto library for JWS validation (used only in iOS 10 devices)
- **GMEllipticCurveCrypto**: Security framework used for elliptic curve keys crypto library

For more details, see the [Forter 3DS iOS SDK Documentation](https://docs.forter.com/3ds-ios-sdk).

**Note:** If you're not using 3DS authentication, you can skip adding Forter3DS. The SDK will gracefully handle the absence of Forter3DS and show an appropriate message if 3DS is required.

## Basic Setup

> **⚠️ Important**: `Spreedly.setup(config:)` is **MANDATORY** and must be called with `environmentKey`, `forterSiteId` (for 3DS), and signature parameters (nonce, signature, certificateToken, timestamp) before making any payment requests. `Spreedly.initializeSDK()` alone is **NOT sufficient** - it only provides a basic initialization without the required credentials.

### Two-Step Initialization Pattern (Required)

The SDK uses a two-step initialization pattern:

**Step 1:** Initialize SDK at app launch (basic setup)  
**Step 2:** Configure with credentials before payment (MANDATORY)

### Step 1: Initialize SDK at App Launch

```swift
import SpreedlyCore
import SpreedlySecurity
import SpreedlyUI

// In your App delegate or SwiftUI App
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    // Step 1: Basic initialization (creates SDK instance)
    // Note: This alone is NOT sufficient - you MUST call setup(config:) with credentials
    Spreedly.initializeSDK()

    return true
}
```

### Step 2: Configure with Credentials (MANDATORY)

**You MUST call `Spreedly.setup(config:)` with the following required parameters before making any payment requests:**
- `environmentKey` (required)
- `forterSiteId` (required for 3DS support)
- `certificateToken` (required for security)
- `nonce` (required for security)
- `signature` (required for security)
- `timestamp` (required for security)

```swift
class SpreedlyConfigManager {
    static let shared = SpreedlyConfigManager()
    
    private let environmentKey = "your_environment_key"  // REQUIRED
    private let forterSiteId = "your_forter_site_id"      // REQUIRED for 3DS support
    private let serverURL = "https://your-backend.com/api/v1/auth/params"
    
    private init() {
        // Step 1: Basic initialization (already called in app launch)
        // This creates the SDK instance but does NOT provide credentials
    }
    
    // Step 2: MANDATORY - Configure with credentials before payment
    // This MUST be called before any payment operations
    func configureSpreedly() async {
        do {
            let signatureParams = try await generateSignature()

            // MANDATORY: Setup with all required credentials
            Spreedly.setup(config: SpreedlyConfig(
                environmentKey: environmentKey,           // REQUIRED
                forterSiteId: forterSiteId,              // REQUIRED for 3DS
                certificateToken: signatureParams.certificateToken,  // REQUIRED
                nonce: signatureParams.nonce,            // REQUIRED
                signature: signatureParams.signature,    // REQUIRED
                timestamp: String(signatureParams.timestamp)  // REQUIRED
            ))
        } catch {
            print("Failed to configure Spreedly: \(error)")
            // Handle error - SDK cannot process payments without proper configuration
        }
    }
}

// Signature generation (implement based on your security requirements)
func generateSignature() async throws -> SignatureParameters {
    // Your signature generation logic here
    // This could be server-side or client-side depending on your setup
}
```

## Express Checkout Integration

The Express Checkout provides a complete, pre-built payment form that handles all the complexity for you.

> ⚠️ **IMPORTANT:** Always apply `.screenPrevention()` modifier to payment forms to protect sensitive payment information from being captured in app switcher screenshots.

### Basic Implementation

```swift
import SwiftUI
import SpreedlyUI

struct CheckoutView: View {
    @State private var showCheckout = false
    @State private var checkoutResult: CheckoutResult?

    var body: some View {
        VStack {
            Button("Show Checkout") {
                showCheckout = true
            }

            if let result = checkoutResult {
                VStack {
                    Text("Payment Successful!")
                        .foregroundColor(.green)

                    if let token = result.paymentMethodToken {
                        Text("Payment Method Token: \(token)")
                    }
                }
            }
        }
        .sheet(isPresented: $showCheckout) {
            CardFormDropIn(
                onProcessingResult: { result in
                    if result.isSuccess {
                        checkoutResult = result.paymentResult
                        showCheckout = false
                    } else if result.isValidationFailed {
                        print("Validation error: \(result.errorMessage ?? "Unknown error")")
                    } else {
                        print("Checkout error: \(result.errorMessage ?? "Unknown error")")
                        showCheckout = false
                    }
                }
            )
        }
    }
}
```

### Callback System

The `CardFormDropIn` component uses a modern callback system to handle payment processing:

> ⚠️ **CRITICAL:** Subscribe to payment results **BEFORE** presenting the form. If you subscribe after presenting, you may miss the result callback.
>
> **Correct Order:**
> 1. Subscribe in `.onAppear` or before showing form
> 2. Then present the form
> 3. Handle results in both callback and subscription

#### Callback API

```swift
struct CheckoutView: View {
    @State private var showCheckout = false
    @State private var isLoading = false
    @State private var cancellable: AnyCancellable?
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Processing payment...")
            }
            
            Button("Show Checkout") {
                showCheckout = true
            }
        }
        .sheet(isPresented: $showCheckout) {
            CardFormDropIn(
                onProcessingResult: { result in
                    if result.isProcessing {
                        // Payment request started - show loading
                        isLoading = true
                    } else if result.isSuccess {
                        // Payment was successful
                        let paymentResult = result.paymentResult
                        isLoading = false
                        print("Payment successful")
                        // Use paymentResult?.token for your payment processing
                    } else if result.isValidationFailed {
                        // Validation failed - hide loading, show error
                        isLoading = false
                        print("Validation failed: \(result.errorMessage ?? "Unknown error")")
                    } else {
                        // Payment failed - hide loading, show error
                        isLoading = false
                        print("Payment failed: \(result.errorMessage ?? "Unknown error")")
                    }
                }
            )
            .screenPrevention()  // Required: Protect sensitive payment data
        }
        .onAppear {
            // Subscribe BEFORE presenting form
            cancellable = Spreedly.shared().subscribeToPaymentResults { result in
                if result.isSuccess {
                    print("Payment successful via subscription")
                    // Handle success
                }
            }
        }
        .onDisappear {
            cancellable?.cancel()  // Clean up subscription
        }
    }
}
```

#### Migration from Old API

**Old API (Deprecated):**

```swift
CardFormDropIn(
    onSubmit: { result in
        // Handle submission
    }
)
```

**Current API:**

```swift
CardFormDropIn(
    onProcessingResult: { result in
        if result.isSuccess {
            // Handle successful payment
            let paymentResult = result.paymentResult
        } else if result.isValidationFailed {
            // Handle validation errors
            print("Validation failed: \(result.errorMessage ?? "Unknown error")")
        } else {
            // Handle other errors
            print("Payment failed: \(result.errorMessage ?? "Unknown error")")
        }
    }
)
```

### Advanced Configuration

```swift
// Set validation parameters before showing CardFormDropIn
Spreedly.shared().setParam(parameter: .allowBlankName, value: false)
Spreedly.shared().setParam(parameter: .allowExpiredDate, value: false)
Spreedly.shared().setParam(parameter: .allowBlankDate, value: false)

CardFormDropIn(
    // Customize form fields
    otherFields: [
        FormField(id: "addressLine1", title: "Address", type: .addressLine1, isRequired: true),
        FormField(id: "city", title: "City", type: .city, isRequired: true),
        FormField(id: "state", title: "State", type: .state, isRequired: true),
        FormField(id: "zipCode", title: "ZIP Code", type: .zipCode, isRequired: true)
    ],

    // Configuration options
    yearFormat: .fourDigit,

    // Callbacks
    onProcessingResult: { result in
        if result.isSuccess {
            handleSuccessfulPayment(result.paymentResult)
        }
    },
    // All errors are handled through onProcessingResult
    // Check result.isValidationFailed or result.errorMessage for error details
)
```

### Validation Parameters

The SDK provides three validation parameters that control how payment method fields are validated:

- **`allowBlankName`** (default: `false`): When set to `true`, allows the cardholder name field to be empty. When `false`, the name field is required.

- **`allowExpiredDate`** (default: `false`): When set to `true`, allows payment methods with expiration dates in the past. When `false`, expired dates are rejected.

- **`allowBlankDate`** (default: `false`): When set to `true`, allows the expiration month and year fields to be empty, making the expiration date optional. When `false`, both month and year are required.

**Note:** These parameters are stored on `Spreedly.shared()` and apply globally across screens. Set them before showing a form, and reset to defaults (`false`) when you leave a flow if you don't want the values to carry over to other screens. They can also be set when creating payment methods via `createCreditCard()` or when recaching payment methods via `recachePaymentMethod()`. For recache operations, all three parameters default to `false` and are always sent to the API.

### Save Card for Future Payments

The `CardFormDropIn` component includes a built-in checkbox that allows users to indicate whether they want to save their card for future payments. This feature is automatically included in the form and appears after the CVC field.

**How It Works:**

1. A checkbox labeled "Save card for future payments" appears automatically in `CardFormDropIn`
2. Users can check or uncheck the box to indicate their preference
3. The `shouldRetain` value is included in the `PaymentResult` for successful payments
4. Use this value to determine whether to save the payment method token for future use

**Accessing shouldRetain:**

```swift
let cancellable = Spreedly.shared().subscribeToPaymentResults { paymentResult in
    if paymentResult.isSuccess {
        if paymentResult.shouldRetain {
            // Merchant can save payment method token for future use
            // e.g., store token securely, send to backend, update user's saved payment methods
        } else {
            // Merchant can use token for this transaction only
            // e.g., process one-time payment, don't store token
        }
    }
}
```

**Complete Example:**

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
                VStack {
                    Text("Payment Successful!")
                        .foregroundColor(.green)
                    
                    if let token = result.token {
                        Text("Payment Token: \(token)")
                    }
                    
                    // Display whether user wants to save card
                    if result.shouldRetain {
                        Text("Card will be saved for future payments")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .sheet(isPresented: $showCheckout) {
            CardFormDropIn(
                onProcessingResult: { result in
                    if result.isSuccess {
                        showCheckout = false
                    }
                }
            )
        }
        .onAppear {
            // Subscribe to payment results
            cancellable = Spreedly.shared().subscribeToPaymentResults { result in
                paymentResult = result
                
                if result.isSuccess {
                    if result.shouldRetain {
                        // Merchant can save payment method token for future use
                        // e.g., store token securely, send to backend
                    }
                }
            }
        }
        .onDisappear {
            cancellable?.cancel()
            cancellable = nil
        }
    }
    
    private func savePaymentMethodForFutureUse(token: String) {
        // Your implementation to save the token
        // This could involve:
        // - Storing token securely (e.g., Keychain)
        // - Sending token to your backend
        // - Updating user's saved payment methods
        print("Saving payment method token")
    }
}
```

**Objective-C Usage:**

```objc
// Subscribe to payment results
[Spreedly.shared setPaymentDelegate:self];

// In delegate method
- (void)paymentDidComplete:(PaymentResult *)result {
    if (result.isSuccess) {
        if (result.shouldRetain) {
            // Merchant can save payment method token for future use
            // e.g., store token securely, send to backend, update user's saved payment methods
        } else {
            // Merchant can use token for this transaction only
            // e.g., process one-time payment, don't store token
        }
    }
}
```

## Individual Field Integration

For more control over the payment form, use individual `SPLTextField` components. The new architecture uses a single `SPLTextField` component for all field types.

### Basic Form with Individual Fields

```swift
import SwiftUI
import SpreedlyUI

struct CustomPaymentForm: View {
    @State private var cardNumberValid = false
    @State private var expirationMonthValid = false
    @State private var expirationYearValid = false
    @State private var cvcValid = false
    @State private var firstNameValid = false
    @State private var lastNameValid = false
    @State private var isFormValid = false
    @State private var focusedFieldType: FormFieldType?

    // Define field order for keyboard navigation
    private var fieldOrder: [FormFieldType] {
        return [.firstName, .lastName, .cardNumber, .expirationMonth, .expirationYear, .cvc]
    }

    var body: some View {
        VStack(spacing: 20) {
            // Name Fields
            HStack(spacing: 16) {
                SPLTextField(
                    type: .firstName,
                    title: "First Name",
                    isRequired: true,
                    keyboardType: .default,
                    textContentType: .givenName,
                    onValidationChange: { isValid in
                        firstNameValid = isValid
                        updateFormValidity()
                    },
                    onSubmit: {
                        handleFieldSubmit(for: .firstName)
                    },
                    submitLabel: getSubmitLabel(for: .firstName),
                    shouldFocus: focusedFieldType == .firstName,
                    onFocus: {
                        focusedFieldType = .firstName
                    }
                )

                SPLTextField(
                    type: .lastName,
                    title: "Last Name",
                    isRequired: true,
                    keyboardType: .default,
                    textContentType: .familyName,
                    onValidationChange: { isValid in
                        lastNameValid = isValid
                        updateFormValidity()
                    },
                    onSubmit: {
                        handleFieldSubmit(for: .lastName)
                    },
                    submitLabel: getSubmitLabel(for: .lastName),
                    shouldFocus: focusedFieldType == .lastName,
                    onFocus: {
                        focusedFieldType = .lastName
                    }
                )
            }

            // Card Number Field
            SPLTextField(
                type: .cardNumber,
                title: "Card Number",
                isRequired: true,
                keyboardType: .numberPad,
                textContentType: .creditCardNumber,
                onValidationChange: { isValid in
                    cardNumberValid = isValid
                    updateFormValidity()
                },
                onSubmit: {
                    handleFieldSubmit(for: .cardNumber)
                },
                submitLabel: getSubmitLabel(for: .cardNumber),
                shouldFocus: focusedFieldType == .cardNumber,
                onFocus: {
                    focusedFieldType = .cardNumber
                }
            )

            // Expiration Fields (Month and Year)
            HStack(spacing: 16) {
                SPLTextField(
                    type: .expirationMonth,
                    title: "Month",
                    isRequired: true,
                    keyboardType: .numberPad,
                    onValidationChange: { isValid in
                        expirationMonthValid = isValid
                        updateFormValidity()
                    },
                    onSubmit: {
                        handleFieldSubmit(for: .expirationMonth)
                    },
                    submitLabel: getSubmitLabel(for: .expirationMonth),
                    shouldFocus: focusedFieldType == .expirationMonth,
                    onFocus: {
                        focusedFieldType = .expirationMonth
                    }
                )

                SPLTextField(
                    type: .expirationYear,
                    title: "Year",
                    isRequired: true,
                    keyboardType: .numberPad,
                    onValidationChange: { isValid in
                        expirationYearValid = isValid
                        updateFormValidity()
                    },
                    onSubmit: {
                        handleFieldSubmit(for: .expirationYear)
                    },
                    submitLabel: getSubmitLabel(for: .expirationYear),
                    shouldFocus: focusedFieldType == .expirationYear,
                    onFocus: {
                        focusedFieldType = .expirationYear
                    }
                )
            }

            // CVC Field
            SPLTextField(
                type: .cvc,
                title: "Security Code",
                isRequired: true,
                keyboardType: .numberPad,
                textContentType: .creditCardSecurityCode,
                onValidationChange: { isValid in
                    cvcValid = isValid
                    updateFormValidity()
                },
                onSubmit: {
                    handleFieldSubmit(for: .cvc)
                },
                submitLabel: getSubmitLabel(for: .cvc),
                shouldFocus: focusedFieldType == .cvc,
                onFocus: {
                    focusedFieldType = .cvc
                }
            )

            // Submit Button
            Button("Pay Now") {
                submitPayment()
            }
            .disabled(!isFormValid)
        }
        .padding()
        .onAppear {
            // Set initial focus to first field
            focusedFieldType = fieldOrder.first
        }
    }

    private func updateFormValidity() {
        isFormValid = cardNumberValid &&
                     expirationMonthValid &&
                     expirationYearValid &&
                     cvcValid &&
                     firstNameValid &&
                     lastNameValid
    }

    private func getSubmitLabel(for fieldType: FormFieldType) -> SpreedlySubmitLabel {
        guard let currentIndex = fieldOrder.firstIndex(of: fieldType) else {
            return .done
        }
        
        let isLastField = currentIndex == fieldOrder.count - 1
        return isLastField ? .done : .next
    }

    private func handleFieldSubmit(for fieldType: FormFieldType) {
        guard let currentIndex = fieldOrder.firstIndex(of: fieldType) else { return }
        
        let isLastField = currentIndex == fieldOrder.count - 1
        
        if isLastField {
            // Last field - submit the form
            if isFormValid {
                submitPayment()
            }
        } else {
            // Move to next field
            let nextIndex = currentIndex + 1
            if nextIndex < fieldOrder.count {
                focusedFieldType = fieldOrder[nextIndex]
            }
        }
    }

    private func submitPayment() {
        // Handle payment submission
        print("Submitting payment...")
    }
}
```

### Form Validation

```swift
// Real-time validation feedback with SPLTextField
SPLTextField(
    type: .cardNumber,
    title: "Card Number",
    isRequired: true,
    onValidationChange: { isValid in
        // Update UI based on validation state
        cardNumberValid = isValid
    }
)
```

### Keyboard Navigation and Focus Management

The `SPLTextField` component now supports advanced keyboard navigation and focus management with the following new parameters:

#### New Parameters

- **`keyboardType`**: Specifies the keyboard type for the field (e.g., `.numberPad`, `.default`)
- **`textContentType`**: Provides hints to the system for autofill and keyboard optimization
- **`onSubmit`**: Callback triggered when the user presses the return/submit key
- **`submitLabel`**: Controls the text displayed on the keyboard's return key (e.g., "Next", "Done")
- **`shouldFocus`**: Controls whether the field should automatically receive focus
- **`onFocus`**: Callback triggered when the field gains focus (when user taps into the field)

#### Focus Management with `onFocus`

The `onFocus` callback is essential for implementing proper focus management in forms. It's triggered when a user taps into a field, allowing you to track which field is currently focused and implement smooth field-to-field navigation.

**Basic Usage:**
```swift
@State private var focusedFieldType: FormFieldType?

SPLTextField(
    type: .cardNumber,
    title: "Card Number",
    onFocus: {
        focusedFieldType = .cardNumber
    },
    shouldFocus: focusedFieldType == .cardNumber
)
```

**Complete Focus Management Example:**
```swift
struct PaymentForm: View {
    @State private var focusedFieldType: FormFieldType?
    
    private let fieldOrder: [FormFieldType] = [.firstName, .lastName, .cardNumber, .cvc]
    
    var body: some View {
        VStack {
            SPLTextField(
                type: .firstName,
                title: "First Name",
                onFocus: { focusedFieldType = .firstName },
                shouldFocus: focusedFieldType == .firstName,
                onSubmit: { moveToNextField() },
                submitLabel: .next
            )
            
            SPLTextField(
                type: .lastName,
                title: "Last Name",
                onFocus: { focusedFieldType = .lastName },
                shouldFocus: focusedFieldType == .lastName,
                onSubmit: { moveToNextField() },
                submitLabel: .next
            )
            
            SPLTextField(
                type: .cardNumber,
                title: "Card Number",
                onFocus: { focusedFieldType = .cardNumber },
                shouldFocus: focusedFieldType == .cardNumber,
                onSubmit: { moveToNextField() },
                submitLabel: .next
            )
            
            SPLTextField(
                type: .cvc,
                title: "Security Code",
                onFocus: { focusedFieldType = .cvc },
                shouldFocus: focusedFieldType == .cvc,
                onSubmit: { submitForm() },
                submitLabel: .done
            )
        }
    }
    
    private func moveToNextField() {
        guard let currentIndex = fieldOrder.firstIndex(of: focusedFieldType ?? .firstName) else { return }
        let nextIndex = currentIndex + 1
        if nextIndex < fieldOrder.count {
            focusedFieldType = fieldOrder[nextIndex]
        }
    }
    
    private func submitForm() {
        // Handle form submission
    }
}
```

#### Submit Label Options

The `SpreedlySubmitLabel` enum provides the following options:

```swift
public enum SpreedlySubmitLabel: Int {
    case `return` = 0    // Standard return key
    case done = 1        // "Done" button
    case go = 2          // "Go" button
    case search = 3      // "Search" button
    case send = 4        // "Send" button
    case next = 5        // "Next" button (recommended for form navigation)
    case join = 6        // "Join" button
    case route = 7       // "Route" button
    case `continue` = 8  // "Continue" button
}
```

#### Basic Keyboard Navigation Example

```swift
struct SimpleForm: View {
    @State private var focusedField: FormFieldType? = .firstName
    
    var body: some View {
        VStack {
            SPLTextField(
                type: .firstName,
                title: "First Name",
                keyboardType: .default,
                textContentType: .givenName,
                onSubmit: {
                    focusedField = .lastName
                },
                submitLabel: .next,
                shouldFocus: focusedField == .firstName
            )
            
            SPLTextField(
                type: .lastName,
                title: "Last Name",
                keyboardType: .default,
                textContentType: .familyName,
                onSubmit: {
                    focusedField = .cardNumber
                },
                submitLabel: .next,
                shouldFocus: focusedField == .lastName
            )
            
            SPLTextField(
                type: .cardNumber,
                title: "Card Number",
                keyboardType: .numberPad,
                textContentType: .creditCardNumber,
                onSubmit: {
                    // Submit form or move to next section
                    submitForm()
                },
                submitLabel: .done,
                shouldFocus: focusedField == .cardNumber
            )
        }
    }
    
    private func submitForm() {
        // Handle form submission
    }
}
```

#### Advanced Focus Management

For more complex forms, you can implement sophisticated focus management:

```swift
struct AdvancedForm: View {
    @State private var focusedFieldType: FormFieldType?
    @State private var formData: [FormFieldType: String] = [:]
    
    private let fieldOrder: [FormFieldType] = [
        .firstName, .lastName, .cardNumber, 
        .expirationMonth, .expirationYear, .cvc
    ]
    
    var body: some View {
        VStack {
            ForEach(fieldOrder, id: \.self) { fieldType in
                SPLTextField(
                    type: fieldType,
                    title: getFieldTitle(for: fieldType),
                    isRequired: true,
                    keyboardType: getKeyboardType(for: fieldType),
                    textContentType: getTextContentType(for: fieldType),
                    onValidationChange: { isValid in
                        updateFieldValidation(fieldType, isValid: isValid)
                    },
                    onSubmit: {
                        handleFieldSubmit(for: fieldType)
                    },
                    submitLabel: getSubmitLabel(for: fieldType),
                    shouldFocus: focusedFieldType == fieldType
                )
            }
        }
        .onAppear {
            focusedFieldType = fieldOrder.first
        }
    }
    
    private func getFieldTitle(for fieldType: FormFieldType) -> String {
        switch fieldType {
        case .firstName: return "First Name"
        case .lastName: return "Last Name"
        case .cardNumber: return "Card Number"
        case .expirationMonth: return "Month"
        case .expirationYear: return "Year"
        case .cvc: return "Security Code"
        default: return ""
        }
    }
    
    private func getKeyboardType(for fieldType: FormFieldType) -> UIKeyboardType {
        switch fieldType {
        case .cardNumber, .expirationMonth, .expirationYear, .cvc:
            return .numberPad
        default:
            return .default
        }
    }
    
    private func getTextContentType(for fieldType: FormFieldType) -> UITextContentType? {
        switch fieldType {
        case .firstName: return .givenName
        case .lastName: return .familyName
        case .cardNumber: return .creditCardNumber
        case .cvc: return .creditCardSecurityCode
        default: return nil
        }
    }
    
    private func getSubmitLabel(for fieldType: FormFieldType) -> SpreedlySubmitLabel {
        guard let currentIndex = fieldOrder.firstIndex(of: fieldType) else {
            return .done
        }
        
        let isLastField = currentIndex == fieldOrder.count - 1
        return isLastField ? .done : .next
    }
    
    private func handleFieldSubmit(for fieldType: FormFieldType) {
        guard let currentIndex = fieldOrder.firstIndex(of: fieldType) else { return }
        
        let isLastField = currentIndex == fieldOrder.count - 1
        
        if isLastField {
            // Last field - submit the form
            submitForm()
        } else {
            // Move to next field
            let nextIndex = currentIndex + 1
            if nextIndex < fieldOrder.count {
                focusedFieldType = fieldOrder[nextIndex]
            }
        }
    }
    
    private func updateFieldValidation(_ fieldType: FormFieldType, isValid: Bool) {
        // Update validation state
    }
    
    private func submitForm() {
        // Handle form submission
    }
}
```

### Migration from Old Components

If you were using the old individual field components, here's how to migrate to the new unified `SPLTextField`:

**Old Components (Deprecated):**

```swift
// These components no longer exist
SPLCreditCardNumber(title: "Card Number", isRequired: true)
SPLExpirationDate(title: "Expiration", isRequired: true)
SPLFirstName(title: "First Name", isRequired: true)
SPLLastName(title: "Last Name", isRequired: true)
SPLCVC(title: "Security Code", isRequired: true)
```

**New Unified Approach:**

```swift
// Use SPLTextField with type parameter and new keyboard navigation features
SPLTextField(
    type: .cardNumber, 
    title: "Card Number", 
    isRequired: true,
    keyboardType: .numberPad,
    textContentType: .creditCardNumber,
    onSubmit: { /* handle submit */ },
    submitLabel: .next,
    shouldFocus: false,
    onFocus: { /* handle focus */ }
)

SPLTextField(
    type: .expirationMonth, 
    title: "Month", 
    isRequired: true,
    keyboardType: .numberPad,
    onSubmit: { /* handle submit */ },
    submitLabel: .next,
    onFocus: { /* handle focus */ }
)

SPLTextField(
    type: .expirationYear, 
    title: "Year", 
    isRequired: true,
    keyboardType: .numberPad,
    onSubmit: { /* handle submit */ },
    submitLabel: .next,
    onFocus: { /* handle focus */ }
)

SPLTextField(
    type: .firstName, 
    title: "First Name", 
    isRequired: true,
    keyboardType: .default,
    textContentType: .givenName,
    onSubmit: { /* handle submit */ },
    submitLabel: .next,
    onFocus: { /* handle focus */ }
)

SPLTextField(
    type: .lastName, 
    title: "Last Name", 
    isRequired: true,
    keyboardType: .default,
    textContentType: .familyName,
    onSubmit: { /* handle submit */ },
    submitLabel: .next,
    onFocus: { /* handle focus */ }
)

SPLTextField(
    type: .cvc, 
    title: "Security Code", 
    isRequired: true,
    keyboardType: .numberPad,
    textContentType: .creditCardSecurityCode,
    onSubmit: { /* handle submit */ },
    submitLabel: .done,
    onFocus: { /* handle focus */ }
)
```

**Key Features:**

- **Unified Component**: One component (`SPLTextField`) handles all field types
- **Consistent Behavior**: Same validation and theming across all fields
- **Global Theme Support**: Automatic theme application via `SpreedlyThemeManager`
- **Advanced Keyboard Navigation**: Built-in support for focus management and keyboard flow
- **Enhanced User Experience**: Automatic keyboard types and text content types for better UX
- **Flexible Submit Handling**: Customizable submit labels and callback handling
- **Focus Management**: Built-in `onFocus` callback for tracking field focus state and implementing smooth navigation

## Custom Form Integration

For complete control, build your own form using the headless components.

**Note:** Unlike `CardFormDropIn`, custom forms don't include a built-in "Save card for future payments" checkbox. If you want to offer this feature, you'll need to implement your own checkbox and track the user's preference. Then use that preference to determine whether to save the payment method token for future use.

### Custom Form Example

```swift
struct CustomPaymentForm: View {
    @State private var cardHolderName = ""
    @State private var cardNumberValid = false
    @State private var expirationMonthValid = false
    @State private var expirationYearValid = false
    @State private var cvcValid = false
    @State private var firstNameValid = false
    @State private var lastNameValid = false

    var body: some View {
        VStack(spacing: 16) {
            // Custom card holder name field
            VStack(alignment: .leading) {
                Text("Card Holder Name")
                    .font(.headline)
                TextField("Enter full name", text: $cardHolderName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            // Card number with validation
            SPLTextField(
                type: .cardNumber,
                title: "Card Number",
                isRequired: true,
                onValidationChange: { isValid in
                    cardNumberValid = isValid
                }
            )

            // Expiration fields
            HStack {
                SPLTextField(
                    type: .expirationMonth,
                    title: "Month",
                    isRequired: true,
                    onValidationChange: { isValid in
                        expirationMonthValid = isValid
                    }
                )

                SPLTextField(
                    type: .expirationYear,
                    title: "Year",
                    isRequired: true,
                    onValidationChange: { isValid in
                        expirationYearValid = isValid
                    }
                )

                SPLTextField(
                    type: .cvc,
                    title: "CVC",
                    isRequired: true,
                    onValidationChange: { isValid in
                        cvcValid = isValid
                    }
                )
            }

            // Name fields
            HStack(spacing: 16) {
                SPLTextField(
                    type: .firstName,
                    title: "First Name",
                    isRequired: true,
                    onValidationChange: { isValid in
                        firstNameValid = isValid
                    }
                )

                SPLTextField(
                    type: .lastName,
                    title: "Last Name",
                    isRequired: true,
                    onValidationChange: { isValid in
                        lastNameValid = isValid
                    }
                )
            }

            Button("Submit Payment") {
                processPayment()
            }
            .disabled(!isFormValid)
        }
        .padding()
    }

    private var isFormValid: Bool {
        return !cardHolderName.isEmpty &&
               cardNumberValid &&
               expirationMonthValid &&
               expirationYearValid &&
               cvcValid &&
               firstNameValid &&
               lastNameValid
    }

    private func processPayment() {
        // Implement payment processing
        let processingResult = Spreedly.shared().createCreditCard(
            additionalFields: [:],
            metadata: [:]
        )
        
        // Subscribe to payment results
        let cancellable = Spreedly.shared().subscribeToPaymentResults { result in
            if result.isSuccess {
                // Use result.token for your payment processing
                // If you implemented a "save card" checkbox, check your local state
                // and save the token accordingly
            }
        }
    }
}
```

### Save Card Option in Custom Forms

If you want to offer a "Save card for future payments" option in your custom form, implement it like this:

```swift
struct CustomPaymentForm: View {
    @State private var shouldRetain = false  // Track user's preference
    // ... other state variables
    
    var body: some View {
        VStack(spacing: 16) {
            // ... your form fields
            
            // Add your own "Save card" checkbox
            Toggle("Save card for future payments", isOn: $shouldRetain)
            
            Button("Submit Payment") {
                processPayment()
            }
        }
        .onAppear {
            cancellable = Spreedly.shared().subscribeToPaymentResults { result in
                if result.isSuccess {
                    if shouldRetain, let token = result.token {
                        // Save payment method token for future use
                        // e.g., store token securely, send to backend
                        savePaymentMethodForFutureUse(token: token)
                    }
                }
            }
        }
    }
    
    private func savePaymentMethodForFutureUse(token: String) {
        // Your implementation to save the token
        // This could involve:
        // - Storing token securely (e.g., Keychain)
        // - Sending token to your backend
        // - Updating user's saved payment methods
    }
}
```

**Note:** The `shouldRetain` property in `PaymentResult` is only set automatically by `CardFormDropIn`. For custom forms, you need to track the user's preference yourself and use it to decide whether to save the payment method token.

## Additional Fields Integration

The SDK now supports passing additional field values directly to the `createCreditCard` method, providing more flexibility for developers who want to handle their own form validation and field management.

### Using Additional Fields

```swift
import SpreedlyCore

// Create payment method with additional fields
let processingResult = Spreedly.shared().createCreditCard(
    additionalFields: [
        .firstName: "John",
        .lastName: "Doe",
        .addressLine1: "123 Main St",
        .city: "Anytown",
        .state: "CA",
        .zipCode: "12345",
        .country: "US",
        .phoneNumber: "+1234567890",
        .email: "john.doe@example.com"
    ],
    metadata: ["orderId": "12345"],
    allowBlankName: false,
    allowExpiredDate: false,
    allowBlankDate: false
)

// Listen for payment results
let cancellable = Spreedly.shared().subscribeToPaymentResults { paymentResult in
    if paymentResult.isSuccess {
        print("Payment successful")
        // Use paymentResult.token for your payment processing
        
        // Note: shouldRetain is only available from CardFormDropIn
        // For custom forms, track your own "save card" preference
    } else if paymentResult.isFailure {
        print("Payment failed: \(paymentResult.failureDetails?.getDescription() ?? "Unknown error")")
    }
}
```

### Available Additional Fields

The `AdditionalField` enum provides type-safe access to all supported fields:

#### Billing Fields
- `.firstName` - First name
- `.lastName` - Last name  
- `.fullName` - Full name (alternative to firstName/lastName)
- `.addressLine1` - Primary address
- `.addressLine2` - Secondary address
- `.city` - City
- `.state` - State/Province
- `.zipCode` - Postal/ZIP code
- `.country` - Country code
- `.phoneNumber` - Phone number
- `.email` - Email address

#### Shipping Fields
- `.shippingAddress1` - Shipping address line 1
- `.shippingAddress2` - Shipping address line 2
- `.shippingCity` - Shipping city
- `.shippingState` - Shipping state/province
- `.shippingZip` - Shipping postal/ZIP code
- `.shippingCountry` - Shipping country code
- `.shippingPhoneNumber` - Shipping phone number

### Field Fallback Logic

The SDK implements intelligent fallback logic:

1. **SDK Fields First**: If a field is available in the SDK's secure fields, it uses that value
2. **Additional Fields Fallback**: If the SDK field is empty, it uses the value from additional fields
3. **Empty String Default**: If neither source has a value, it uses an empty string

```swift
// Example: If firstName is empty in SDK fields but provided in additional fields
let processingResult = Spreedly.shared().createCreditCard(
    additionalFields: [
        .firstName: "John",  // This will be used if SDK firstName is empty
        .lastName: "Doe"
    ]
)
```

### Additional Field Validation

The SDK automatically validates additional fields when you pass them to `createCreditCard`. If validation fails, the `PaymentProcessingResult` will include the invalid fields in `invalidAdditionalFields`.

```swift
let processingResult = Spreedly.shared().createCreditCard(
    additionalFields: [
        .email: "invalid-email",  // Invalid email format
        .firstName: "",           // Empty required field
        .addressLine1: "123 Main St"
    ]
)

if processingResult.isValidationFailed {
    // Check for invalid SDK form fields
    if !processingResult.invalidFields.isEmpty {
        print("Invalid SDK fields: \(processingResult.invalidFields)")
    }
    
    // Check for invalid additional fields
    if !processingResult.invalidAdditionalFields.isEmpty {
        print("Invalid additional fields: \(processingResult.invalidAdditionalFields)")
        
        // Handle each invalid additional field
        for field in processingResult.invalidAdditionalFields {
            switch field {
            case .email:
                showError("Please enter a valid email address")
            case .firstName:
                showError("First name is required")
            case .addressLine1:
                showError("Address is required")
            default:
                showError("\(field.fieldName) is invalid")
            }
        }
    }
}
```

#### Validation Methods

You can also check for specific invalid additional fields:

```swift
if processingResult.hasInvalidAdditionalField(.email) {
    // Email validation failed
    highlightEmailField()
}

if processingResult.hasInvalidAdditionalField(.firstName) {
    // First name validation failed
    highlightFirstNameField()
}
```

### Objective-C Integration

For Objective-C projects, use the `createCreditCardObjC` method with string-based keys:

```objc
// Objective-C implementation
NSDictionary *additionalFields = @{
    @"firstName": @"John",
    @"lastName": @"Doe",
    @"address1": @"123 Main St",
    @"city": @"Anytown",
    @"state": @"CA",
    @"zip": @"12345",
    @"country": @"US",
    @"phone_number": @"+1234567890",
    @"email": @"john.doe@example.com"
};

NSDictionary *metadata = @{@"orderId": @"12345"};

PaymentProcessingResult *processingResult = [Spreedly.shared 
    createCreditCardObjCWithAdditionalFields:additionalFields 
    metadata:metadata];

// Handle validation errors
if (processingResult.isValidationFailed) {
    // Check for invalid SDK form fields
    if (processingResult.invalidFields.count > 0) {
        NSLog(@"Invalid SDK fields: %@", processingResult.invalidFields);
    }
    
    // Check for invalid additional fields
    if (processingResult.invalidAdditionalFields.count > 0) {
        NSLog(@"Invalid additional fields: %@", processingResult.invalidAdditionalFields);
        
        // Handle each invalid additional field
        for (AdditionalField field in processingResult.invalidAdditionalFields) {
            if ([field isEqual:@(AdditionalFieldEmail)]) {
                [self showError:@"Please enter a valid email address"];
            } else if ([field isEqual:@(AdditionalFieldFirstName)]) {
                [self showError:@"First name is required"];
            }
        }
    }
}

// Set up delegate for payment results
Spreedly.shared.paymentDelegate = self;
```

### Complete Example with Additional Fields

```swift
struct PaymentWithAdditionalFields: View {
    @State private var additionalFields: [AdditionalField: String] = [:]
    @State private var paymentResult: PaymentResult?
    @State private var cancellable: AnyCancellable?

    var body: some View {
        VStack(spacing: 20) {
            // Only secure fields need SDK components
            SPLTextField(
                type: .cardNumber,
                title: "Card Number",
                isRequired: true,
                onValidationChange: { _ in }
            )
            
            SPLTextField(
                type: .expirationMonth,
                title: "Month",
                isRequired: true,
                onValidationChange: { _ in }
            )
            
            SPLTextField(
                type: .expirationYear,
                title: "Year",
                isRequired: true,
                onValidationChange: { _ in }
            )
            
            SPLTextField(
                type: .cvc,
                title: "Security Code",
                isRequired: true,
                onValidationChange: { _ in }
            )

            // Regular TextFields for additional fields
            VStack(spacing: 16) {
                TextField("First Name", text: Binding(
                    get: { additionalFields[.firstName] ?? "" },
                    set: { additionalFields[.firstName] = $0 }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Last Name", text: Binding(
                    get: { additionalFields[.lastName] ?? "" },
                    set: { additionalFields[.lastName] = $0 }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Address", text: Binding(
                    get: { additionalFields[.addressLine1] ?? "" },
                    set: { additionalFields[.addressLine1] = $0 }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack {
                    TextField("City", text: Binding(
                        get: { additionalFields[.city] ?? "" },
                        set: { additionalFields[.city] = $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("State", text: Binding(
                        get: { additionalFields[.state] ?? "" },
                        set: { additionalFields[.state] = $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("ZIP", text: Binding(
                        get: { additionalFields[.zipCode] ?? "" },
                        set: { additionalFields[.zipCode] = $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }

            Button("Process Payment") {
                processPayment()
            }
        }
        .padding()
        .onAppear {
            // Subscribe to payment results
            cancellable = Spreedly.shared().subscribeToPaymentResults { result in
                paymentResult = result
                if result.isSuccess {
                    print("Payment successful!")
                    // Use result.token for your payment processing
                    // If you want to offer "save card" option, implement your own checkbox
                    // and save the token based on user's preference
                }
            }
        }
        .onDisappear {
            cancellable?.cancel()
        }
    }

    private func processPayment() {
        let processingResult = Spreedly.shared().createCreditCard(
            additionalFields: additionalFields,
            metadata: ["source": "custom_form"]
        )
        
        if processingResult.isValidationFailed {
            // Handle validation errors for SDK form fields
            if !processingResult.invalidFields.isEmpty {
                print("Validation failed for SDK fields: \(processingResult.invalidFields)")
                for fieldType in processingResult.invalidFields {
                    // Highlight invalid SDK fields
                    highlightInvalidField(fieldType)
                }
            }
            
            // Handle validation errors for additional fields
            if !processingResult.invalidAdditionalFields.isEmpty {
                print("Validation failed for additional fields: \(processingResult.invalidAdditionalFields)")
                for additionalField in processingResult.invalidAdditionalFields {
                    // Highlight invalid additional fields
                    highlightInvalidAdditionalField(additionalField)
                }
            }
        }
    }
}
```

## CVV Recaching

CVV Recaching allows you to update the CVV (Card Verification Value) for existing saved payment methods. This is essential for PCI DSS compliance, as CVV values cannot be stored and must be re-entered by the customer for each transaction.

### Basic Implementation

The SDK provides `SpreedlyCVVRecachingView` component for SwiftUI integration. You can present the recaching UI as a sheet or dialog.

```swift
import SwiftUI
import SpreedlyUI
import SpreedlyCore
import Combine

struct SavedCardsView: View {
    @State private var showCVVRecaching = false
    @State private var selectedCard: SavedCard?
    @State private var paymentResult: PaymentResult?
    @State private var cancellable: AnyCancellable?
    
    struct SavedCard {
        let paymentMethodToken: String
        let lastFourDigits: String
        let cardType: String
        let cardBrand: String?
    }
    
    var body: some View {
        VStack {
            List(savedCards) { card in
                CardRow(card: card) {
                    selectedCard = card
                    showCVVRecaching = true
                }
            }
        }
        .sheet(isPresented: $showCVVRecaching) {
            if let card = selectedCard {
                SpreedlyCVVRecachingView(
                    config: RecacheConfig(
                        cardInfo: SavedCardInfo(
                            lastFourDigits: card.lastFourDigits,
                            cardType: card.cardType,
                            cardBrand: card.cardBrand
                        ),
                        presentationMode: .bottomSheet
                    ),
                    paymentMethodToken: card.paymentMethodToken,
                    allowBlankName: false,
                    allowExpiredDate: false,
                    allowBlankDate: false,
                    onProcessingResult: { result in
                        if result.isProcessing {
                            // Show loading indicator
                        } else if result.isValidationFailed {
                            // Handle validation errors
                        }
                    },
                    onDismiss: {
                        showCVVRecaching = false
                    }
                )
                .screenPrevention()
            }
        }
        .onAppear {
            cancellable = Spreedly.shared().subscribeToPaymentResults { result in
                paymentResult = result
                
                if result.isSuccess {
                    showCVVRecaching = false
                    print("CVV recached successfully")
                    // Use result.token for your payment processing
                } else if result.isFailure {
                    if let failureDetails = result.failureDetails {
                        print("Recaching failed: \(failureDetails.getDescription())")
                    }
                    showCVVRecaching = false
                }
            }
        }
        .onDisappear {
            cancellable?.cancel()
            cancellable = nil
        }
    }
}
```

### Payment Result Handling

Recaching uses the same payment result system as payment method creation. You can receive results via:

**1. Combine Publisher (Swift/SwiftUI)**

```swift
let cancellable = Spreedly.shared().subscribeToPaymentResults { result in
    if result.isSuccess {
        // Recaching successful
        print("Recaching successful")
        // Use result.token for your payment processing
    } else if result.isFailure {
        // Handle failure
        if let failureDetails = result.failureDetails {
            print("Error: \(failureDetails.getDescription())")
        }
    }
}
```

**2. Delegate Pattern (UIKit/Objective-C)**

```objc
// Set delegate
[Spreedly.shared setPaymentDelegate:self];

// Implement delegate method
- (void)paymentDidComplete:(PaymentResult *)result {
    if (result.isSuccess) {
        NSLog(@"Recaching successful");
        // Use result.token for your payment processing
    } else if (result.isFailure) {
        NSLog(@"Recaching failed: %@", [result.failureDetails getDescription]);
    }
}
```

**PaymentResult Properties:**

- `token: String?` - The payment method token (available for successful recaching)
- `paymentResponse: PaymentMethodResponse?` - Full payment method response
- `shouldRetain: Bool` - Always `false` for recaching operations (not applicable)

### Presentation Modes

The SDK supports two presentation modes via `ScreenPresentationMode` enum:

**1. Bottom Sheet (`.bottomSheet`)**

```swift
RecacheConfig(
    cardInfo: cardInfo,
    presentationMode: .bottomSheet
)
```

**2. Dialog (`.dialog`)**

For dialog mode, use `.crossDissolveFullScreenCover()` instead of `.sheet()`:

```swift
.crossDissolveFullScreenCover(
    isPresented: $showCVVRecaching
) {
    SpreedlyCVVRecachingView(
        config: RecacheConfig(
            cardInfo: cardInfo,
            presentationMode: .dialog
        ),
        paymentMethodToken: paymentMethodToken,
        allowBlankName: false,
        allowExpiredDate: false,
        allowBlankDate: false,
        onDismiss: {
            showCVVRecaching = false
        }
    )
    .screenPrevention()
}
```

#### Customization Options

**RecacheConfig Parameters:**

```swift
RecacheConfig(
    cardInfo: SavedCardInfo(
        lastFourDigits: "4242",        // Required: Last 4 digits
        cardType: "Visa",               // Required: Card type name
        cardBrand: "visa"                // Optional: Card brand identifier
    ),
    presentationMode: .bottomSheet,      // .bottomSheet or .dialog
    labelText: "CVV",                   // CVV field label (default: "CVV")
    placeholderText: "123",              // CVV placeholder (default: "123")
    buttonText: "Confirm",              // Submit button text (default: "Confirm")
    cancelButtonText: "Cancel"           // Cancel button text (default: "Cancel")
)
```

**Validation Parameters for Recaching:**

When using `SpreedlyCVVRecachingView`, you can also specify validation parameters:

```swift
SpreedlyCVVRecachingView(
    config: recacheConfig,
    paymentMethodToken: paymentMethodToken,
    allowBlankName: false,      // Allow blank name fields (default: false)
    allowExpiredDate: false,    // Allow expired dates (default: false)
    allowBlankDate: false,      // Allow blank expiration date (default: false)
    onProcessingResult: { result in
        // Handle result
    }
)
```

**Note:** For recache operations, all validation parameters default to `false` and are always sent to the API, even if not explicitly set.
```

#### Theme Customization

Apply custom themes to match your app's design:

```swift
let lightTheme = SpreedlyThemeManager.createCustomTheme(
    colors: SpreedlyColors(
        primary: Color.blue,
        background: Color.white,
        text: Color.black
    )
)

let darkTheme = SpreedlyThemeManager.createCustomTheme(
    colors: SpreedlyColors(
        primary: Color.cyan,
        background: Color.black,
        text: Color.white
    )
)

SpreedlyCVVRecachingView(
    config: recacheConfig,
    paymentMethodToken: paymentMethodToken,
    theme: lightTheme,
    darkTheme: darkTheme,
    allowBlankName: false,
    allowExpiredDate: false,
    allowBlankDate: false,
    onProcessingResult: { result in
        // Handle result
    },
    onDismiss: {
        // Called when Cancel button is tapped - merchant handles dismissal
        showCVVRecaching = false
    }
)
```

#### Complete SwiftUI Example

```swift
import SwiftUI
import SpreedlyUI
import SpreedlyCore
import Combine

struct RecachingExampleView: View {
    @State private var showCVVRecaching = false
    @State private var selectedCard: SavedCard?
    @State private var paymentResult: PaymentResult?
    @State private var cancellable: AnyCancellable?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    struct SavedCard: Identifiable {
        let id: String
        let paymentMethodToken: String
        let lastFourDigits: String
        let cardType: String
        let cardBrand: String?
    }
    
    let savedCards: [SavedCard] = [
        SavedCard(
            id: "1",
            paymentMethodToken: "token_123",
            lastFourDigits: "4242",
            cardType: "Visa",
            cardBrand: "visa"
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Processing...")
                }
                
                if let error = errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                }
                
                if let result = paymentResult, result.isSuccess {
                    Text("CVV Recached Successfully!")
                        .foregroundColor(.green)
                        .padding()
                }
                
                List(savedCards) { card in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(card.cardType)
                            Text("•••• \(card.lastFourDigits)")
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button("Update CVV") {
                            selectedCard = card
                            showCVVRecaching = true
                        }
                    }
                }
            }
            .navigationTitle("Saved Cards")
        }
        .sheet(isPresented: $showCVVRecaching) {
            if let card = selectedCard {
                SpreedlyCVVRecachingView(
                    config: RecacheConfig(
                        cardInfo: SavedCardInfo(
                            lastFourDigits: card.lastFourDigits,
                            cardType: card.cardType,
                            cardBrand: card.cardBrand
                        ),
                        presentationMode: .bottomSheet
                    ),
                    paymentMethodToken: card.paymentMethodToken,
                    allowBlankName: false,
                    allowExpiredDate: false,
                    allowBlankDate: false,
                    onProcessingResult: { result in
                        if result.isProcessing {
                            isLoading = true
                            errorMessage = nil
                        } else if result.isValidationFailed {
                            isLoading = false
                            errorMessage = "CVV validation failed"
                        }
                    },
                    onDismiss: {
                        // Called when Cancel button is tapped - merchant handles dismissal
                        showCVVRecaching = false
                    }
                )
                .screenPrevention()
            }
        }
        .onAppear {
            // Subscribe to payment results
            cancellable = Spreedly.shared().subscribeToPaymentResults { result in
                paymentResult = result
                isLoading = false
                
                if result.isSuccess {
                    showCVVRecaching = false
                    errorMessage = nil
                    print("Recaching successful: \(result.token ?? "N/A")")
                } else if result.isFailure {
                    if let failureDetails = result.failureDetails {
                        errorMessage = failureDetails.getDescription()
                    } else {
                        errorMessage = "Recaching failed"
                    }
                    showCVVRecaching = false
                }
            }
        }
        .onDisappear {
            cancellable?.cancel()
            cancellable = nil
        }
    }
}
```

### UIKit Integration

For UIKit-based apps, use `CVVRecachingViewController` which wraps the SwiftUI component:

```swift
import UIKit
import SpreedlyUI
import SpreedlyCore

class SavedCardsViewController: UIViewController {
    var selectedCard: SavedCard?
    
    @IBAction func updateCVVTapped(_ sender: UIButton) {
        guard let card = selectedCard else { return }
        
        // Generate signature for Spreedly configuration before showing recaching UI
        Task {
            let signatureGenerated = await SpreedlyConfigManager.shared.generateSignature()
            await MainActor.run {
                switch signatureGenerated {
                case .success(_):
                    // Create configuration
                    let config = RecacheConfig(
                        cardInfo: SavedCardInfo(
                            lastFourDigits: card.lastFourDigits,
                            cardType: card.cardType,
                            cardBrand: card.cardBrand
                        ),
                        presentationMode: .bottomSheet,
                        labelText: "CVV",
                        placeholderText: "123",
                        buttonText: "Confirm",
                        cancelButtonText: "Cancel"
                    )
                    
                    // Initialize view controller
                    let recachingVC = CVVRecachingViewController(
                        lastFourDigits: card.lastFourDigits,
                        cardType: card.cardType,
                        cardBrand: card.cardBrand,
                        paymentMethodToken: card.paymentMethodToken,
                        presentationMode: 0, // 0 = sheet, 1 = alert
                        labelText: "CVV",
                        placeholderText: "123",
                        buttonText: "Confirm",
                        cancelButtonText: "Cancel",
                        onProcessingResult: { result in
                            if result.isProcessing {
                                // Show loading indicator
                            } else if result.isValidationFailed {
                                // Handle validation errors
                            }
                        }
                    )
                    
                    // Set presentation style
                    recachingVC.modalPresentationStyle = .formSheet
                    
                    // Present view controller
                    self.present(recachingVC, animated: true)
                    
                case .failure(let error):
                    // Handle signature generation error
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Failed to generate signature: \(error.localizedDescription)",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
```

#### With Custom Themes (UIKit)

```swift
import UIKit
import SpreedlyUI
import SpreedlyCore

// Create theme configurations
let lightThemeConfig = SPLThemeConfig(
    primaryColor: .systemBlue,
    secondaryColor: .systemGray,
    backgroundColor: .white,
    borderColor: .systemGray4,
    borderFocusedColor: .systemBlue,
    textColor: .black,
    textSecondaryColor: .systemGray,
    errorColor: .systemRed,
    placeholderColor: nil,
    borderRadius: 8.0
)

let darkThemeConfig = SPLThemeConfig(
    primaryColor: .systemBlue,
    secondaryColor: .systemGray,
    backgroundColor: .black,
    borderColor: .systemGray2,
    borderFocusedColor: .systemBlue,
    textColor: .white,
    textSecondaryColor: .systemGray,
    errorColor: .systemRed,
    placeholderColor: nil,
    borderRadius: 8.0
)

// Generate signature before presenting (required for production)
Task {
    let signatureGenerated = await SpreedlyConfigManager.shared.generateSignature()
    await MainActor.run {
        if case .success = signatureGenerated {
            // Initialize with custom themes
            let recachingVC = CVVRecachingViewController(
                lastFourDigits: card.lastFourDigits,
                cardType: card.cardType,
                cardBrand: card.cardBrand,
                paymentMethodToken: card.paymentMethodToken,
                presentationMode: 0,
                labelText: "CVV",
                placeholderText: "123",
                buttonText: "Confirm",
                cancelButtonText: "Cancel",
                lightThemeConfig: lightThemeConfig,
                darkThemeConfig: darkThemeConfig,
                onProcessingResult: { result in
                    // Handle processing result
                }
            )
            
            present(recachingVC, animated: true)
        } else {
            // Handle signature generation error
            print("Failed to generate signature")
        }
    }
}
```

### Objective-C Integration

For Objective-C projects, use `CVVRecachingViewController` with Objective-C compatible initializers:

```objc
#import "SavedCardsViewController.h"
#import <SpreedlyUI/SpreedlyUI-Swift.h>
#import <SpreedlyCore/SpreedlyCore-Swift.h>

@interface SavedCardsViewController () <SpreedlyPaymentDelegate>
@property (nonatomic, strong) SavedCard *selectedCard;
@end

@implementation SavedCardsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set payment delegate to receive recaching results
    [Spreedly.shared setPaymentDelegate:self];
}

- (void)updateCVVTapped {
    if (!self.selectedCard) {
        return;
    }
    
    // Generate signature for Spreedly configuration before showing recaching UI
    [[SpreedlyConfigManager shared] generateSignatureWithCompletion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                // Create CVV Recaching view controller
                CVVRecachingViewController *recachingVC = [[CVVRecachingViewController alloc]
                    initWithLastFourDigits:self.selectedCard.lastFourDigits
                    cardType:self.selectedCard.cardType
                    cardBrand:self.selectedCard.cardBrand
                    paymentMethodToken:self.selectedCard.paymentMethodToken
                    presentationMode:0  // 0 = sheet, 1 = alert
                    labelText:@"CVV"
                    placeholderText:@"123"
                    buttonText:@"Confirm"
                    cancelButtonText:@"Cancel"
                    onProcessingResult:^(PaymentProcessingResult *result) {
                        // Called during recaching
                        // isValidationFailed = validation error
                        // isProcessing = request started
                        // Final success/failure comes via paymentDidComplete: delegate method
                        if (result.isValidationFailed) {
                            NSLog(@"CVV validation failed");
                        } else if (result.isProcessing) {
                            NSLog(@"Recaching in progress...");
                        }
                    }];
                
                // Set presentation style
                recachingVC.modalPresentationStyle = UIModalPresentationFormSheet;
                
                // Present view controller
                [self presentViewController:recachingVC animated:YES completion:nil];
            } else {
                // Handle signature generation error
                NSString *errorMessage = error ? error.localizedDescription : @"Failed to generate signature";
                UIAlertController *alert = [UIAlertController 
                    alertControllerWithTitle:@"Error" 
                    message:errorMessage 
                    preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
            }
        });
    }];
}

#pragma mark - SpreedlyPaymentDelegate

- (void)paymentDidComplete:(PaymentResult *)result {
    if (result.isSuccess) {
        // Recaching successful - token updated
        NSLog(@"CVV Recaching successful!");
        // Use result.token for your payment processing
        
        // Dismiss recaching view controller if still presented
        if (self.presentedViewController) {
            [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }
    } else if (result.isFailure) {
        // Handle failure
        if (result.failureDetails) {
            NSLog(@"Recaching failed: %@", [result.failureDetails getDescription]);
        } else {
            NSLog(@"Recaching failed");
        }
        
        // Dismiss recaching view controller if still presented
        if (self.presentedViewController) {
            [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

@end
```

#### With Custom Themes (Objective-C)

```objc
#import <SpreedlyUI/SpreedlyUI-Swift.h>

// Create theme configurations
SPLThemeConfig *lightThemeConfig = [[SPLThemeConfig alloc]
    initWithPrimaryColor:[UIColor systemBlueColor]
    secondaryColor:[UIColor systemGrayColor]
    backgroundColor:[UIColor whiteColor]
    borderColor:[UIColor systemGray4Color]
    borderFocusedColor:[UIColor systemBlueColor]
    textColor:[UIColor blackColor]
    textSecondaryColor:[UIColor systemGrayColor]
    errorColor:[UIColor systemRedColor]
    placeholderColor:nil
    borderRadius:8.0];

SPLThemeConfig *darkThemeConfig = [[SPLThemeConfig alloc]
    initWithPrimaryColor:[UIColor systemBlueColor]
    secondaryColor:[UIColor systemGrayColor]
    backgroundColor:[UIColor blackColor]
    borderColor:[UIColor systemGray2Color]
    borderFocusedColor:[UIColor systemBlueColor]
    textColor:[UIColor whiteColor]
    textSecondaryColor:[UIColor systemGrayColor]
    errorColor:[UIColor systemRedColor]
    placeholderColor:nil
    borderRadius:8.0];

// Generate signature before presenting (required for production)
[[SpreedlyConfigManager shared] generateSignatureWithCompletion:^(BOOL success, NSError * _Nullable error) {
    if (success) {
        // Initialize with custom themes
        CVVRecachingViewController *recachingVC = [[CVVRecachingViewController alloc]
            initWithLastFourDigits:self.selectedCard.lastFourDigits
            cardType:self.selectedCard.cardType
            cardBrand:self.selectedCard.cardBrand
            paymentMethodToken:self.selectedCard.paymentMethodToken
            presentationMode:0
            labelText:@"CVV"
            placeholderText:@"123"
            buttonText:@"Confirm"
            cancelButtonText:@"Cancel"
            lightThemeConfig:lightThemeConfig
            darkThemeConfig:darkThemeConfig
            onProcessingResult:^(PaymentProcessingResult *result) {
                // Handle processing result
            }];
        
        [self presentViewController:recachingVC animated:YES completion:nil];
    } else {
        // Handle signature generation error
        NSLog(@"Failed to generate signature: %@", error.localizedDescription);
    }
}];
```

### Payment Result Handling

Recaching uses the same payment result system as payment method creation. You can receive results via:

**1. Combine Publisher (Swift/SwiftUI)**

```swift
let cancellable = Spreedly.shared().subscribeToPaymentResults { result in
    if result.isSuccess {
        // Recaching successful
        print("Recaching successful")
        // Use result.token for your payment processing
    } else if result.isFailure {
        // Handle failure
        if let failureDetails = result.failureDetails {
            print("Error: \(failureDetails.getDescription())")
        }
    }
}
```

**2. Delegate Pattern (UIKit/Objective-C)**

```objc
// Set delegate
[Spreedly.shared setPaymentDelegate:self];

// Implement delegate method
- (void)paymentDidComplete:(PaymentResult *)result {
    if (result.isSuccess) {
        NSLog(@"Recaching successful");
        // Use result.token for your payment processing
    } else if (result.isFailure) {
        NSLog(@"Recaching failed: %@", [result.failureDetails getDescription]);
    }
}
```

**PaymentResult Properties:**

- `token: String?` - The payment method token (available for successful payments)
- `paymentResponse: PaymentMethodResponse?` - Full payment method response
- `shouldRetain: Bool` - Indicates if user wants to save card for future payments
  - `true` - User checked "Save card for future payments" checkbox
  - `false` - User unchecked the checkbox

### Error Handling

Common error scenarios and how to handle them:

> **📖 For comprehensive error handling documentation**, including detailed 3DS authentication error handling, see [ERROR_HANDLING_GUIDE.md](ERROR_HANDLING_GUIDE.md).

**1. Validation Errors**

```swift
onProcessingResult: { result in
    if result.isValidationFailed {
        if result.invalidFields.contains(.cvc) {
            showError("Please enter a valid CVV (3-4 digits)")
        }
    }
}
```

**2. Network Errors**

```swift
Spreedly.shared().subscribeToPaymentResults { result in
    if result.isFailure {
        if let failureDetails = result.failureDetails {
            switch failureDetails.errorType {
            case .networkError:
                showError("Network connection failed. Please check your internet connection.")
            case .apiError:
                showError("Recaching failed. Please try again.")
            default:
                showError(failureDetails.getDescription())
            }
        }
    }
}
```

**3. Payment Method Not Found**

```swift
Spreedly.shared().subscribeToPaymentResults { result in
if result.isFailure, let failureDetails = result.failureDetails {
        if failureDetails.statusCode?.intValue == 404 {
            showError("Payment method not found. Please add a new payment method.")
            removePaymentMethod(token: paymentMethodToken)
        }
    }
}
```

### Security Considerations

**1. Screen Prevention**

Always apply `.screenPrevention()` to protect sensitive CVV input:

```swift
SpreedlyCVVRecachingView(
    // ... configuration
)
.screenPrevention()
```

**2. Secure Value Collection**

The SDK uses `SecureValueContainer` to securely collect and transmit CVV values. CVV is never stored locally and is only transmitted securely to Spreedly's API.

**3. Memory Management**

Remember to cancel payment result subscriptions to prevent memory leaks:

```swift
.onDisappear {
    cancellable?.cancel()
    cancellable = nil
}
```



### Security Considerations

**1. Screen Prevention**

Always apply `.screenPrevention()` to protect sensitive CVV input:

```swift
SpreedlyCVVRecachingView(
    // ... configuration
)
.screenPrevention()
```

**2. Secure Value Collection**

The SDK uses `SecureValueContainer` to securely collect and transmit CVV values. CVV is never stored locally and is only transmitted securely. When using SDK UI components, `SecureValueContainer` is managed automatically.

**3. Memory Management**

Remember to cancel payment result subscriptions to prevent memory leaks:

```swift
.onDisappear {
    cancellable?.cancel()
    cancellable = nil
}
```

**Issue: CVV Recaching view doesn't appear**

- Ensure `paymentMethodToken` is valid and not empty
- Check that `RecacheConfig` is properly initialized with required `cardInfo`
- Verify that `isPresented` binding is set to `true`
- For dialog mode, ensure you're using `.crossDissolveFullScreenCover()` instead of `.sheet()`
- Check that view is not hidden or covered by other views

**Issue: Payment result not received**

- Ensure payment result subscription is set up BEFORE calling `recachePaymentMethod()`
- Check that subscription is not cancelled prematurely
- Verify delegate is set for Objective-C integration
- Check that you're not creating multiple subscriptions (only one should be active)
- Verify SDK is properly initialized with `Spreedly.initializeSDK()` or `Spreedly.setup(config:)`

**Issue: Validation errors**

- Ensure CVV format is correct (3-4 digits)
- Check that `SecureValueContainer` is properly initialized
- Verify SDK configuration is correct
- For programmatic recaching, ensure CVV is registered before calling recache
- Check that `SecureValueContainer.shared.startCollection()` was called

**Issue: Network errors**

- Check network connectivity
- Verify Spreedly environment key is correct
- Ensure API credentials are valid

**Issue: "CVV is not available for payment processing" error**

- This means CVV was not found in `SecureValueContainer`
- For UI components: Ensure user actually entered CVV in the input field
- For programmatic: Ensure you called `SecureValueContainer.shared.registerValue()` before recaching
- Check that `SecureValueContainer.shared.startCollection()` was called
- Verify CVV wasn't cleared before recache was called

**Issue: Payment method token not found (404 error)**

- Token may have been deleted
- Token may belong to a different environment
- Token may be invalid or expired
- Solution: Remove token from saved payment methods and ask user to add new payment method

**Issue: Dialog mode not showing dimmed background**

- Ensure you're using `.crossDissolveFullScreenCover()` modifier
- Check that `presentationMode` is set to `.dialog` in `RecacheConfig`

**Issue: Screen prevention not working**

- Ensure `.screenPrevention()` is applied to the recaching view
- Verify SDK is properly imported

**Issue: Memory leaks or retain cycles**

- Ensure you cancel subscriptions in `onDisappear` or `dealloc`
- Verify `SecureValueContainer` is cleaned up after use

## 3DS Authentication

3D Secure (3DS) authentication provides an additional layer of security for online card payments. The Spreedly iOS SDK integrates with Forter's 3DS solution to handle Strong Customer Authentication (SCA) challenges when required by the payment gateway.

### Overview

When a transaction requires 3DS authentication, your backend will receive a `managed_order_token` from Spreedly's API. The SDK fetches this token internally via the status API using the `transaction_token`, so you no longer need to pass `managed_order_token` into the app. The SDK provides UI components to present the 3DS challenge to the user and report the result back to your application.

**Key Components:**

- **DoChallengeIfNeeded** - SwiftUI view for presenting 3DS challenges
- **DoChallengeIfNeededViewController** - UIKit/Objective-C compatible view controller
- **ThreeDSChallengeResult** - Result object containing challenge outcome
- **SpreedlyThreeDSChallengeDelegate** - Delegate protocol for Objective-C integration

### SDK Initialization with 3DS Support

> **⚠️ Important**: `Spreedly.setup(config:)` is **MANDATORY** and must include `environmentKey`, `forterSiteId`, and all signature parameters. `Spreedly.initializeSDK()` alone is **NOT sufficient** - it only creates the SDK instance without required credentials.

To enable 3DS authentication, use the two-step initialization pattern:

**Step 1:** Initialize SDK at app launch (basic setup - creates instance only)  
**Step 2:** **MANDATORY** - Configure with `environmentKey`, `forterSiteId`, and signature parameters before making payment requests

#### Step 1: Basic Initialization (App Launch)

> **⚠️ Note**: This step only creates the SDK instance. It is **NOT sufficient** for payment operations. You **MUST** complete Step 2 with `setup(config:)` before making any payment requests.

**Swift (UIKit):**

```swift
import SpreedlyCore

// In your App delegate
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // Step 1: Basic initialization (creates SDK instance only)
    // ⚠️ This alone is NOT sufficient - you MUST call setup(config:) in Step 2
    Spreedly.initializeSDK()
    
    return true
}
```

**Swift (SwiftUI):**

```swift
import SwiftUI
import SpreedlyCore

@main
struct MyApp: App {
    init() {
        // Step 1: Basic initialization (creates SDK instance only)
        // ⚠️ This alone is NOT sufficient - you MUST call setup(config:) in Step 2
        Spreedly.initializeSDK()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

**Objective-C:**

```objc
#import <SpreedlyCore/SpreedlyCore-Swift.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Step 1: Basic initialization (creates SDK instance only)
    // ⚠️ This alone is NOT sufficient - you MUST call setupWithConfig: in Step 2
    [Spreedly initializeSDK];
    
    return YES;
}
```

#### Step 2: Configure with Credentials (MANDATORY)

> **⚠️ CRITICAL**: You **MUST** call `Spreedly.setup(config:)` with all required credentials before making any payment requests. The SDK **will not function** without:
> - `environmentKey` (REQUIRED)
> - `forterSiteId` (REQUIRED for 3DS support)
> - `certificateToken` (REQUIRED for security)
> - `nonce` (REQUIRED for security)
> - `signature` (REQUIRED for security)
> - `timestamp` (REQUIRED for security)
>
> **Without Step 2, payment operations will fail.**

**Step 1:** Initialize SDK with basic configuration at app launch (creates instance only - **NOT sufficient for payments**)  
**Step 2:** **MANDATORY** - Update configuration with environment key, Forter Site ID, and signature parameters before making payment requests

**Swift:**

```swift
import SpreedlyCore

class SpreedlyConfigManager {
    static let shared = SpreedlyConfigManager()
    
    private let environmentKey = "your_environment_key"
    private let forterSiteId = "your_forter_site_id"
    private let serverURL = "https://your-backend.com/api/v1/auth/params"
    
    private init() {
        // Step 1: Basic initialization (already called in app launch)
        // This creates the SDK instance but does NOT provide credentials
    }
    
    /// Step 2: MANDATORY - Update config with ALL required credentials before payment
    /// This MUST be called before any payment operations
    func generateSignature() async -> Result<Bool, Error> {
        let config = SignatureSecurityService.ServerSecurityConfig(
            serverURL: serverURL,
            apiKey: nil,
            environmentKey: environmentKey
        )
        
        let result = await SignatureSecurityService.setupServerBasedSecurity(config: config)
        
        guard let signatureParams = result.signatureParams else {
            return .failure(result.error ?? NSError(domain: "Config", code: 0))
        }
        
        // MANDATORY: Update Spreedly config with ALL required credentials
        // This MUST include: environmentKey, forterSiteId, and signature parameters
        Spreedly.setup(config: SpreedlyConfig(
            environmentKey: environmentKey,           // REQUIRED
            forterSiteId: forterSiteId,              // REQUIRED for 3DS
            certificateToken: signatureParams.certificateToken,  // REQUIRED
            nonce: signatureParams.nonce,            // REQUIRED
            signature: signatureParams.signature,    // REQUIRED
            timestamp: String(signatureParams.timestamp)  // REQUIRED
        ))
        
        return .success(true)
    }
}
```

**Objective-C:**

```objc
#import <SpreedlyCore/SpreedlyCore-Swift.h>

@implementation SpreedlyConfigManager

- (instancetype)init {
    if (self = [super init]) {
        // Step 1: Initialize with default configuration
        [Spreedly initializeSDK];
    }
    return self;
}

/// Step 2: MANDATORY - Update config with ALL required credentials before payment
/// This MUST be called before any payment operations
- (void)generateSignatureWithCompletion:(void (^)(BOOL success, NSError *error))completion {
    // Fetch signature from your backend...
    
    // MANDATORY: Update Spreedly config with ALL required credentials
    // This MUST include: environmentKey, forterSiteId, and signature parameters
    SpreedlyConfig *config = [[SpreedlyConfig alloc] initWithEnvironmentKey:self.environmentKey];  // REQUIRED
    config.forterSiteId = self.forterSiteId;  // REQUIRED for 3DS
    config.certificateToken = result.signatureParams.certificateToken;  // REQUIRED
    config.nonce = result.signatureParams.nonce;  // REQUIRED
    config.signature = result.signatureParams.signature;  // REQUIRED
    config.timestamp = [NSString stringWithFormat:@"%ld", (long)result.signatureParams.timestamp];  // REQUIRED
    
    [Spreedly setupWithConfig:config];
    
    completion(YES, nil);
}

@end
```

> **⚠️ CRITICAL**: `Spreedly.setup(config:)` is **MANDATORY** and must be called with all required credentials:
> - `environmentKey` (REQUIRED) - Without this, API calls will fail
> - `forterSiteId` (REQUIRED for 3DS) - Get from [Forter Portal](https://portal.forter.com/app/integration/credentials/)
> - `certificateToken`, `nonce`, `signature`, `timestamp` (REQUIRED) - For secure authentication
>
> **Without calling `setup(config:)` with these credentials, the SDK cannot process payments.**
>
> When `setup(config:)` is called after the SDK is already initialized, it updates the existing configuration without reinitializing the Forter SDK.

### 3DS Flow Overview

The 3DS authentication flow provides Strong Customer Authentication (SCA) for card payments. The SDK integrates with Forter's 3DS solution to handle the challenge presentation and transaction completion automatically.

**Complete End-to-End Flow:**

1. **Tokenize Payment Method** - Use `CardFormDropIn` or individual fields to create a payment method token
2. **Backend Purchase Request** - Your backend sends the payment method token to Spreedly's purchase/authorize endpoint
3. **Check for 3DS Requirement** - If the response contains `sca_authentication` and `transaction.token`, 3DS is required
4. **Present Challenge** - Display the 3DS challenge UI using `DoChallengeIfNeeded` or `DoChallengeIfNeededViewController`
5. **SDK Internal Processing** (Automatic):
   - Forter SDK presents challenge UI to user (if required)
   - When Forter completes, SDK receives callback
   - **SDK automatically calls `three_ds_automated_complete` API** to signal challenge completion
   - **SDK automatically calls `status.json` API** to check final transaction state
   - SDK maps status response to `ThreeDSChallengeResult` and emits result
6. **Handle Result** - Receive the challenge result via subscription or delegate (result is based on status API, not just Forter callback)

**Important Notes:**

- The SDK **automatically handles** the completion and status API calls internally - you don't need to call them manually
- The `ThreeDSChallengeResult` you receive is based on the **status.json API response**, ensuring accurate transaction state
- If Forter SDK reports an error immediately, the SDK emits a failure result without calling APIs
- The result indicates the final transaction state: success, failure, or canceled

### SwiftUI Integration

#### Basic Implementation

```swift
import SwiftUI
import SpreedlyCore
import SpreedlyUI
import Combine

struct PaymentView: View {
    @State private var showCheckout = false
    @State private var show3DSChallenge = false
    @State private var transactionToken: String?
    @State private var paymentResult: PaymentResult?
    @State private var challengeResult: ThreeDSChallengeResult?
    @State private var errorMessage: String?
    
    // Subscriptions
    @State private var paymentCancellable: AnyCancellable?
    @State private var challengeCancellable: AnyCancellable?
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Pay Now") {
                showCheckout = true
            }
            
            if let result = paymentResult, result.isSuccess {
                Text("Payment Successful!")
                    .foregroundColor(.green)
            }
            
            if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            }
        }
        .sheet(isPresented: $showCheckout) {
            CardFormDropIn(
                onProcessingResult: { result in
                    if result.isSuccess {
                        showCheckout = false
                    }
                }
            )
        }
        .sheet(isPresented: $show3DSChallenge) {
            if let transactionToken = transactionToken {
                DoChallengeIfNeeded(
                    transactionToken: transactionToken,
                    onDismiss: {
                        show3DSChallenge = false
                    }
                )
            }
        }
        // Note: Do NOT apply .screenPrevention() to 3DS challenges - Forter SDK handles its own security
        .onAppear {
            setupSubscriptions()
        }
        .onDisappear {
            cleanupSubscriptions()
        }
    }
    
    private func setupSubscriptions() {
        // Subscribe to payment results
        paymentCancellable = Spreedly.shared().subscribeToPaymentResults { result in
            paymentResult = result
            
            if result.isSuccess {
                // After successful tokenization, check with your backend if 3DS is required
                // This is a simplified example - in production, call your backend API
                checkFor3DSRequirement(paymentToken: result.token ?? "")
            } else if result.isFailure {
                errorMessage = result.failureDetails?.getDescription() ?? "Payment failed"
            }
        }
        
        // ⚠️ CRITICAL: Subscribe to 3DS challenge results BEFORE presenting challenge
        // If you subscribe after presenting, you may miss the result callback
        challengeCancellable = Spreedly.shared().subscribeToThreeDSChallengeResults { result in
            challengeResult = result
            
            if result.isSuccess {
                // 3DS Challenge completed successfully
                // The SDK has already called three_ds_automated_complete API and status API internally
                // Result is based on status API response, indicating transaction succeeded
                show3DSChallenge = false
                errorMessage = nil
                
                // Transaction is complete based on status API response
                
            } else if result.isFailure {
                // 3DS Challenge failed
                show3DSChallenge = false
                if let error = result.error {
                    errorMessage = "3DS Challenge failed: \(error.localizedDescription)"
                } else {
                    errorMessage = "3DS Challenge failed"
                }
                
            } else if result.isCanceled {
                // User canceled 3DS challenge
                show3DSChallenge = false
                errorMessage = "3DS Challenge canceled by user"
            }
        }
    }
    
    private func cleanupSubscriptions() {
        paymentCancellable?.cancel()
        paymentCancellable = nil
        challengeCancellable?.cancel()
        challengeCancellable = nil
    }
    
    private func checkFor3DSRequirement(paymentToken: String) {
        // In production, call your backend API to initiate the purchase
        // Your backend will return the transaction_token and indicate if 3DS is required
        
        // Example (replace with your actual backend call):
        // Task {
        //     let response = try await yourBackendAPI.purchase(paymentToken: paymentToken)
        //     
        //     await MainActor.run {
        //         // Check if 3DS is required
        //         if let transaction = response.transaction,
        //            transaction.scaAuthentication != nil {
        //             // Store the transaction token - SDK fetches managed_order_token internally
        //             transactionToken = transaction.token  // Required for SDK's internal API calls
        //             show3DSChallenge = true
        //         } else {
        //             // No 3DS required - transaction complete
        //             successMessage = "Transaction completed successfully!"
        //         }
        //     }
        // }
    }
}
```

#### DoChallengeIfNeeded Parameters

```swift
DoChallengeIfNeeded(
    transactionToken: String,         // Required: Transaction token for completion and status APIs
    onDismiss: (() -> Void)? = nil  // Optional: Called when view should be dismissed
)
```

**Note:** Screen prevention cannot be applied to 3DS challenges because Forter SDK presents its own sheet/view controller that cannot be wrapped in our protection layer. The Forter SDK handles its own security measures for the challenge UI.

### UIKit Integration

For UIKit-based apps, use `DoChallengeIfNeededViewController`:

```swift
import UIKit
import SpreedlyCore
import SpreedlyUI
import Combine

class PaymentViewController: UIViewController {
    private var challengeCancellable: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChallengeSubscription()
    }
    
    private func setupChallengeSubscription() {
        // Subscribe to 3DS challenge results BEFORE presenting challenge
        challengeCancellable = Spreedly.shared().subscribeToThreeDSChallengeResults { [weak self] result in
            guard let self = self else { return }
            
            if result.isSuccess {
                // 3DS Challenge completed successfully
                self.dismiss(animated: true) {
                    self.handleChallengeSuccess()
                }
                
            } else if result.isFailure {
                // 3DS Challenge failed
                self.dismiss(animated: true) {
                    let message = result.error?.localizedDescription ?? "3DS Challenge failed"
                    self.showError(message)
                }
                
            } else if result.isCanceled {
                // User canceled
                self.dismiss(animated: true) {
                    self.showError("3DS Challenge canceled")
                }
            }
        }
    }
    
    func present3DSChallenge(transactionToken: String) {
        // Create the challenge view controller
        let challengeVC = DoChallengeIfNeededViewController(
            transactionToken: transactionToken,
            onDismiss: { [weak self] in
                self?.dismiss(animated: true)
            }
        )
        
        // Present modally
        present(challengeVC, animated: true)
    }
    
    private func handleChallengeSuccess() {
        // Transaction is complete based on status API response
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    deinit {
        challengeCancellable?.cancel()
    }
}
```

### Objective-C Integration

For Objective-C projects, use the delegate pattern to receive 3DS challenge results:

#### Setting Up the Delegate

```objc
#import <SpreedlyCore/SpreedlyCore-Swift.h>
#import <SpreedlyUI/SpreedlyUI-Swift.h>

@interface PaymentViewController () <SpreedlyThreeDSChallengeDelegate>
@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the 3DS challenge delegate
    [Spreedly shared].threeDSChallengeDelegate = self;
}

// MARK: - SpreedlyThreeDSChallengeDelegate

- (void)threeDSChallengeDidComplete:(ThreeDSChallengeResult *)result {
    if (result.isSuccess) {
        // 3DS Challenge completed successfully
        // The SDK has already called three_ds_automated_complete API and status API internally
        // Result is based on status API response, indicating transaction succeeded
        
        [self dismissViewControllerAnimated:YES completion:^{
            // Transaction is complete based on status API response
            [self handleTransactionSuccess];
        }];
        
    } else if (result.isFailure) {
        // 3DS Challenge failed
        NSString *errorMessage = result.error.localizedDescription ?: @"3DS Challenge failed";
        
        [self dismissViewControllerAnimated:YES completion:^{
            [self showErrorWithMessage:errorMessage];
        }];
        
    } else if (result.isCanceled) {
        // User canceled the challenge
        
        [self dismissViewControllerAnimated:YES completion:^{
            [self showErrorWithMessage:@"3DS Challenge canceled"];
        }];
    }
}

@end
```

#### Presenting the 3DS Challenge

```objc
- (void)present3DSChallengeWithTransactionToken:(NSString *)transactionToken {
    // Create the challenge view controller
    DoChallengeIfNeededViewController *challengeVC = [[DoChallengeIfNeededViewController alloc] 
        initWithTransactionToken:transactionToken
        onDismiss:nil];  // Using delegate pattern, so onDismiss can be nil
    
    // Present modally
    [self presentViewController:challengeVC animated:YES completion:nil];
}

- (void)handleTransactionSuccess {
    // Transaction is complete based on status API response
    NSLog(@"Transaction completed successfully");
}

- (void)showErrorWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController 
        alertControllerWithTitle:@"Error" 
        message:message 
        preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}
```

#### Complete Objective-C Example

```objc
#import <SpreedlyCore/SpreedlyCore-Swift.h>
#import <SpreedlyUI/SpreedlyUI-Swift.h>

@interface CheckoutViewController () <SpreedlyPaymentDelegate, SpreedlyThreeDSChallengeDelegate>
@property (nonatomic, strong) NSString *paymentMethodToken;
@end

@implementation CheckoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set delegates for both payment and 3DS challenge results
    [Spreedly shared].paymentDelegate = self;
    [Spreedly shared].threeDSChallengeDelegate = self;
}

// MARK: - Show Payment Form

- (void)showPaymentForm {
    CardFormDropInViewController *dropInVC = [[CardFormDropInViewController alloc] init];
    
    dropInVC.onProcessingResult = ^(PaymentProcessingResult *result) {
        if (result.isSuccess) {
            NSLog(@"Payment form submitted successfully");
        }
    };
    
    [self presentViewController:dropInVC animated:YES completion:nil];
}

// MARK: - SpreedlyPaymentDelegate

- (void)paymentDidComplete:(PaymentResult *)result {
    if (result.isSuccess) {
        self.paymentMethodToken = result.token;
        
        // Dismiss payment form and check for 3DS requirement
        [self dismissViewControllerAnimated:YES completion:^{
            [self checkFor3DSRequirementWithToken:result.token];
        }];
        
    } else if (result.isFailure) {
        NSLog(@"Payment failed: %@", [result.failureDetails getDescription]);
    }
}

// MARK: - 3DS Flow

- (void)checkFor3DSRequirementWithToken:(NSString *)paymentToken {
    // Call your backend API to initiate the purchase
    // Your backend will return the transaction_token and indicate if 3DS is required
    
    // Example (replace with your actual backend call):
    // [self.backendAPI purchaseWithToken:paymentToken completion:^(BackendResponse *response, NSError *error) {
    //     // Check if 3DS is required
    //     if (response.transaction && 
    //         response.transaction.scaAuthentication) {
    //         // Store the transaction token - SDK fetches managed_order_token internally
    //         self.transactionToken = response.transaction.token;  // Required for SDK's internal API calls
    //         [self present3DSChallengeWithTransactionToken:self.transactionToken];
    //     } else {
    //         // No 3DS required - transaction complete
    //         [self handlePaymentSuccess];
    //     }
    // }];
}

- (void)present3DSChallengeWithTransactionToken:(NSString *)transactionToken {
    DoChallengeIfNeededViewController *challengeVC = [[DoChallengeIfNeededViewController alloc] 
        initWithTransactionToken:transactionToken
        onDismiss:nil];
    
    [self presentViewController:challengeVC animated:YES completion:nil];
}

// MARK: - SpreedlyThreeDSChallengeDelegate

- (void)threeDSChallengeDidComplete:(ThreeDSChallengeResult *)result {
    if (result.isSuccess) {
        // 3DS Challenge completed successfully
        // The SDK has already called three_ds_automated_complete API and status API internally
        // Result is based on status API response, indicating transaction succeeded
        
        [self dismissViewControllerAnimated:YES completion:^{
            // Transaction is complete based on status API response
            [self handleTransactionSuccess];
        }];
        
    } else if (result.isFailure) {
        NSString *errorMessage = result.error.localizedDescription ?: @"3DS Challenge failed";
        
        [self dismissViewControllerAnimated:YES completion:^{
            [self showErrorWithMessage:errorMessage];
        }];
        
    } else if (result.isCanceled) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self showErrorWithMessage:@"Payment canceled"];
        }];
    }
}

// MARK: - Backend Integration

- (void)handleTransactionSuccess {
    // The SDK has already called three_ds_automated_complete and status APIs internally
    // Transaction is complete based on the status API response
}

- (void)handlePaymentSuccess {
    // Payment completed successfully
}

- (void)showErrorWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController 
        alertControllerWithTitle:@"Payment Error" 
        message:message 
        preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
```

### ThreeDSChallengeResult Properties

The `ThreeDSChallengeResult` class provides information about the challenge outcome:

| Property | Type | Description |
|----------|------|-------------|
| `isSuccess` | `Bool` | `true` if the challenge completed successfully |
| `isCanceled` | `Bool` | `true` if the user canceled the challenge |
| `isFailure` | `Bool` | `true` if the challenge failed |
| `managedOrderToken` | `String?` | The managed order token (available for successful challenges) |
| `error` | `Error?` | Error information (available for failed challenges) |
| `failureDetails` | `FailedDetails?` | Detailed failure information |

### Result Handling Patterns

**Swift with Combine:**

```swift
let cancellable = Spreedly.shared().subscribeToThreeDSChallengeResults { result in
    if result.isSuccess {
        // Challenge completed successfully
        // Call backend to finalize transaction
    } else if result.isFailure {
        // Handle failure
        if let error = result.error {
            print("Error: \(error.localizedDescription)")
        }
    } else if result.isCanceled {
        // User canceled
    }
}
```

**Objective-C with Delegate:**

```objc
// Set delegate
[Spreedly shared].threeDSChallengeDelegate = self;

// Implement delegate method
- (void)threeDSChallengeDidComplete:(ThreeDSChallengeResult *)result {
    if (result.isSuccess) {
        // Challenge completed successfully
    } else if (result.isFailure) {
        // Handle failure
    } else if (result.isCanceled) {
        // User canceled
    }
}
```

### Backend Integration

**SDK Internal API Calls (Automatic):**

The SDK automatically handles the following API calls internally when the Forter challenge completes:

1. **`three_ds_automated_complete` API** - Called automatically to signal Spreedly that the 3DS challenge has completed
2. **`status.json` API** - Called automatically after completion API to check the final transaction state
3. **Result Mapping** - The SDK maps the status API response to `ThreeDSChallengeResult`:
   - If `transaction.succeeded == true` → `ThreeDSChallengeResult.success`
   - If `transaction.failed == true` → `ThreeDSChallengeResult.failure`
   - If `transaction.isPending == true` → `ThreeDSChallengeResult.failure` (with appropriate error message)
   - If Forter SDK reports an error → `ThreeDSChallengeResult.failure` (emitted immediately, no API calls)

**Your Backend Flow:**

1. **Initiate Purchase** - Your backend calls Spreedly's purchase/authorize endpoint with the payment method token
2. **Handle SCA Response** - If `sca_authentication` and `transaction.token` are present in the response, return the transaction token and a 3DS-required signal to the app
3. **Receive Challenge Result** - After the SDK completes the challenge and internal API calls, you receive `ThreeDSChallengeResult`
4. **Transaction Complete** - The transaction is complete based on the status API response. No additional backend calls are needed.

**Important:** The SDK handles the completion and status API calls automatically. You only need to:
- Extract `transaction.token` from your backend's purchase response
- Present the challenge UI
- Handle the result callback

For detailed backend integration, refer to [Spreedly's 3DS documentation](https://docs.spreedly.com/guides/3ds/).

### How 3DS Processing Works

**What You Need to Know:**

The SDK automatically handles the complete 3DS authentication flow for you. Here's what happens:

1. **Challenge Presentation:**
   - When you present `DoChallengeIfNeeded` or `DoChallengeIfNeededViewController`, the SDK manages the Forter SDK integration
   - The Forter SDK presents its challenge UI to the user if authentication is required
   - If no challenge is needed, the flow completes immediately

2. **Automatic Processing:**
   - After the challenge completes, the SDK automatically calls the required Spreedly APIs:
     - `three_ds_automated_complete` API - Signals that the 3DS challenge has completed
     - `status.json` API - Checks the final transaction state
   - The SDK maps the status response to determine the final result

3. **Result Delivery:**
   - You receive the final `ThreeDSChallengeResult` via:
     - Combine publisher: `subscribeToThreeDSChallengeResults()`
     - Delegate: `SpreedlyThreeDSChallengeDelegate.threeDSChallengeDidComplete()`
   - The result reflects the actual transaction state from Spreedly's status API

**Important Points:**
- The SDK automatically handles all API calls - you don't need to call any completion or status APIs manually
- The result you receive reflects the actual transaction state from Spreedly's status API
- If the Forter SDK reports an error immediately, you get a failure result without any API calls
- The SDK requires `transactionToken` for internal API calls and fetches `managedOrderToken` via status

### Security Considerations

**1. Token Handling**

- The `transaction_token` is required for SDK's internal API calls - ensure it's included from your backend response
- The SDK fetches `managed_order_token` internally via the status API
- Never log or store these tokens permanently
- Tokens are only used during the challenge flow and should be discarded after completion

**2. Subscription Timing**

- Always subscribe to 3DS challenge results **BEFORE** presenting the challenge view
- This ensures you don't miss the result callback
- The SDK emits results asynchronously after internal API calls complete

**3. Memory Management**

```swift
// Cancel subscriptions when view disappears
.onDisappear {
    challengeCancellable?.cancel()
    challengeCancellable = nil
}
```

**4. Error Handling**

- Handle all three result states: `isSuccess`, `isFailure`, and `isCanceled`
- The `error` property contains detailed error information for failures
- Network errors during internal API calls are automatically handled and reported via the result

### Troubleshooting

**Issue: 3DS Challenge view doesn't appear**

- Ensure `transactionToken` is provided (required for SDK's internal API calls)
- Verify the status API response includes a valid `managed_order_token`
- Verify Forter Site ID is configured in `Spreedly.setup(config:)` with a `SpreedlyConfig` containing `forterSiteId`
- Check that the Forter3DS framework is properly linked and embedded in your app bundle
- Verify Forter3DS is available at runtime (check that framework is included in "Frameworks, Libraries, and Embedded Content")

**Issue: Challenge result not received**

- Ensure challenge result subscription is set up **BEFORE** presenting the challenge view
- Check that subscription is not cancelled prematurely
- Verify delegate is set for Objective-C integration (`[Spreedly shared].threeDSChallengeDelegate = self`)
- Verify SDK is properly initialized with `Spreedly.setup(config:)` including all required credentials
- Check network connectivity - SDK makes internal API calls that require network access

**Issue: "Forter SDK not initialized" error**

- Ensure you're calling `Spreedly.setup(config:)` with a `SpreedlyConfig` containing a valid `forterSiteId`
- Verify the Forter3DS framework is properly imported and embedded
- Check that Forter3DS is available at runtime (not just compile-time)

**Issue: Challenge fails immediately**

- Ensure `transaction_token` is included from your backend response
- Verify the status API response includes a valid `managed_order_token`
- Check your Forter portal configuration
- Ensure your environment (test/production) matches your Forter configuration
- Check network connectivity - SDK needs to call completion and status APIs

**Issue: Result shows failure even though Forter challenge succeeded**

- This is expected behavior - the result is based on Spreedly's status API, not just Forter callback
- Check the `error` property in `ThreeDSChallengeResult` for details
- Verify transaction status in Spreedly dashboard
- The SDK calls `status.json` API after Forter completes - check if that API call succeeded

**Issue: "Transaction is not completed" error in result**

- This occurs when `status.json` API returns `transaction.isPending == true`
- Possible causes: incorrect authentication, payment method issues, or network problems
- Check transaction details in Spreedly dashboard
- Verify payment method is valid and not expired

**Issue: Memory leaks or retain cycles**

- Ensure you cancel subscriptions in `onDisappear` or `deinit`
- Use `[weak self]` in closures to avoid retain cycles
- Clean up subscriptions when view controller is deallocated

## Advanced Features

### Custom Theming

The SpreedlyUI SDK provides comprehensive theming support with automatic light/dark mode switching. You can set themes globally or on individual components.

**Key Features:**
- **Separate light and dark themes** - Set different themes for light and dark modes
- **Automatic theme switching** - Themes automatically update when device color scheme changes
- **Global and component-level themes** - Set themes app-wide or per component
- **Backward compatible** - Single theme parameter still works for both modes

**Quick Example:**

```swift
import SpreedlyUI

// Set separate light and dark themes globally
let lightTheme = SpreedlyThemeManager.createCustomTheme(
    colors: SpreedlyColors(primary: Color.blue, background: Color.white, text: Color.black)
)

let darkTheme = SpreedlyThemeManager.createCustomTheme(
    colors: SpreedlyColors(primary: Color.cyan, background: Color.black, text: Color.white)
)

SpreedlyThemeManager.setGlobalTheme(lightTheme: lightTheme, darkTheme: darkTheme)

// Use in components - automatically switches based on color scheme
CardFormDropIn(
    theme: lightTheme,
    darkTheme: darkTheme,
    onProcessingResult: { result in
        // Handle result
    }
)
```

**For detailed theming documentation, including:**
- Complete theme configuration examples
- Global theme setup for Swift and Objective-C
- Component-level theme overrides
- Theme priority system
- Accessibility support
- Android-style theme configuration

**See: [THEME_USAGE_GUIDE.md](THEME_USAGE_GUIDE.md)** for complete documentation on:
- Theme priority system (Custom > Environment > Global > Default)
- Automatic theme switching based on device color scheme
- Detailed examples for all components
- Objective-C integration
- Accessibility support

### Screen Prevention and Security

The Spreedly iOS SDK includes comprehensive screen prevention features to protect sensitive payment information from screenshots, screen recording, and app switcher previews. This is essential for PCI DSS compliance and protecting user payment data.

#### Overview

SpreedlyUI includes comprehensive screen prevention features to protect sensitive payment information. The screen prevention system protects against:

- **Screenshots**: Prevents users from taking screenshots of protected content
- **Screen Recording**: Blocks screen recording of sensitive payment information
- **Screen Sharing**: Prevents content from being shared via AirPlay, screen mirroring, or other sharing methods
- **App Switcher Protection**: Automatically applies privacy overlay when app goes to background to protect previews in the app switcher

The screen prevention system provides three layers of protection:

1. **View-level Protection**: Prevents screenshots, screen recordings, and screen sharing of protected views
2. **App Switcher Protection**: Automatically applies privacy overlay when app goes to background
3. **Automatic Management**: Handles lifecycle events and screen capture detection

#### SwiftUI Integration

Apply screen prevention to any SwiftUI view using the `.screenPrevention()` modifier. **Best Practice:** The most effective way to protect your app is by applying `.screenPrevention()` at the root screen level.

**Note:** Always apply `.screenPrevention()` to `CardFormDropIn` and other payment forms to protect sensitive payment information.

**Important:** Screen prevention **cannot** be applied to 3DS challenges (`DoChallengeIfNeeded` or `DoChallengeIfNeededViewController`) because Forter SDK presents its own sheet/view controller that cannot be wrapped in our protection layer. The Forter SDK handles its own security measures for the challenge UI.

##### Securing the Root Screen (Recommended)

Apply `.screenPrevention()` at the root of your app in `WindowGroup` or your main app entry point:

```swift
import SwiftUI
import SpreedlyUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            MainNavigationView()
                .screenPrevention()  // Protects entire app at root level
        }
    }
}
```

This provides comprehensive protection for your entire app, including all screens, navigation, and content.

##### Securing Sheets Separately

When using sheets, you should protect the sheet content separately by applying `.screenPrevention()` inside the `.sheet()` modifier:

```swift
struct ContentView: View {
    @State private var showPaymentForm = false
    
    var body: some View {
        Button("Show Payment Form") {
            showPaymentForm = true
        }
        .sheet(isPresented: $showPaymentForm) {
            PaymentFormView()
                .screenPrevention()  // Protect sheet content separately
        }
    }
}
```

##### Securing Full Screen Covers

Apply `.screenPrevention()` when presenting full screen content:

```swift
struct ContentView: View {
    @State private var showFullScreenPayment = false
    
    var body: some View {
        Button("Show Full Screen Payment") {
            showFullScreenPayment = true
        }
        .fullScreenCover(isPresented: $showFullScreenPayment) {
            FullScreenPaymentView()
                .screenPrevention()  // Secure full screen content at creation
        }
    }
}
```

##### With Custom Placeholder Text

You can provide custom placeholder text that appears in screenshots, screen recordings, and app switcher previews:

```swift
// At root level
WindowGroup {
    MainNavigationView()
        .screenPrevention(placeholderText: "Secure Payment App")
}

// In sheets
.sheet(isPresented: $showForm) {
    PaymentFormView()
        .screenPrevention(placeholderText: "Payment Information")
}
```

#### UIKit Integration

**Note:** `CardFormDropInViewController` already includes built-in screen prevention protection, so you don't need to wrap it with `wrapInSecureViewController()`. Use the wrapper for other view controllers that need protection.

For other UIKit view controllers, use the `wrapInSecureViewController()` extension:

```swift
import UIKit
import SpreedlyUI

class PaymentViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // CardFormDropInViewController already has built-in protection
        let paymentFormVC = CardFormDropInViewController()
        addChild(paymentFormVC)
        view.addSubview(paymentFormVC.view)
        paymentFormVC.didMove(toParent: self)
        
        // For custom view controllers, wrap them in secure protection
        let sensitiveDataVC = SensitiveDataViewController()
        let secureVC = sensitiveDataVC.wrapInSecureViewController()
        
        // Present or embed the secure view controller
        addChild(secureVC)
        view.addSubview(secureVC.view)
        secureVC.didMove(toParent: self)
    }
}
```

**With Custom Placeholder Text:**

```swift
// For custom view controllers (not CardFormDropInViewController)
let sensitiveDataVC = SensitiveDataViewController()
let secureVC = sensitiveDataVC.wrapInSecureViewController(
    placeholderText: "Payment information is protected"
)
```

**Objective-C Usage:**

```objc
#import <SpreedlyUI/SpreedlyUI-Swift.h>

- (void)showPaymentForm {
    // Create CardFormDropIn view controller
    CardFormDropInViewController *dropInVC = [[CardFormDropInViewController alloc] init];
    
    // Configure the drop-in
    dropInVC.yearFormat = YearFormatFourDigit;
    dropInVC.nameDisplayMode = DropInNameDisplayModeSeparateFields;
    
    // Set completion handlers
    dropInVC.onProcessingResult = ^(PaymentProcessingResult *processingResult) {
        if (processingResult.isSuccess) {
            NSLog(@"Payment successful");
            // Use processingResult.paymentResult.token for your payment processing
        }
    };
    
    // Wrap DropIn in secure protection for screen prevention
    UIViewController *secureDropInVC = [dropInVC wrapInSecureViewControllerWithPlaceholderText:@""];
    
    // Present the wrapped secure view controller
    [self presentViewController:secureDropInVC animated:YES completion:nil];
    
    // For custom view controllers, wrap them:
    // SensitiveDataViewController *sensitiveVC = [[SensitiveDataViewController alloc] init];
    // UIViewController *secureVC = [sensitiveVC wrapInSecureViewControllerWithPlaceholderText:@""];
    // [self presentViewController:secureVC animated:YES completion:nil];
}
```

#### How It Works

- **Screenshot Protection**: Uses secure text entry views to prevent screenshots of protected content
- **Screen Recording Protection**: Blocks screen recording and screen sharing (AirPlay, mirroring) of sensitive information
- **App Switcher Protection**: Automatically applies privacy overlay when app goes to background to protect previews
- **Automatic Management**: When you apply `.screenPrevention()` or `wrapInSecureViewController()`, the manager automatically starts protection for app switcher overlays
- **Lifecycle Management**: The system handles app state changes (background/foreground) automatically
- **Screen Capture Detection**: Monitors for screen recording and mirroring events
- **Privacy Overlay**: Applies blur or custom placeholder when app enters background

#### Protection Scope

**Note:** `CardFormDropIn` already includes built-in screen prevention, so you don't need to apply it manually.

**Important:** Screen prevention **cannot** be applied to 3DS challenges because Forter SDK presents its own sheet/view controller that cannot be wrapped in our protection layer.

**Recommended Usage:**

Apply screen prevention to:
- ✅ Custom views displaying credit card information
- ✅ Views showing sensitive user data (beyond payment forms)
- ❌ **NOT** for 3DS challenges (`DoChallengeIfNeeded` or `DoChallengeIfNeededViewController`) - Forter SDK handles its own security
- ✅ Views displaying payment confirmation details
- ✅ Custom checkout screens (if not using `CardFormDropIn`)
- ✅ Views showing transaction history with sensitive data

**When Not Needed:**

You can skip protection for:
- ❌ `CardFormDropIn` (already protected)
- ❌ **3DS challenges** (`DoChallengeIfNeeded` or `DoChallengeIfNeededViewController`) - Forter SDK presents its own sheet/view controller that cannot be wrapped in our protection layer
- ❌ Non-sensitive content (product listings, menus)
- ❌ Public information
- ❌ Views without payment or sensitive data

#### Best Practices

1. **Apply at Root Level**: The best way to protect your app is by applying `.screenPrevention()` at the root screen level (e.g., in `WindowGroup`). This provides comprehensive protection for your entire app.
2. **Protect Sheets Separately**: Always apply `.screenPrevention()` to sheet content separately, even if you have root-level protection, to ensure complete protection of sheet content.
3. **Use Placeholder Text**: Provide meaningful placeholder text for better user experience in app switcher and screenshots

#### Testing Screen Prevention

**Test Screenshot Prevention:**

1. Apply `.screenPrevention()` to a view
2. Take a screenshot (Command+Shift+3 on simulator, or physical device buttons)
3. Verify the screenshot shows placeholder text or blank content

**Test Screen Recording Prevention:**

1. Start screen recording on your device (Control Center → Screen Recording)
2. Navigate to a protected view
3. Verify the recording shows placeholder text or blank content

**Test App Switcher Prevention:**

1. Navigate to a protected view
2. Put the app in background (home gesture or button)
3. Open app switcher
4. Verify the app preview shows blur overlay or placeholder text

#### Troubleshooting

**Protection Not Working:**

- Ensure `.screenPrevention()` is applied to the root view or specific sensitive views
- Check that the view is actually visible (not hidden or off-screen)
- Verify the SDK is properly imported

**App Switcher Overlay Not Showing:**

- Ensure the view controller is properly embedded or presented
- Check that app lifecycle notifications are being received
- Verify the view hierarchy is correct

**Placeholder Text Not Showing:**

- Ensure placeholder text is provided as a parameter
- Check that the text is not empty
- Verify the view is properly configured

### Localization

```swift
// The SDK automatically supports localization
// Add localized strings to your app bundle

// en.lproj/Localizable.strings
"card_number" = "Card Number";
"expiration_date" = "Expiration Date";
"security_code" = "Security Code";
"pay_now" = "Pay Now";

// Use in your custom forms
Text("card_number".localized)
```

## Logging System

The Spreedly iOS SDK includes a comprehensive logging system that helps you debug issues, monitor SDK behavior, and track payment processing flows. The logging system is built on top of Apple's `os.log` framework for optimal performance and integration with system logging tools.

### Overview

The logging system provides:
- **Structured logging** with consistent formatting
- **Multiple log levels** (VERBOSE, DEBUG, INFO, WARN, ERROR)
- **Automatic sensitive data sanitization** (credit card numbers, API keys, etc.)
- **Configurable log levels** for different environments
- **Performance-optimized** logging that can be disabled in production

### Basic Usage

#### 1. Logging Configuration

By default, logging is enabled with `DEBUG` level. The logger is automatically configured and ready to use without any additional setup:

```swift
import SpreedlyCore

// Initialize the SDK
Spreedly.initializeSDK()

// Logging is automatically configured and ready to use
```

#### 2. Using Global Logging Functions

The SDK provides global logging functions that you can use anywhere in your app:

```swift
import SpreedlyCore

// Basic logging
logDebug(tag: "PaymentFlow", message: "Starting payment process")
logInfo(tag: "PaymentFlow", message: "Payment method created successfully")
logWarn(tag: "PaymentFlow", message: "Retrying payment due to network timeout")
logError(tag: "PaymentFlow", message: "Payment failed", error: paymentError)

// Logging with error objects
do {
    try processPayment()
} catch {
    logError(tag: "PaymentFlow", message: "Payment processing failed", error: error)
}
```

#### 3. Log Levels

The SDK supports five log levels with different priorities:

```swift
// From most verbose to least verbose
logVerbose(tag: "Debug", message: "Detailed debugging information")
logDebug(tag: "Debug", message: "General debugging information")
logInfo(tag: "Info", message: "General information about SDK operations")
logWarn(tag: "Warning", message: "Warning messages for potential issues")
logError(tag: "Error", message: "Error messages for failures")
```

### Configuration

#### Setting Log Levels

The logger is configured with debug settings by default, which means:

- **DEBUG**, **INFO**, **WARN**, and **ERROR** messages are logged
- **VERBOSE** messages are filtered out
- This provides comprehensive logging for development and debugging

You can change the logging level at runtime using the `setLogLevel()` function:

```swift
import SpreedlyCore

// Set different log levels as needed
Spreedly.setLogLevel(.verbose)  // Show all messages
Spreedly.setLogLevel(.debug)    // Show debug and above (default)
Spreedly.setLogLevel(.info)     // Show info and above
Spreedly.setLogLevel(.warn)     // Show warnings and errors only
Spreedly.setLogLevel(.error)    // Show errors only
Spreedly.setLogLevel(.none)     // Disable all logging
```

#### Environment-Specific Configuration

The logger is automatically configured with debug settings by default, which provides comprehensive logging for development and debugging. For production environments, you may want to set a higher log level to reduce log volume:

```swift
// For production, consider setting to warn or error level
Spreedly.setLogLevel(.warn)  // Only show warnings and errors
```

### Logging in Your Code

#### 1. Payment Processing

Add logging to your payment processing code:

```swift
class PaymentManager {
    func processPayment(cardData: CreditCardData) {
        logInfo(tag: "PaymentManager", message: "Starting payment processing")
        
        do {
            let result = Spreedly.shared().createCreditCard(
                additionalFields: [:],
                metadata: ["source": "mobile_app"]
            )
            
            if result.isProcessing {
                logInfo(tag: "PaymentManager", message: "Payment processing started successfully")
            } else if result.isValidationFailed {
                var errorMessages: [String] = []
                if !result.invalidFields.isEmpty {
                    errorMessages.append("SDK fields: \(result.invalidFields)")
                }
                if !result.invalidAdditionalFields.isEmpty {
                    errorMessages.append("Additional fields: \(result.invalidAdditionalFields)")
                }
                logWarn(tag: "PaymentManager", message: "Payment validation failed for \(errorMessages.joined(separator: ", "))")
            }
        } catch {
            logError(tag: "PaymentManager", message: "Failed to create credit card", error: error)
        }
    }
}
```

#### 2. Network Operations

Log network operations for debugging:

```swift
class NetworkService {
    func makeAPIRequest() async {
        logDebug(tag: "NetworkService", message: "Making API request to payment endpoint")
        
        do {
            let response = try await performRequest()
            logInfo(tag: "NetworkService", message: "API request completed successfully")
        } catch {
            logError(tag: "NetworkService", message: "API request failed", error: error)
        }
    }
}
```

#### 3. User Interface Events

Log UI events for user behavior analysis:

```swift
struct PaymentForm: View {
    var body: some View {
        VStack {
            SPLTextField(
                type: .cardNumber,
                title: "Card Number",
                onValidationChange: { isValid in
                    logDebug(tag: "PaymentForm", message: "Card number validation: \(isValid ? "valid" : "invalid")")
                }
            )
        }
        .onAppear {
            logInfo(tag: "PaymentForm", message: "Payment form displayed")
        }
    }
}
```

### Sensitive Data Protection

The logging system automatically sanitizes sensitive information:

```swift
// These will be automatically sanitized in logs
logInfo(tag: "Payment", message: "Processing card: 4111111111111111")
// Logs: "Processing card: [REDACTED]"

logDebug(tag: "API", message: "Using API key: sk_test_1234567890")
// Logs: "Using API key: [REDACTED]"

// Error objects are also sanitized
let error = NSError(domain: "PaymentError", code: 100, userInfo: [
    "cardNumber": "4111111111111111",
    "apiKey": "sk_test_1234567890"
])
logError(tag: "Payment", message: "Payment failed", error: error)
// Logs: "Payment failed: Error Domain=PaymentError Code=100 [REDACTED]"
```

### Viewing Logs

#### 1. Xcode Console

View logs in Xcode's console during development:

1. Open Xcode
2. Run your app in debug mode
3. Open the Debug Console (View → Debug Area → Debug Console)
4. Logs will appear with the format: `[LEVEL] [TAG] MESSAGE`

#### 2. Console App

View logs on device or simulator using Console.app:

1. Open Console.app on your Mac
2. Select your device or simulator
3. Filter by your app's bundle identifier
4. Look for messages with your custom tags

#### 3. Device Logs

Access logs on physical devices:

```bash
# View logs for your app
xcrun simctl spawn booted log stream --predicate 'process == "YourAppName"'

# View all Spreedly-related logs
xcrun simctl spawn booted log stream --predicate 'subsystem == "com.spreedly.ios"'
```

### Best Practices

#### 1. Use Appropriate Log Levels

```swift
// ✅ Good: Use appropriate levels
logDebug(tag: "PaymentFlow", message: "Validating card number format")
logInfo(tag: "PaymentFlow", message: "Payment processing completed")
logWarn(tag: "PaymentFlow", message: "Network timeout, retrying...")
logError(tag: "PaymentFlow", message: "Payment failed", error: error)

// ❌ Avoid: Using wrong levels
logError(tag: "PaymentFlow", message: "Card number is valid") // Should be logDebug
logInfo(tag: "PaymentFlow", message: "Critical payment failure") // Should be logError
```

#### 2. Use Descriptive Tags

```swift
// ✅ Good: Descriptive, consistent tags
logInfo(tag: "PaymentManager", message: "Payment started")
logInfo(tag: "NetworkClient", message: "Request completed")
logInfo(tag: "ValidationEngine", message: "Card number validated")

// ❌ Avoid: Generic or inconsistent tags
logInfo(tag: "App", message: "Payment started")
logInfo(tag: "Manager", message: "Request completed")
logInfo(tag: "Validation", message: "Card number validated")
```

#### 3. Include Context in Messages

```swift
// ✅ Good: Include relevant context
logInfo(tag: "PaymentFlow", message: "Payment processing started for amount: $\(amount)")
logDebug(tag: "Validation", message: "Card number validation completed in \(duration)ms")
logWarn(tag: "Network", message: "Retrying request after \(retryCount) attempts")

// ❌ Avoid: Vague messages
logInfo(tag: "PaymentFlow", message: "Processing started")
logDebug(tag: "Validation", message: "Validation completed")
logWarn(tag: "Network", message: "Retrying")
```

#### 4. Performance Considerations

```swift
// ✅ Good: Use string interpolation efficiently
logInfo(tag: "Payment", message: "Processing payment for user: \(userID)")

// ✅ Good: Use appropriate log levels
logWarn(tag: "Payment", message: "Retrying payment after network error")
logError(tag: "Payment", message: "Payment failed", error: error)

// ❌ Avoid: Using debug/verbose levels in production code
// These will be filtered out by the production logger configuration
logDebug(tag: "Debug", message: "Debug info: \(expensiveData)")
```

### Troubleshooting with Logs

#### Common Issues and Log Messages

**1. SDK Not Initialized**
```
[ERROR] [Spreedly] Spreedly instance not initialized. Call Spreedly(environmentKey:) first.
```
**Solution**: Ensure `Spreedly.initializeSDK()` or `Spreedly.setup(config:)` is called before using the SDK.

**2. Network Errors**
```
[ERROR] [NetworkClient] Network request failed: The Internet connection appears to be offline.
[WARN] [NetworkClient] Attempt 1 failed: Server error with status code: 500
```
**Solution**: Check network connectivity and server status.

**3. Validation Failures**
```
[WARN] [PaymentProcessingResult] Creating validation failed result for fields: Card Number, CVC
[DEBUG] [Spreedly] Validation failed for fields: [cardNumber, cvc]
```
**Solution**: Check form validation and user input.

**4. Configuration Issues**
```
[WARN] [Spreedly] Spreedly instance already initialized. Configuration updated.
[DEBUG] [Spreedly] Updating Spreedly configuration
```
**Solution**: These are informational messages, not errors.

## Error Handling

> **📖 For comprehensive error handling documentation**, including detailed 3DS authentication error handling, see [ERROR_HANDLING_GUIDE.md](ERROR_HANDLING_GUIDE.md).

### Handling Payment Errors

```swift
CardFormDropIn(
    onProcessingResult: { result in
        if result.isSuccess {
            // Handle successful payment
            print("Payment successful")
            // Use result.paymentResult?.token for your payment processing
        } else if result.isValidationFailed {
            // Handle validation errors
            showAlert(title: "Validation Error", message: result.errorMessage ?? "Validation failed")
        } else {
            // Handle payment errors
            showAlert(title: "Payment Error", message: result.errorMessage ?? "Payment failed")
        }
    }
)
            showAlert(title: "Error", message: "An unexpected error occurred")
        }
    }
)

func showAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
}
```

### Network Error Handling

````swift
import SpreedlyCore

// The new API returns PaymentProcessingResult synchronously
let processingResult = Spreedly.shared().createCreditCard(
    additionalFields: [:],
    metadata: [:]
)

if processingResult.isProcessing {
    // Payment processing started successfully
    // Listen for PaymentResult updates through callbacks
} else if processingResult.isValidationFailed {
    // Handle validation errors for SDK form fields
    if !processingResult.invalidFields.isEmpty {
        for fieldType in processingResult.invalidFields {
            // Highlight invalid SDK fields (e.g., cardNumber, cvc, expirationDate)
            highlightInvalidField(fieldType)
        }
    }
    
    // Handle validation errors for additional fields
    if !processingResult.invalidAdditionalFields.isEmpty {
        for additionalField in processingResult.invalidAdditionalFields {
            // Highlight invalid additional fields (e.g., email, firstName, addressLine1)
            highlightInvalidAdditionalField(additionalField)
        }
    }
}

// Listen for payment results using Combine publisher (Swift)
let cancellable = Spreedly.shared().subscribeToPaymentResults { paymentResult in
    if paymentResult.isSuccess {
        // Handle success
        print("Credit card created successfully")
        // Use paymentResult.token for your payment processing
        
        // Check if user wants to save card
        if paymentResult.shouldRetain {
            // Merchant can save payment method token for future use
            // e.g., store token securely, send to backend
        }
    } else if paymentResult.isFailure {
        // Handle failure
        if let failureDetails = paymentResult.failureDetails {
            print("Error: \(failureDetails.getDescription())")
        }
    }
}

// For Objective-C integration, use the delegate pattern:
```objc
@interface MyViewController : UIViewController <SpreedlyPaymentDelegate>
@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    Spreedly.shared.paymentDelegate = self;
}

- (void)paymentDidComplete:(PaymentResult *)result {
    if (result.isSuccess) {
        NSLog(@"Payment successful");
        // Use result.token for your payment processing
    } else if (result.isFailure) {
        NSLog(@"Payment failed: %@", [result.failureDetails getDescription]);
    }
}

@end
````

## Memory Management and Cancellables

When using Combine publishers with SwiftUI views, it's crucial to properly manage cancellables to prevent memory leaks and unexpected behavior.

### The Problem

Cancellables in SwiftUI views do **not** automatically cancel when the view disappears. You need to explicitly manage their lifecycle.

### Best Practices

#### 1. Using `@State` with `onDisappear` (Recommended)

For a single subscription:

```swift
struct PaymentView: View {
    @State private var cancellable: AnyCancellable?
    @State private var paymentResult: PaymentResult?

    var body: some View {
        VStack {
            // Your UI content
        }
        .onAppear {
            // Subscribe to payment results
            Spreedly.shared().subscribeToPaymentResults { result in
                paymentResult = result
            }
            .store(in: &cancellable)
        }
        .onDisappear {
            // Cancel subscription when view disappears
            cancellable?.cancel()
            cancellable = nil
        }
    }
}
```

For multiple subscriptions:

```swift
struct PaymentView: View {
    @State private var cancellables = Set<AnyCancellable>()
    @State private var paymentResult: PaymentResult?

    var body: some View {
        VStack {
            // Your UI content
        }
        .onAppear {
            // Subscribe to multiple publishers
            Spreedly.shared().subscribeToPaymentResults { result in
                paymentResult = result
            }
            .store(in: &cancellables)

            // Another subscription
            someOtherPublisher.sink { value in
                // Handle value
            }
            .store(in: &cancellables)
        }
        .onDisappear {
            // Cancel all subscriptions when view disappears
            cancellables.removeAll()
        }
    }
}
```

#### 2. Using `onReceive` (Automatic Cancellation)

```swift
struct PaymentView: View {
    @State private var paymentResult: PaymentResult?

    var body: some View {
        VStack {
            // Your UI content
        }
        .onReceive(Spreedly.shared().paymentResultsPublisher) { result in
            paymentResult = result
        }
    }
}
```

The `onReceive` modifier automatically cancels the subscription when the view disappears, making it the cleanest approach for most cases.

#### 3. Using `@StateObject` with Custom Class

```swift
class PaymentManager: ObservableObject {
    private var cancellable: AnyCancellable?
    @Published var paymentResult: PaymentResult?

    init() {
        cancellable = Spreedly.shared().subscribeToPaymentResults { result in
            self.paymentResult = result
        }
    }

    deinit {
        cancellable?.cancel()
    }
}

struct PaymentView: View {
    @StateObject private var paymentManager = PaymentManager()

    var body: some View {
        VStack {
            // Your UI content
        }
    }
}
```

### Common Mistakes to Avoid

1. **Don't rely on `deinit` in SwiftUI views** - SwiftUI views can be recreated frequently, making `deinit` unreliable.

2. **Don't forget to cancel subscriptions** - Always cancel subscriptions when views disappear to prevent memory leaks.

3. **Don't use global cancellables** - Keep cancellables scoped to the view that needs them.

### Example Implementation

Here's a complete example showing proper cancellable management:

```swift
struct CheckoutView: View {
    @State private var showForm = false
    @State private var paymentResult: PaymentResult?
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var cancellable: AnyCancellable?

    var body: some View {
        VStack {
            Button("Show Checkout") {
                showForm = true
            }

            if let result = paymentResult {
                Text("Payment Successful!")
            }

            if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            }
        }
        .sheet(isPresented: $showForm) {
            CardFormDropIn(
                onProcessingResult: { result in
                    if result.isSuccess {
                        paymentResult = result.paymentResult
                        showForm = false
                    } else if result.isValidationFailed {
                        errorMessage = result.errorMessage
                    } else {
                        errorMessage = result.errorMessage
                        showForm = false
                    }
                }
            )
        }
        .onAppear {
            // Subscribe to payment results
            Spreedly.shared().subscribeToPaymentResults { result in
                paymentResult = result
                isLoading = false

                if result.isSuccess {
                    errorMessage = nil
                } else if result.isFailure {
                    if let failureDetails = result.failureDetails {
                        errorMessage = failureDetails.getDescription()
                    } else {
                        errorMessage = "Payment failed"
                    }
                }
            }
            .store(in: &cancellable)
        }
        .onDisappear {
            // Cancel subscription when view disappears
            cancellable?.cancel()
            cancellable = nil
        }
    }
}
```

### Key Takeaways

- **Always cancel subscriptions** when views disappear
- **Use single `AnyCancellable?`** for one subscription, `Set<AnyCancellable>` for multiple
- **Use `onReceive`** when possible for automatic cancellation
- **Use `@State` with `onDisappear`** for manual management
- **Avoid `deinit`** in SwiftUI views
- **Keep cancellables scoped** to the views that need them

## Testing

### Unit Testing

```swift
import XCTest
@testable import SpreedlyCore

class SpreedlyCoreTests: XCTestCase {

    func testCreditCardValidation() {
        // Test valid card number
        let validCard = "4111111111111111"
        XCTAssertTrue(validateCardNumber(validCard))

        // Test invalid card number
        let invalidCard = "1234567890123456"
        XCTAssertFalse(validateCardNumber(invalidCard))
    }

    func testExpirationDateValidation() {
        // Test valid expiration date
        let validDate = "12/25"
        XCTAssertTrue(validateExpirationDate(validDate))

        // Test expired date
        let expiredDate = "01/20"
        XCTAssertFalse(validateExpirationDate(expiredDate))
    }
}
```

### Integration Testing

```swift
import XCTest
@testable import SpreedlyCore

class SpreedlyIntegrationTests: XCTestCase {

    func testPaymentFlow() {
        // Setup test environment
        Spreedly.initializeSDK()

        // Test payment creation - new API returns PaymentProcessingResult synchronously
        let processingResult = Spreedly.shared().createCreditCard(
            additionalFields: ["firstName": "Test", "lastName": "User"],
            metadata: [:]
        )

        // Verify processing result
        XCTAssertNotNil(processingResult)
        // Note: Actual payment result comes through async callbacks

        // For testing, you can verify the processing result
        XCTAssertTrue(processingResult.isProcessing || processingResult.isValidationFailed)
    }
}
```

### UI Testing

```swift
import XCTest

class SpreedlyUITests: XCTestCase {

    func testCheckoutFlow() {
        let app = XCUIApplication()
        app.launch()

        // Navigate to checkout
        app.buttons["Show Checkout"].tap()

        // Fill in payment form
        let cardNumberField = app.textFields["Card Number"]
        cardNumberField.tap()
        cardNumberField.typeText("4111111111111111")

        let expirationField = app.textFields["Expiration Date"]
        expirationField.tap()
        expirationField.typeText("12/25")

        let cvcField = app.secureTextFields["Security Code"]
        cvcField.tap()
        cvcField.typeText("123")

        // Submit payment
        app.buttons["Pay Now"].tap()

        // Verify success
        XCTAssertTrue(app.staticTexts["Payment Successful!"].exists)
    }
}
```

## Objective-C Integration

### Basic Usage with UIKit

```objc
#import <SpreedlyUI/SpreedlyUI-Swift.h>

@interface PaymentViewController : UIViewController
@end

@implementation PaymentViewController

- (void)showPaymentForm {
    CardFormDropInViewController *dropInVC = [[CardFormDropInViewController alloc] init];

    // Set up callback
    dropInVC.onProcessingResult = ^(PaymentProcessingResult *result) {
        if (result.isSuccess) {
            // Payment was successful
            PaymentResult *paymentResult = result.paymentResult;
            NSLog(@"Payment successful");
            // Use paymentResult.token for your payment processing
        } else if (result.isProcessing) {
            // Payment is still being processed
            NSLog(@"Payment processing...");
        } else if (result.isValidationFailed) {
            // Validation failed
            NSLog(@"Validation failed: %@", result.errorMessage);
        } else {
            // Payment failed
            NSLog(@"Payment failed: %@", result.errorMessage);
        }
    };

    [self presentViewController:dropInVC animated:YES completion:nil];
}

@end
```

### Advanced Configuration with Objective-C

```objc
// Create additional fields
NSArray *additionalFields = @[
    [[FormField alloc] initWithId:@"addressLine1" title:@"Address" type:FormFieldTypeAddressLine1 placeholder:nil isRequired:YES],
    [[FormField alloc] initWithId:@"city" title:@"City" type:FormFieldTypeCity placeholder:nil isRequired:YES],
    [[FormField alloc] initWithId:@"state" title:@"State" type:FormFieldTypeState placeholder:nil isRequired:YES],
    [[FormField alloc] initWithId:@"zipCode" title:@"ZIP Code" type:FormFieldTypeZipCode placeholder:nil isRequired:YES]
];

// Set validation parameters before creating CardFormDropInViewController
[[Spreedly shared] setParamWithParameter:ValidationParamAllowBlankName value:NO];
[[Spreedly shared] setParamWithParameter:ValidationParamAllowExpiredDate value:NO];
[[Spreedly shared] setParamWithParameter:ValidationParamAllowBlankDate value:NO];

// Create CardFormDropIn with configuration
CardFormDropInViewController *dropInVC = [[CardFormDropInViewController alloc]
    initWithOtherFields:additionalFields
    yearFormat:YearFormatFourDigit
    nameDisplayMode:DropInNameDisplayModeSeparateFields
    onProcessingResult:^(PaymentProcessingResult *result) {
        if (result.isSuccess) {
            NSLog(@"Payment successful");
            // Use result.paymentResult.token for your payment processing
        } else if (result.isValidationFailed) {
            NSLog(@"Validation failed: %@", result.errorMessage);
        } else {
            NSLog(@"Payment failed: %@", result.errorMessage);
        }
    }];

[self presentViewController:dropInVC animated:YES completion:nil];
```

### Individual Field Components

```objc
// Create individual text field components with keyboard navigation
SPLTextFieldViewController *cardNumberField = [[SPLTextFieldViewController alloc]
    initWithField:FormFieldTypeCardNumber
    title:@"Card Number"
    isRequired:YES
    placeholder:nil
    keyboardType:UIKeyboardTypeNumberPad
    textContentType:UITextContentTypeCreditCardNumber
    onValidationChange:^(BOOL isValid) {
        NSLog(@"Card number valid: %@", isValid ? @"YES" : @"NO");
    }
    onSubmitBlock:^{
        // Move focus to next field
        [self.cvcField becomeFirstResponder];
    }
    submitLabelValue:SpreedlySubmitLabelNext
    onFocusBlock:^{
        // Handle focus event
        NSLog(@"Card number field focused");
    }];

SPLTextFieldViewController *cvcField = [[SPLTextFieldViewController alloc]
    initWithField:FormFieldTypeCvc
    title:@"Security Code"
    isRequired:YES
    placeholder:nil
    keyboardType:UIKeyboardTypeNumberPad
    textContentType:UITextContentTypeCreditCardSecurityCode
    onValidationChange:^(BOOL isValid) {
        NSLog(@"CVC valid: %@", isValid ? @"YES" : @"NO");
    }
    onSubmitBlock:^{
        // Submit form or move to next section
        [self submitForm];
    }
    submitLabelValue:SpreedlySubmitLabelDone
    onFocusBlock:^{
        // Handle focus event
        NSLog(@"CVC field focused");
    }];

// Add to view hierarchy
[self addChildViewController:cardNumberField];
[self.view addSubview:cardNumberField.view];
[cardNumberField didMoveToParentViewController:self];

[self addChildViewController:cvcField];
[self.view addSubview:cvcField.view];
[cvcField didMoveToParentViewController:self];

// Set initial focus
[cardNumberField becomeFirstResponder];
```

### Objective-C Focus Management

For Objective-C projects, you can implement focus management using the `becomeFirstResponder` and `resignFirstResponder` methods:

```objc
@interface PaymentFormViewController : UIViewController
@property (nonatomic, strong) SPLTextFieldViewController *firstNameField;
@property (nonatomic, strong) SPLTextFieldViewController *lastNameField;
@property (nonatomic, strong) SPLTextFieldViewController *cardNumberField;
@property (nonatomic, strong) SPLTextFieldViewController *cvcField;
@end

@implementation PaymentFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupFormFields];
}

- (void)setupFormFields {
    // First Name Field
    self.firstNameField = [[SPLTextFieldViewController alloc]
        initWithField:FormFieldTypeFirstName
        title:@"First Name"
        isRequired:YES
        placeholder:nil
        keyboardType:UIKeyboardTypeDefault
        textContentType:UITextContentTypeGivenName
        onValidationChange:nil
        onSubmitBlock:^{
            [self.lastNameField becomeFirstResponder];
        }
        submitLabelValue:SpreedlySubmitLabelNext];

    // Last Name Field
    self.lastNameField = [[SPLTextFieldViewController alloc]
        initWithField:FormFieldTypeLastName
        title:@"Last Name"
        isRequired:YES
        placeholder:nil
        keyboardType:UIKeyboardTypeDefault
        textContentType:UITextContentTypeFamilyName
        onValidationChange:nil
        onSubmitBlock:^{
            [self.cardNumberField becomeFirstResponder];
        }
        submitLabelValue:SpreedlySubmitLabelNext];

    // Card Number Field
    self.cardNumberField = [[SPLTextFieldViewController alloc]
        initWithField:FormFieldTypeCardNumber
        title:@"Card Number"
        isRequired:YES
        placeholder:nil
        keyboardType:UIKeyboardTypeNumberPad
        textContentType:UITextContentTypeCreditCardNumber
        onValidationChange:nil
        onSubmitBlock:^{
            [self.cvcField becomeFirstResponder];
        }
        submitLabelValue:SpreedlySubmitLabelNext];

    // CVC Field
    self.cvcField = [[SPLTextFieldViewController alloc]
        initWithField:FormFieldTypeCvc
        title:@"Security Code"
        isRequired:YES
        placeholder:nil
        keyboardType:UIKeyboardTypeNumberPad
        textContentType:UITextContentTypeCreditCardSecurityCode
        onValidationChange:nil
        onSubmitBlock:^{
            [self submitForm];
        }
        submitLabelValue:SpreedlySubmitLabelDone];

    // Add fields to view hierarchy
    [self addFormField:self.firstNameField];
    [self addFormField:self.lastNameField];
    [self addFormField:self.cardNumberField];
    [self addFormField:self.cvcField];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Set initial focus to first field
    [self.firstNameField becomeFirstResponder];
}

- (void)addFormField:(SPLTextFieldViewController *)fieldVC {
    [self addChildViewController:fieldVC];
    [self.view addSubview:fieldVC.view];
    [fieldVC didMoveToParentViewController:self];
    
    // Set up constraints
    fieldVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    // Add your constraints here
}

- (void)submitForm {
    // Handle form submission
    NSLog(@"Submitting payment form...");
}

@end
```

### Objective-C Submit Label Values

When using Objective-C, you need to use the integer raw values for `SpreedlySubmitLabel`:

```objc
// Submit label values for Objective-C
typedef NS_ENUM(NSInteger, SpreedlySubmitLabel) {
    SpreedlySubmitLabelReturn = 0,
    SpreedlySubmitLabelDone = 1,
    SpreedlySubmitLabelGo = 2,
    SpreedlySubmitLabelSearch = 3,
    SpreedlySubmitLabelSend = 4,
    SpreedlySubmitLabelNext = 5,        // Most common for form navigation
    SpreedlySubmitLabelJoin = 6,
    SpreedlySubmitLabelRoute = 7,
    SpreedlySubmitLabelContinue = 8
};
```

## Troubleshooting

This section covers common integration errors and their solutions.

### Common Integration Errors

#### 1. Build Errors

**Problem**: Framework not found

**Error Message:**
```
No such module 'SpreedlyCore'
```

**Solution:**
```bash
# Ensure frameworks are properly linked in Xcode:
# 1. Target → Build Phases → Link Binary With Libraries
# 2. Add: SpreedlyCore.framework, SpreedlySecurity.framework, SpreedlyUI.framework
# 3. Clean build folder: Product → Clean Build Folder (Shift+Cmd+K)
# 4. Rebuild the project
```

**Problem**: Swift version compatibility

**Error Message:**
```
Swift version mismatch
```

**Solution:**
```bash
# Check Swift version in project settings
# Target → Build Settings → Swift Language Version → Swift 5.10 or later
```

**Problem**: Module import errors

**Error Message:**
```
Cannot find 'SpreedlyUI' in scope
```

**Solution:**
```swift
// Ensure proper imports
import SpreedlyCore
import SpreedlySecurity
import SpreedlyUI

// Check that all required modules are added to your target dependencies
```

#### 2. SDK Initialization Errors

**Problem**: SDK not initialized

**Error Message:**
```
Spreedly instance not initialized. Call Spreedly.initializeSDK() or Spreedly.setup(config:) first.
```

**Solution:**
```swift
// Ensure Spreedly.initializeSDK() or Spreedly.setup(config:) is called before use
// In AppDelegate or SwiftUI App:

// AppDelegate
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    Spreedly.initializeSDK()
    return true
}

// SwiftUI App
@main
struct MyApp: App {
    init() {
        Spreedly.initializeSDK()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

**Problem**: Invalid credentials

**Error Message:**
```
Invalid environment key or authentication failed
```

**Solution:**
```swift
// Verify all required credentials are provided
let config = SpreedlyConfig(
    environmentKey: "your_env_key",      // ✅ Required - from Spreedly dashboard
    certificateToken: "your_cert_token", // ✅ Required for enhanced security
    nonce: "your_nonce",                 // ✅ Required - unique per request
    signature: "your_signature",         // ✅ Required - generated signature
    timestamp: "your_timestamp"          // ✅ Required - current timestamp
)

Spreedly.setup(config: config)

// Verify credentials in Spreedly dashboard
// Check that environment key is correct for your environment (test/production)
```

#### 3. Network Connectivity Issues

**Problem**: Network request failed

**Error Message:**
```
Network request failed: The Internet connection appears to be offline.
```

**Solution:**
```swift
// Check network connectivity
import Network

let monitor = NWPathMonitor()
monitor.pathUpdateHandler = { path in
    if path.status == .satisfied {
        print("Network connection available")
    } else {
        print("No network connection")
        // Show error to user
    }
}

// Ensure device has internet connection
// Check firewall/network restrictions
// Verify API endpoint is accessible
```

**Problem**: SSL/TLS certificate errors

**Error Message:**
```
SSL certificate validation failed
```

**Solution:**
```swift
// Ensure your app's Info.plist allows network connections
// Add App Transport Security settings if needed (for development only)
// In production, ensure proper SSL certificate configuration
```

#### 4. Validation Failures

**Problem**: Form validation errors

**Error Message:**
```
Validation failed for fields: [cardNumber, cvc]
```

**Solution:**
```swift
// Handle validation errors properly
let processingResult = Spreedly.shared().createCreditCard(
    additionalFields: [:],
    metadata: [:]
)

if processingResult.isValidationFailed {
    // Check for invalid SDK form fields
    if !processingResult.invalidFields.isEmpty {
        for fieldType in processingResult.invalidFields {
            // Highlight invalid fields in UI
            highlightInvalidField(fieldType)
        }
    }
    
    // Check for invalid additional fields
    if !processingResult.invalidAdditionalFields.isEmpty {
        for additionalField in processingResult.invalidAdditionalFields {
            // Show error messages for invalid fields
            showFieldError(additionalField)
        }
    }
}
```

**Problem**: Card number validation failing

**Solution:**
```swift
// Ensure card number is properly formatted
// Card number should be digits only, no spaces or dashes
// Check card number length (typically 13-19 digits)
// Verify Luhn algorithm validation

// Use SPLTextField for automatic validation
SPLTextField(
    type: .cardNumber,
    title: "Card Number",
    isRequired: true,
    onValidationChange: { isValid in
        if !isValid {
            // Show validation error
        }
    }
)
```

#### 5. UI/Display Issues

**Problem**: Form not displaying

**Error Message:**
```
View not rendering or appearing blank
```

**Solution:**
```swift
// Ensure proper SwiftUI environment
struct ContentView: View {
    var body: some View {
        CardFormDropIn(
            onProcessingResult: { result in
                if result.isSuccess {
                    // Handle successful submission
                    print("Payment successful")
                    // Use result.paymentResult?.token for your payment processing
                } else if result.isValidationFailed {
                    // Handle validation errors
                    print("Validation error: \(result.errorMessage ?? "Unknown error")")
                } else {
                    // Handle payment errors
                    print("Payment error: \(result.errorMessage ?? "Unknown error")")
                }
            }
        )
    }
}

// Check that:
// 1. SpreedlyUI module is properly imported
// 2. All required frameworks are linked
// 3. SwiftUI is properly configured
// 4. View hierarchy is correct
```

**Problem**: Validation callbacks not firing

**Solution:**
```swift
// Ensure validation callbacks are properly implemented
SPLTextField(
    type: .cardNumber,
    title: "Card Number",
    isRequired: true,
    onValidationChange: { isValid in
        // This callback is required for validation state
        print("Card number valid: \(isValid)")
        updateFormState(isValid: isValid)
    }
)

// Check that:
// 1. Callback closure is not nil
// 2. Callback is properly retained (not deallocated)
// 3. View is properly initialized
```

**Problem**: Theme not applying

**Solution:**
```swift
// Set global theme
SpreedlyThemeManager.setDarkTheme()
// or
SpreedlyThemeManager.setLightTheme()

// Apply theme to specific component
let customTheme = SpreedlyThemeManager.createCustomTheme(
    colors: SpreedlyColors(primary: Color.blue)
)
SpreedlyThemeManager.setGlobalTheme(customTheme)

// Ensure theme is set before views are created
```

#### 6. Authentication Errors

**Problem**: Authentication failed

**Error Message:**
```
Authentication failed: Invalid signature or credentials
```

**Solution:**
```swift
// Verify signature generation
// Ensure nonce is unique for each request
// Check timestamp is current (not expired)
// Verify certificate token is correct
// Ensure signature matches expected format

// Example: Regenerate signature
let config = SpreedlyConfig(
    environmentKey: environmentKey,
    certificateToken: certificateToken,
    nonce: generateUniqueNonce(),
    signature: generateSignature(),
    timestamp: String(Int(Date().timeIntervalSince1970))
)
```

#### 7. Memory Management Issues

**Problem**: Memory leaks or retain cycles

**Solution:**
```swift
// Ensure proper memory management
struct PaymentView: View {
    @State private var cancellable: AnyCancellable?
    
    var body: some View {
        // Your view
    }
    .onAppear {
        cancellable = Spreedly.shared().subscribeToPaymentResults { result in
            // Handle result
        }
    }
    .onDisappear {
        cancellable?.cancel()
        cancellable = nil
    }
}
```

### Debug Mode

Enable debug logging for troubleshooting:

```swift
#if DEBUG
// Enable verbose logging
Spreedly.setLogLevel(.debug)

// Set to different levels as needed
Spreedly.setLogLevel(.verbose)  // Most detailed
Spreedly.setLogLevel(.debug)    // Debug information
Spreedly.setLogLevel(.info)     // General information
Spreedly.setLogLevel(.warn)     // Warnings only
Spreedly.setLogLevel(.error)    // Errors only
#endif
```

### Getting Help

If you encounter issues not covered here:

1. **Check Documentation**: Review this guide and API documentation
2. **Review Examples**: Examine the Example app for working implementations
3. **Enable Debug Logging**: Use `Spreedly.setLogLevel(.debug)` to see detailed logs
4. **GitHub Issues**: Report bugs and request features
5. **Spreedly Support**: Contact Spreedly support for API-related issues

When reporting issues, include:
- SDK version
- iOS version
- Xcode version
- Error messages
- Code snippets
- Debug logs (with sensitive data redacted)

## Security Best Practices

This section covers essential security practices for integrating the Spreedly iOS SDK securely into your application.

### API Key Security

#### Never Hardcode API Keys

**❌ Bad Practice:**
```swift
// NEVER do this - hardcoded keys in source code
Spreedly.setup(config: SpreedlyConfig(
    environmentKey: "production_key_abc123xyz"
))
```

**✅ Good Practice:**
```swift
// Use secure configuration management
struct SecureConfig {
    static var environmentKey: String {
        // Load from secure storage, environment variables, or secure configuration service
        guard let key = Bundle.main.object(forInfoDictionaryKey: "SpreedlyEnvironmentKey") as? String else {
            fatalError("Environment key not found")
        }
        return key
    }
}

// Initialize with secure key
Spreedly.setup(config: SpreedlyConfig(
    environmentKey: SecureConfig.environmentKey
))
```

#### Secure Configuration Management

1. **Use Build Configuration Files**:
   - Store keys in separate configuration files (not in source control)
   - Use different keys for development, staging, and production
   - Add configuration files to `.gitignore`

2. **Environment Variables**:
   ```swift
   // Load from environment variables
   let environmentKey = ProcessInfo.processInfo.environment["SPREEDLY_ENV_KEY"] ?? ""
   Spreedly.setup(config: SpreedlyConfig(environmentKey: environmentKey))
   ```

3. **Secure Backend Service** (Recommended):
   - Store API keys on your backend server
   - Retrieve keys securely when needed
   - Never expose keys in client-side code

#### Key Rotation on Compromise

If your API key is compromised:

1. **Immediately rotate the key** in your Spreedly dashboard
2. **Update your application** with the new key
3. **Monitor for unauthorized access** in your Spreedly account
4. **Review access logs** for suspicious activity
5. **Update all environments** (development, staging, production)

```swift
// Example: Key rotation handler
func rotateAPIKey() async {
    // 1. Get new key from secure backend
    let newKey = await fetchNewAPIKeyFromBackend()
    
    // 2. Update SDK configuration
    Spreedly.setup(config: SpreedlyConfig(environmentKey: newKey))
    
    // 3. Verify new key works
    // Test with a simple API call
}
```

### Mobile App Security

#### App Switcher Screenshot Prevention

The SDK provides built-in protection for `CardFormDropIn`, but for custom views, you need to apply protection manually.

**Implementation:**

```swift
import SwiftUI
import SpreedlyUI

struct PaymentView: View {
    var body: some View {
        VStack {
            // CardFormDropIn has built-in protection
            CardFormDropIn(
                onProcessingResult: { result in
                    // Handle payment
                }
            )
            
            // Apply protection to custom sensitive views
            CustomSensitiveView()
                .screenPrevention()
        }
    }
}
```

**Testing App Switcher Protection:**

1. Navigate to a protected view in your app
2. Put the app in background (swipe up or press home button)
3. Open app switcher (double-press home or swipe up and hold)
4. Verify the app preview shows a blur overlay or placeholder text
5. Return to the app - content should be visible again

**Best Practices:**

- Apply `.screenPrevention()` to all views displaying payment information
- Test on real devices (not just simulator)
- Use meaningful placeholder text for better user experience
- Ensure protection works across all app states (foreground, background, suspended)

#### Screen Recording Protection

**Risks:**
- Screen recording can capture sensitive payment information
- Users may share screenshots or recordings
- Malicious apps can record screen content

**Mitigation Strategies:**

1. **Detect Screen Recording**:
```swift
import UIKit

class PaymentViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Monitor screen recording state
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenRecordingChanged),
            name: UIScreen.capturedDidChangeNotification,
            object: nil
        )
    }
    
    @objc func screenRecordingChanged() {
        if UIScreen.main.isCaptured {
            // Screen recording is active
            showSecurityWarning()
            // Optionally: Hide sensitive content or show placeholder
        }
    }
}
```

2. **Show Security Warning**:
```swift
func showSecurityWarning() {
    let alert = UIAlertController(
        title: "Screen Recording Detected",
        message: "For your security, please stop screen recording before entering payment information.",
        preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
}
```

3. **Use Screen Prevention Modifier**:
```swift
// The SDK's screen prevention automatically handles recording protection
struct PaymentView: View {
    var body: some View {
        CardFormDropIn(
            onProcessingResult: { result in
                // Handle payment
            }
        )
        // CardFormDropIn already has built-in screen recording protection
    }
}
```

**User Experience Considerations:**

- Inform users about screen recording risks in your app's privacy policy
- Provide clear messaging when recording is detected
- Consider allowing users to proceed with warnings (balance security vs UX)
- Test with screen recording apps (Screen Recording, Zoom, etc.)

### Token Storage Guidance

#### Never Store Tokens In:

**❌ UserDefaults / SharedPreferences:**
```swift
// NEVER do this
UserDefaults.standard.set(paymentToken, forKey: "payment_token")
```

**❌ Plain Text Files:**
```swift
// NEVER do this
try paymentToken.write(toFile: filePath, atomically: true, encoding: .utf8)
```

**❌ LocalStorage / Core Data (unencrypted):**
```swift
// NEVER do this
// Storing unencrypted tokens in local database
```

#### Recommended Secure Storage

**✅ iOS Keychain Services** (Recommended):
```swift
import Security

class SecureTokenStorage {
    static func saveToken(_ token: String, forKey key: String) {
        let data = token.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // Delete existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            print("Failed to save token: \(status)")
            return
        }
    }
    
    static func loadToken(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return token
    }
    
    static func deleteToken(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

// Usage
SecureTokenStorage.saveToken(paymentToken, forKey: "payment_token")
let token = SecureTokenStorage.loadToken(forKey: "payment_token")
```

**✅ Memory-Only Storage** (For temporary tokens):
```swift
// Store tokens only in memory, never persist
class PaymentManager {
    private var paymentToken: String? // Only in memory
    
    func processPayment() {
        // Use token immediately, don't store
        let token = getPaymentToken()
        submitPayment(token: token)
        // Token is cleared when object is deallocated
    }
}
```

**✅ Secure Enclave** (For sensitive cryptographic keys):
```swift
// Use Secure Enclave for cryptographic keys (iOS 8+)
// Note: Payment tokens should be handled by Spreedly backend
// Use Secure Enclave only for app-specific encryption keys
```

#### Best Practices for Token Storage

1. **Minimize Token Lifetime**: Use tokens immediately, don't store longer than necessary
2. **Use Keychain Access Control**: Set appropriate access controls on Keychain items
3. **Enable Keychain Synchronization Carefully**: Only sync if necessary and secure
4. **Clear Tokens on Logout**: Always delete tokens when user logs out
5. **Use Token Expiration**: Implement token expiration checks
6. **Never Log Tokens**: Don't log tokens in console or files

## Best Practices

### Security

1. **CardFormDropIn is automatically protected** - screen prevention is built into `CardFormDropIn`, so you don't need to apply it manually
2. **Enable screen prevention for custom views** - Apply `.screenPrevention()` modifier to your own views that display sensitive payment information
3. **Never store sensitive data** in UserDefaults or other insecure storage - use Keychain Services
4. **Use HTTPS** for all network communications
5. **Validate input** on both client and server
6. **Implement proper error handling** without exposing sensitive information
7. **Protect app switcher previews** - screen prevention automatically handles app switcher protection for `CardFormDropIn` and any views where you apply the modifier
8. **Follow API key security practices** - never hardcode keys, rotate on compromise
9. **Implement screen recording detection** - detect and warn users about screen recording
10. **Use secure token storage** - always use Keychain Services, never UserDefaults

### Performance

1. **Lazy load** payment forms when needed
2. **Cache validation results** to avoid repeated API calls
3. **Use background queues** for network operations
4. **Implement proper memory management** for large forms

### User Experience

1. **Provide clear error messages** for validation failures
2. **Show loading states** during payment processing
3. **Implement proper accessibility** for all form fields
4. **Support dark mode** and dynamic type

### Testing

1. **Test on multiple devices** and iOS versions
2. **Use different network conditions** to test error handling
3. **Test accessibility features** with VoiceOver
4. **Implement automated testing** for critical payment flows

---

## Merchant API Reference Summary

This section provides a quick reference of all merchant-facing classes. For complete API details, see [MERCHANT_API_REFERENCE.md](MERCHANT_API_REFERENCE.md).

### SwiftUI Components

| Class | Purpose | Location |
|-------|---------|----------|
| `CardFormDropIn` | Complete payment form with all fields | `SpreedlyUI/Components/Checkout/CardFormDropIn.swift` |
| `SPLTextField` | Individual form field component | `SpreedlyUI/Components/SPLTextField.swift` |
| `SpreedlyCVVRecachingView` | CVV recaching component | `SpreedlyUI/Components/Recaching/Views/SpreedlyCVVRecachingView.swift` |
| `DoChallengeIfNeeded` | 3DS challenge presentation | `SpreedlyUI/Components/ThreeDS/DoChallengeIfNeeded.swift` |

### UIKit/Objective-C Components

| Class | Purpose | Location |
|-------|---------|----------|
| `CardFormDropInViewController` | Complete payment form (UIKit wrapper) | `SpreedlyUI/Components/Checkout/CardFormDropIn.swift` |
| `SPLTextFieldViewController` | Individual form field (UIKit wrapper) | `SpreedlyUI/Components/SPLTextField.swift` |
| `CVVRecachingViewController` | CVV recaching (UIKit wrapper) | `SpreedlyUI/Components/Recaching/Controllers/CVVRecachingViewController.swift` |
| `DoChallengeIfNeededViewController` | 3DS challenge (UIKit wrapper) | `SpreedlyUI/Components/ThreeDS/DoChallengeIfNeededViewController.swift` |

### Core Classes

| Class | Purpose | Location |
|-------|---------|----------|
| `Spreedly` | Main SDK class for initialization and configuration | `SpreedlyCore/Core/Spreedly.swift` |
| `SpreedlyConfig` | Configuration for SDK setup | `SpreedlyCore/Core/Spreedly.swift` |

### Result Classes

| Class | Purpose | Location |
|-------|---------|----------|
| `PaymentResult` | Payment method creation/recaching result | `SpreedlyCore/Core/Payment/PaymentResult.swift` |
| `PaymentProcessingResult` | Processing status during operations | `SpreedlyCore/Core/Payment/PaymentProcessingResult.swift` |
| `ThreeDSChallengeResult` | 3DS challenge result | `SpreedlyCore/Core/Payment/ThreeDSChallengeResult.swift` |

### Delegate Protocols (Objective-C)

| Protocol | Purpose | Location |
|----------|---------|----------|
| `SpreedlyPaymentDelegate` | Payment result callbacks | `SpreedlyCore/Core/Spreedly.swift` |
| `SpreedlyThreeDSChallengeDelegate` | 3DS challenge result callbacks | `SpreedlyCore/Core/Spreedly.swift` |

### Configuration Classes

| Class | Purpose | Location |
|-------|---------|----------|
| `RecacheConfig` | CVV recaching configuration | `SpreedlyUI/Components/Recaching/Models/RecacheConfig.swift` |
| `SavedCardInfo` | Card information for recaching | `SpreedlyUI/Components/Recaching/Models/RecacheConfig.swift` |
| `FormField` | Additional field configuration | `SpreedlyCore/Core/Constants/FormFieldType.swift` |

### Enums

| Enum | Purpose | Location |
|------|---------|----------|
| `FormFieldType` | Available field types | `SpreedlyCore/Core/Constants/FormFieldType.swift` |
| `YearFormat` | Year format options (two-digit/four-digit) | `SpreedlyUI/Constants/YearFormat.swift` |
| `DropInNameDisplayMode` | Name field display mode | `SpreedlyUI/Constants/DropInNameDisplayMode.swift` |
| `ScreenPresentationMode` | CVV recaching presentation mode | `SpreedlyUI/Components/Recaching/Models/RecacheConfig.swift` |
| `SpreedlySubmitLabel` | Submit button label options | `SpreedlyCore/Core/Constants/FormFieldType.swift` |

### Important Notes

1. **All UIKit/Objective-C classes are wrappers** around SwiftUI components using `UIHostingController`
2. **Same implementation** - Both SwiftUI and UIKit classes use the same underlying SwiftUI views
3. **Result handling differs**:
   - SwiftUI/Swift: Use Combine subscriptions (`subscribeToPaymentResults()`, `subscribeToThreeDSChallengeResults()`)
   - Objective-C: Use delegate protocols (`SpreedlyPaymentDelegate`, `SpreedlyThreeDSChallengeDelegate`)
4. **No internal/private APIs exposed** - Only public merchant-facing classes are documented

For complete API details, parameters, and usage examples, see [MERCHANT_API_REFERENCE.md](MERCHANT_API_REFERENCE.md).

---

## Support Resources

- **SDK Documentation**: [GitHub Repository](https://github.com/spreedly/checkout-ios-sdk)
- **Spreedly API Docs**: [docs.spreedly.com](https://docs.spreedly.com/)
- **Example App**: Check the `Example/` directory for working implementations
- **GitHub Issues**: Report bugs and request features
- **Spreedly Support**: [spreedly.com/support](https://spreedly.com/support/)

For additional help or questions, please refer to the main [README.md](README.md) or create an issue in the GitHub repository.
