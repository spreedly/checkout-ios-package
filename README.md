# Spreedly iOS SDK Distribution

This repository contains pre-built frameworks for the Spreedly iOS SDK, designed for easy integration into iOS applications via Swift Package Manager or CocoaPods.

## 🚀 Quick Start

### Swift Package Manager (Recommended)

Add this to your `Package.swift` dependencies:

```swift
.package(url: "https://github.com/your-org/checkout-ios-package.git", from: "1.0.0")
```

Or add it via Xcode:
1. File → Add Package Dependencies...
2. Enter: `https://github.com/your-org/checkout-ios-package.git`
3. Choose your desired version

Then import the modules you need:

```swift
import SpreedlyCore      // Core functionality and networking
import SpreedlySecurity  // Security and encryption features
import SpreedlyUI        // UI components for payment forms
// Or import everything at once:
import Spreedly
```

### CocoaPods

Add this to your `Podfile`:

```ruby
source 'https://github.com/your-org/checkout-ios-package.git'

# Install all modules
pod 'Spreedly', '~> 1.0'

# Or choose specific modules:
# pod 'Spreedly/Core'      # Core functionality only
# pod 'Spreedly/Security'  # Core + Security
# pod 'Spreedly/UI'        # Core + UI components

# pod 'Spreedly/Full'      # All modules
```

Then run:
```bash
pod install
```

## 📋 Requirements

- **iOS**: 13.0+
- **Swift**: 6.1+
- **Xcode**: 15.4+

## 🏗 Architecture

### Modules

- **SpreedlyCore**: Foundation module containing core payment processing functionality and networking layer
- **SpreedlySecurity**: Security utilities and encryption features
- **SpreedlyUI**: Ready-to-use UI components for payment forms


### Dependencies

```
SpreedlySecurity  ─┬── SpreedlyCore
SpreedlyUI        ─┘
```

All modules depend on `SpreedlyCore`, allowing you to use them individually or in combination.

## 📁 Repository Structure

```
├── Frameworks/               # Pre-built .framework files for CocoaPods
│   ├── SpreedlyCore.framework
│   ├── SpreedlySecurity.framework
│   └── SpreedlyUI.framework
├── Package.swift            # Swift Package Manager configuration
├── Spreedly.podspec         # CocoaPods specification
└── *.zip + *.sha256        # Individual framework archives and checksums
```

## 🔧 Usage Examples

### Basic Payment Processing

```swift
import SpreedlyCore

// Configure Spreedly
let config = SpreedlyConfig(
    environmentKey: "your-environment-key",
    gateway: "your-gateway"
)

// Create payment method
let paymentData = PaymentMethodData(
    creditCard: CreditCardData(
        number: "4111111111111111",
        cvv: "123",
        month: "12",
        year: "2025"
    )
)

Spreedly.shared.createPaymentMethod(paymentData) { result in
    switch result {
    case .success(let response):
        print("Payment method created: \(response.token)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

### Using UI Components

```swift
import SpreedlyCore
import SpreedlyUI

// Use the pre-built card form
let cardForm = CardFormDropIn()
cardForm.configure(with: config)

// Present the form
present(cardForm, animated: true)
```

### Security Features

```swift
import SpreedlySecurity

// Encrypt sensitive data
let encrypted = SpreedlySecurity.encrypt("sensitive-data")

// Store in secure container
let container = SecureValueContainer()
container.store(value: encrypted, forKey: "payment-token")
```

## 🔒 Security

This SDK implements industry-standard security practices:

- **End-to-end encryption** for sensitive payment data
- **SSL certificate pinning** for network communications
- **Secure storage** for tokens and sensitive information
- **PCI DSS compliance** ready architecture



```swift

```

## 🚨 Migration from Source-based Integration

If you were previously using the source-based SDK:

1. **Remove** the old source dependency
2. **Add** this package repository as a dependency
3. **Update** import statements (module names remain the same)
4. **Rebuild** your project

No code changes are required - only the dependency source changes.

## 🐛 Troubleshooting

### Swift Package Manager Issues

**Problem**: Package resolution fails
```
Solution: Try cleaning the package cache:
File → Swift Packages → Reset Package Caches
```

**Problem**: Binary target checksum mismatch
```
Solution: This usually means the release was updated. 
Try removing and re-adding the package dependency.
```

### CocoaPods Issues

**Problem**: Pod not found
```bash
# Clear CocoaPods cache
pod cache clean --all
pod repo update
```

**Problem**: Framework not found during build
```
Solution: Ensure you're opening the .xcworkspace file, not .xcodeproj
```

## 🔢 Versioning

This package follows [Semantic Versioning (SemVer)](https://semver.org/):
- **Major** (x.0.0): Breaking changes
- **Minor** (0.x.0): New features (backward compatible)  
- **Patch** (0.0.x): Bug fixes (backward compatible)

Versions are automatically created based on commit messages in the source repository:
- `feat:`, `feature:`, `add:` → Minor version bump
- `fix:`, `bug:`, `patch:` → Patch version bump
- `BREAKING CHANGE`, `major:` → Major version bump

## 📝 Changelog

See [Releases](https://github.com/your-org/checkout-ios-package/releases) for version history and updates.

## 🤝 Support

For issues related to:
- **Framework integration**: Open an issue in this repository
- **SDK functionality**: Contact Spreedly support at support@spreedly.com
- **Source code**: See the [source repository](https://github.com/your-org/checkout-ios-sdk)

## 📄 License

See LICENSE file for details.

---

**Note**: This is a private repository containing pre-built frameworks. The source code is maintained separately in the main SDK repository.