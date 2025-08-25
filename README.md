# checkout-ios-package

## Table of Contents

1. [Overview](#overview)
2. [Installation](#installation)
3. [Quick Start](#quick-start)
4. [Framework Architecture](#framework-architecture)
5. [Core Framework](#core-framework)
6. [UI Framework](#ui-framework)
7. [Configuration](#configuration)
8. [Implementation Examples](#implementation-examples)
9. [Customization](#customization)
10. [Error Handling](#error-handling)
11. [Best Practices](#best-practices)
12. [API Reference](#api-reference)

## Overview

The Spreedly iOS SDK provides a comprehensive payment processing solution with a modular architecture. It consists of multiple frameworks that can be used independently or together:

- **SpreedlyCore**: Core payment processing functionality
- **SpreedlyUI**: Pre-built UI components for payment forms
- **SpreedlySecurity**: Security and encryption features

## Installation

### CocoaPods

Add the following to your `Podfile`:

```ruby
# For all frameworks
pod 'Spreedly/Full'

# Or for specific frameworks
pod 'Spreedly/Core'
pod 'Spreedly/UI'
pod 'Spreedly/Security'
```

### Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/spreedly/spreedly-sdk-ios.git", from: "1.0.0")
]
```

## Quick Start

### 1. Initialize Spreedly

```swift
import SpreedlyCore

// Basic initialization with environment key
Spreedly.setup(environmentKey: "YOUR_ENVIRONMENT_KEY")

// Or with full configuration
let config = SpreedlyConfig(
    environmentKey: "YOUR_ENVIRONMENT_KEY",
    certificateToken: "CERTIFICATE_TOKEN",
    nonce: "NONCE",
    signature: "SIGNATURE",
    timestamp: "TIMESTAMP"
)
Spreedly.setup(config: config)
```

### 2. Use the Drop-in Form

```swift
import SpreedlyUI
import SwiftUI

struct PaymentView: View {
    @State private var showPaymentForm = false
    
    var body: some View {
        Button("Pay Now") {
            showPaymentForm = true
        }
        .sheet(isPresented: $showPaymentForm) {
            CardFormDropIn(
                onSubmit: { result in
                    print("Payment successful: \(result.transactionToken ?? "")")
                },
                onError: { error in
                    print("Payment failed: \(error)")
                }
            )
        }
    }
}
```

## Framework Architecture

### Module Dependencies

```
SpreedlyUI
├── SpreedlyCore
└── SpreedlySecurity

SpreedlyCore
└── SpreedlySecurity
```

### Key Components

- **Spreedly**: Main singleton class for payment processing
- **SpreedlyConfig**: Configuration class for SDK setup
- **CardFormDropIn**: SwiftUI component for payment forms
- **CardFormDropInViewController**: UIKit wrapper for payment forms
- **CheckoutResult**: Result object containing payment tokens

## Core Framework

### Spreedly Class

The main entry point for payment processing.

#### Initialization

```swift
// Basic setup
Spreedly.setup(environmentKey: "YOUR_ENVIRONMENT_KEY")

// Advanced setup with configuration
let config = SpreedlyConfig(
    environmentKey: "YOUR_ENVIRONMENT_KEY",
    certificateToken: "CERTIFICATE_TOKEN",
    nonce: "NONCE",
    signature: "SIGNATURE",
    timestamp: "TIMESTAMP"
)
Spreedly.setup(config: config)

// Access shared instance
let spreedly = Spreedly.shared()
```

#### Payment Processing

```swift
// Create credit card payment
let result = try await Spreedly.shared().createCreditCard(
    additionalFields: [:],
    metadata: ["order_id": "12345"],
    allowBlankName: false,
    allowExpiredDate: false
)

if result.success {
    print("Transaction Token: \(result.transactionToken ?? "")")
    print("Payment Method Token: \(result.paymentMethodToken ?? "")")
} else {
    print("Error: \(result.error ?? "")")
}
```

### SpreedlyConfig

Configuration class for SDK setup.

```swift
@objcMembers public class SpreedlyConfig: NSObject, SpreedlyConfigGenerator {
    public var environmentKey: String?
    public var certificateToken: String?
    public var nonce: String?
    public var signature: String?
    public var timestamp: String?
    
    public init(
        environmentKey: String,
        certificateToken: String? = nil,
        nonce: String? = nil,
        signature: String? = nil,
        timestamp: String? = nil
    )
}
```

### CheckoutResult

Result object returned from payment processing.

```swift
@objcMembers public class CheckoutResult: NSObject {
    public var transactionToken: String?
    public var paymentMethodToken: String?
    public var success: Bool
    public var message: String?
    public var error: String?
}
```

## UI Framework

### CardFormDropIn (SwiftUI)

A complete payment form component with built-in validation and styling.

#### Basic Usage

```swift
import SwiftUI
import SpreedlyUI

struct PaymentView: View {
    @State private var showForm = false
    
    var body: some View {
        CardFormDropIn(
            onSubmit: { result in
                // Handle successful payment
                print("Payment successful: \(result.transactionToken ?? "")")
            },
            onError: { error in
                // Handle payment error
                print("Payment failed: \(error)")
            }
        )
    }
}
```

#### Advanced Configuration

```swift
CardFormDropIn(
    otherFields: [
        FormField(id: "addressLine1", title: "Address", type: .addressLine1),
        FormField(id: "city", title: "City", type: .city),
        FormField(id: "state", title: "State", type: .state),
        FormField(id: "zipCode", title: "Zip Code", type: .zipCode)
    ],
    allowBlankName: false,
    allowExpiredDate: false,
    yearFormat: .fourDigit,
    onSubmit: { result in
        // Handle success
    },
    onError: { error in
        // Handle error
    }
)
```

### CardFormDropInViewController (UIKit)

UIKit wrapper for the SwiftUI component.

```swift
import UIKit
import SpreedlyUI

class PaymentViewController: UIViewController {
    
    func showPaymentForm() {
        let dropInVC = CardFormDropInViewController()
        
        dropInVC.allowBlankName = false
        dropInVC.allowExpiredDate = false
        dropInVC.yearFormat = .fourDigit
        
        dropInVC.onSubmit = { result in
            // Handle successful payment
            self.dismiss(animated: true)
        }
        
        dropInVC.onError = { error in
            // Handle payment error
            self.dismiss(animated: true)
        }
        
        present(dropInVC, animated: true)
    }
}
```

### FormField

Custom field configuration for the payment form.

```swift
public class FormField: NSObject {
    public let id: String
    public let title: String
    public let placeholder: String
    public let type: FormFieldType
    public let isRequired: Bool
    
    public init(
        id: String,
        title: String,
        type: FormFieldType,
        placeholder: String? = nil,
        isRequired: Bool = true
    )
}
```

### FormFieldType

Available field types for the payment form.

```swift
public enum FormFieldType {
    case cardNumber
    case fullName
    case firstName
    case lastName
    case expirationDate
    case expirationMonth
    case expirationYear
    case cvc
    case addressLine1
    case addressLine2
    case city
    case state
    case zipCode
}
```

## Configuration

### Environment Setup

1. **Get Environment Key**: Obtain your Spreedly environment key from the Spreedly dashboard.

2. **Basic Setup**: For simple implementations, use basic setup with just the environment key.

3. **Advanced Setup**: For production applications, implement server-side signature generation.

### Server-Side Signature Generation

For enhanced security, implement server-side signature generation:

```swift
// Example configuration manager
class SpreedlyConfigManager {
    static var shared: SpreedlyConfigManager!
    private let environmentKey: String = "YOUR_ENVIRONMENT_KEY"
    private let serverURL: String = "YOUR_SERVER_URL"
    
    private init() {
        Spreedly.setup(environmentKey: environmentKey)
    }
    
    static func setup() {
        shared = SpreedlyConfigManager()
    }
    
    func generateSignature() async -> Result<Bool, Error> {
        // Implement server-side signature generation
        // Update Spreedly configuration with signature parameters
        return .success(true)
    }
}
```

## Implementation Examples

### SwiftUI Implementation

```swift
import SwiftUI
import SpreedlyCore
import SpreedlyUI

struct PaymentView: View {
    @State private var showPaymentForm = false
    @State private var paymentResult: CheckoutResult?
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            Button("Pay Now") {
                showPaymentForm = true
            }
            .padding()
            
            if let result = paymentResult {
                VStack {
                    Text("Payment Successful!")
                        .foregroundColor(.green)
                    Text("Transaction: \(result.transactionToken ?? "")")
                        .font(.caption)
                }
                .padding()
            }
            
            if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .sheet(isPresented: $showPaymentForm) {
            CardFormDropIn(
                allowBlankName: false,
                allowExpiredDate: false,
                yearFormat: .fourDigit,
                onSubmit: { result in
                    paymentResult = result
                    errorMessage = nil
                    showPaymentForm = false
                },
                onError: { error in
                    errorMessage = error
                    paymentResult = nil
                }
            )
        }
    }
}
```

### UIKit Implementation

```swift
import UIKit
import SpreedlyCore
import SpreedlyUI

class PaymentViewController: UIViewController {
    
    @IBAction func payButtonTapped(_ sender: UIButton) {
        showPaymentForm()
    }
    
    private func showPaymentForm() {
        let dropInVC = CardFormDropInViewController()
        
        dropInVC.allowBlankName = false
        dropInVC.allowExpiredDate = false
        dropInVC.yearFormat = .fourDigit
        
        dropInVC.onSubmit = { [weak self] result in
            self?.handlePaymentSuccess(result)
        }
        
        dropInVC.onError = { [weak self] error in
            self?.handlePaymentError(error)
        }
        
        present(dropInVC, animated: true)
    }
    
    private func handlePaymentSuccess(_ result: CheckoutResult) {
        dismiss(animated: true) {
            // Show success message
            let alert = UIAlertController(
                title: "Payment Successful",
                message: "Transaction: \(result.transactionToken ?? "")",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    private func handlePaymentError(_ error: String) {
        dismiss(animated: true) {
            // Show error message
            let alert = UIAlertController(
                title: "Payment Failed",
                message: error,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}
```

### Objective-C Implementation

```objc
#import "PaymentViewController.h"
#import <SpreedlyCore/SpreedlyCore-Swift.h>
#import <SpreedlyUI/SpreedlyUI-Swift.h>

@implementation PaymentViewController

- (IBAction)payButtonTapped:(UIButton *)sender {
    [self showPaymentForm];
}

- (void)showPaymentForm {
    CardFormDropInViewController *dropInVC = [[CardFormDropInViewController alloc] init];
    
    dropInVC.allowBlankName = NO;
    dropInVC.allowExpiredDate = NO;
    dropInVC.yearFormat = YearFormatFourDigit;
    
    dropInVC.onSubmit = ^(CheckoutResult *result) {
        [self handlePaymentSuccess:result];
    };
    
    dropInVC.onError = ^(NSString *error) {
        [self handlePaymentError:error];
    };
    
    [self presentViewController:dropInVC animated:YES completion:nil];
}

- (void)handlePaymentSuccess:(CheckoutResult *)result {
    [self dismissViewControllerAnimated:YES completion:^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Payment Successful"
                                                                       message:[NSString stringWithFormat:@"Transaction: %@", result.transactionToken ?: @""]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (void)handlePaymentError:(NSString *)error {
    [self dismissViewControllerAnimated:YES completion:^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Payment Failed"
                                                                       message:error
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

@end
```

## Customization

### Theme Customization

The SDK provides a comprehensive theming system for customizing the appearance of UI components.

#### Using Predefined Themes

```swift
import SpreedlyUI

struct PaymentView: View {
    var body: some View {
        CardFormDropIn(
            onSubmit: { result in
                // Handle success
            },
            onError: { error in
                // Handle error
            }
        )
        .spreedlyTheme(SpreedlyLightTheme()) // or SpreedlyDarkTheme()
    }
}
```

#### Creating Custom Themes

```swift
let customTheme = SpreedlyCustomTheme(
    colors: SpreedlyColors(
        primary: Color(hex: "#0077C8"),
        secondary: Color(hex: "#AFB4B5"),
        accent: Color(hex: "#FF9500"),
        background: Color(hex: "#FFFFFF"),
        surface: Color(hex: "#FFFFFF"),
        text: Color(hex: "#000000"),
        textSecondary: Color(hex: "#6C757D"),
        border: Color(hex: "#D9D9D9"),
        error: Color(hex: "#DC3545"),
        success: Color(hex: "#28A745"),
        warning: Color(hex: "#FFC107"),
        disabled: Color(hex: "#ADB5BD"),
        placeholder: Color(hex: "#AFB4B5")
    ),
    typography: SpreedlyTypography(
        titleFont: .system(size: 32, weight: .bold, design: .rounded),
        subtitleFont: .system(size: 18, weight: .semibold, design: .rounded),
        bodyFont: .system(size: 16, weight: .regular, design: .rounded),
        captionFont: .system(size: 12, weight: .regular, design: .rounded),
        buttonFont: .system(size: 20, weight: .bold, design: .rounded),
        fieldFont: .system(size: 18, design: .rounded)
    ),
    spacing: SpreedlySpacing(
        xs: 4,
        sm: 8,
        md: 16,
        lg: 24,
        xl: 32,
        xxl: 48
    ),
    borderRadius: SpreedlyBorderRadius(
        xs: 4,
        sm: 6,
        md: 8,
        lg: 12,
        xl: 16
    ),
    shadows: SpreedlyShadows(
        small: Shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1),
        medium: Shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2),
        large: Shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    )
)

CardFormDropIn(
    onSubmit: { result in
        // Handle success
    },
    onError: { error in
        // Handle error
    }
)
.spreedlyTheme(customTheme)
```

### Card Type Detection

The SDK includes built-in card type detection and validation.

```swift
import SpreedlyUI

// Detect card type from card number
let cardType = CardTypeDetector.detectCardType(from: "4111111111111111")
print("Card type: \(cardType.displayName)")

// Validate card number
let validationResult = CardTypeDetector.validateCard("4111111111111111")
if validationResult.isValid {
    print("Card is valid")
} else {
    print("Card validation errors: \(validationResult.errors)")
}

// Format card number
let formattedNumber = CardTypeDetector.formatCardNumber("4111111111111111")
print("Formatted: \(formattedNumber)") // "4111 1111 1111 1111"
```

### Year Format Configuration

Configure the expiration year format for the payment form.

```swift
CardFormDropIn(
    yearFormat: .twoDigit, // Shows YY format
    onSubmit: { result in
        // Handle success
    },
    onError: { error in
        // Handle error
    }
)

// Or for 4-digit year format
CardFormDropIn(
    yearFormat: .fourDigit, // Shows YYYY format
    onSubmit: { result in
        // Handle success
    },
    onError: { error in
        // Handle error
    }
)
```

## Error Handling

### Error Types

The SDK provides comprehensive error handling for various scenarios:

1. **Network Errors**: Connection issues, timeouts, server errors
2. **Validation Errors**: Invalid card data, missing required fields
3. **Configuration Errors**: Invalid environment key, missing signature
4. **Payment Errors**: Declined transactions, insufficient funds

### Error Handling Example

```swift
CardFormDropIn(
    onSubmit: { result in
        if result.success {
            // Handle successful payment
            print("Transaction Token: \(result.transactionToken ?? "")")
        } else {
            // Handle payment failure
            print("Payment failed: \(result.error ?? "")")
        }
    },
    onError: { error in
        // Handle form validation or network errors
        print("Error: \(error)")
        
        // Show user-friendly error message
        showAlert(title: "Payment Error", message: error)
    }
)
```

### Field-Level Error Handling

The SDK provides field-level error handling for validation issues:

```swift
// Access field errors through the error handler
let spreedly = Spreedly.shared()
let fieldErrors = spreedly.errorHandler.fieldErrors

// Check for specific field errors
if let cardNumberError = fieldErrors["cardNumber"] {
    print("Card number error: \(cardNumberError)")
}

// Check for general errors
if let generalError = spreedly.errorHandler.generalError {
    print("General error: \(generalError)")
}

// Clear all errors
spreedly.errorHandler.clearAllErrors()
```

## Best Practices

### Security

1. **Environment Key**: Never hardcode environment keys in your app. Use secure configuration management.

2. **Server-Side Signature**: Implement server-side signature generation for production applications.

3. **Data Handling**: Never log or store sensitive payment data.

4. **Network Security**: Use HTTPS for all API communications.

### Performance

1. **Lazy Loading**: Initialize Spreedly only when needed.

2. **Memory Management**: Properly handle view controller lifecycles.

3. **Error Recovery**: Implement proper error recovery mechanisms.

### User Experience

1. **Loading States**: Show appropriate loading indicators during payment processing.

2. **Error Messages**: Display user-friendly error messages.

3. **Validation Feedback**: Provide immediate feedback for form validation.

4. **Accessibility**: Ensure your implementation is accessible to all users.

### Code Organization

1. **Separation of Concerns**: Keep payment logic separate from UI logic.

2. **Configuration Management**: Centralize configuration management.

3. **Error Handling**: Implement consistent error handling across your app.

4. **Testing**: Write unit tests for payment logic.

## API Reference

### Spreedly

#### Class Methods

```swift
// Initialize with environment key
static func setup(environmentKey: String)

// Initialize with configuration
static func setup(config: SpreedlyConfigGenerator)

// Get shared instance
static func shared() -> Spreedly
```

#### Instance Methods

```swift
// Create credit card payment
func createCreditCard(
    additionalFields: [String: String] = [:],
    metadata: [String: String]? = nil,
    allowBlankName: Bool = false,
    allowExpiredDate: Bool = false
) async throws -> CheckoutResult

// Update configuration
func setConfig(config: SpreedlyConfigGenerator)

// Reset SDK state
func reset()
```

### SpreedlyConfig

#### Properties

```swift
var environmentKey: String?
var certificateToken: String?
var nonce: String?
var signature: String?
var timestamp: String?
```

#### Initializer

```swift
init(
    environmentKey: String,
    certificateToken: String? = nil,
    nonce: String? = nil,
    signature: String? = nil,
    timestamp: String? = nil
)
```

### CheckoutResult

#### Properties

```swift
var transactionToken: String?
var paymentMethodToken: String?
var success: Bool
var message: String?
var error: String?
```

### CardFormDropIn

#### Initializer

```swift
init(
    otherFields: [FormField] = [],
    allowBlankName: Bool = false,
    allowExpiredDate: Bool = false,
    yearFormat: YearFormat = .fourDigit,
    onSubmit: ((CheckoutResult) -> Void)? = nil,
    onError: ((String) -> Void)? = nil
)
```

### CardFormDropInViewController

#### Properties

```swift
var allowBlankName: Bool
var allowExpiredDate: Bool
var yearFormat: YearFormat
var onSubmit: ((CheckoutResult) -> Void)?
var onError: ((String) -> Void)?
```

### FormField

#### Properties

```swift
let id: String
let title: String
let placeholder: String
let type: FormFieldType
let isRequired: Bool
```

#### Initializer

```swift
init(
    id: String,
    title: String,
    type: FormFieldType,
    placeholder: String? = nil,
    isRequired: Bool = true
)
```

### CardTypeDetector

#### Class Methods

```swift
// Detect card type
static func detectCardType(from cardNumber: String) -> CardType

// Validate card number
static func validateCard(_ cardNumber: String) -> CardValidationResult

// Format card number
static func formatCardNumber(_ cardNumber: String) -> String

// Validate Luhn algorithm
static func isValidLuhn(_ cardNumber: String) -> Bool
```

### Theme System

#### SpreedlyTheme Protocol

```swift
protocol SpreedlyTheme {
    var colors: SpreedlyColors { get }
    var typography: SpreedlyTypography { get }
    var spacing: SpreedlySpacing { get }
    var borderRadius: SpreedlyBorderRadius { get }
    var shadows: SpreedlyShadows { get }
}
```

#### Predefined Themes

```swift
SpreedlyLightTheme()
SpreedlyDarkTheme()
SpreedlyCustomTheme()
```

---

## Support

For technical support and questions:

- **Email**: support@spreedly.com
- **Documentation**: [Spreedly Developer Portal](https://docs.spreedly.com)
- **GitHub**: [Spreedly iOS SDK Repository](https://github.com/spreedly/spreedly-sdk-ios)

## License

This SDK is licensed under the terms specified in the LICENSE file included with the SDK distribution. 
