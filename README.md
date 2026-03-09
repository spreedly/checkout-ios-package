# Spreedly iOS SDK

[![GitHub Package](https://img.shields.io/badge/GitHub%20Package-1.1.0-blue)](https://github.com/spreedly/checkout-ios-package/releases)
[![iOS](https://img.shields.io/badge/iOS-14.0%2B-brightgreen.svg?style=flat)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.10-blue.svg?style=flat&logo=swift)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-Compatible-blue)](https://developer.apple.com/xcode/swiftui/)

A modern iOS SDK for integrating Spreedly payment processing into iOS applications. Built
with Swift, SwiftUI, and following iOS best practices.

## Installation

### Swift Package Manager (Recommended)

#### In Xcode

1. Go to **File → Add Package Dependencies**
2. Enter the repository URL:
   ```
   https://github.com/spreedly/checkout-ios-package
   ```
3. Select the modules you need (see [Modules](#modules) below)

#### In Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/spreedly/checkout-ios-package", from: "1.1.0")
]
```

Then add the products to your target:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "SpreedlyCore", package: "checkout-ios-package"),
        .product(name: "SpreedlySecurity", package: "checkout-ios-package"),
        .product(name: "SpreedlyUI", package: "checkout-ios-package"),
    ]
)
```

### CocoaPods

```ruby
# Podfile
pod 'SpreedlyCore', '~> 1.1'
pod 'SpreedlySecurity', '~> 1.1'
pod 'SpreedlyUI', '~> 1.1'

# Optional — add as needed
# pod 'SpreedlyStripeAPM', '~> 1.1'
# pod 'SpreedlyBraintree', '~> 1.1'
```

**Private repository access:** If the SDK is distributed via a private GitHub repository, use the `:git` option with a [personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens):

```ruby
# Podfile — private repo via Git token
pod 'SpreedlyCore',      :git => 'https://{GitToken}@github.com/spreedly/checkout-ios-package.git'
pod 'SpreedlySecurity',  :git => 'https://{GitToken}@github.com/spreedly/checkout-ios-package.git'
pod 'SpreedlyUI',        :git => 'https://{GitToken}@github.com/spreedly/checkout-ios-package.git'

# Optional — add as needed
# pod 'SpreedlyStripeAPM', :git => 'https://{GitToken}@github.com/spreedly/checkout-ios-package.git'
# pod 'SpreedlyBraintree', :git => 'https://{GitToken}@github.com/spreedly/checkout-ios-package.git'
```

Replace `{GitToken}` with your GitHub personal access token that has read access to the repository.

## Modules

| Module | Product | Description |
|--------|---------|-------------|
| **Core** | `SpreedlyCore` | Core payment processing, API client, 3DS, offsite payments (required) |
| **Security** | `SpreedlySecurity` | Encryption and secure field storage (required) |
| **UI** | `SpreedlyUI` | Pre-built payment forms and hosted field components (required) |
| **Stripe APM** | `SpreedlyStripeAPM` | Stripe APM via native PaymentSheet (iDEAL, Bancontact, EPS, P24, SEPA) |
| **Braintree** | `SpreedlyBraintree` | Braintree PayPal and Venmo payments |

## Integration Guides

Get started quickly with the [Getting Started Guide](docs/guides/getting-started.md), then follow the guide for your use case:

### Payments

- **[Getting Started](docs/guides/getting-started.md)** -- Install, initialize, and process your first payment
- **[Recaching](docs/guides/recaching.md)** -- Update CVV for saved payment methods
- **[Error Handling](docs/guides/error-handling.md)** -- Handle payment errors and edge cases

### Offsite & Alternative Payment Methods

- **[Offsite Payments](docs/guides/offsite-payments.md)** -- Sprel, PayPal, and EBANX via Safari
- **[EBANX APM](docs/guides/ebanx-apm.md)** -- Pix, Boleto, OXXO, NuPay, Rapipago via EBANX
- **[Stripe APM](docs/guides/stripe-apm.md)** -- iDEAL, Bancontact, EPS, P24, SEPA via native Stripe PaymentSheet
- **[Braintree APM](docs/guides/braintree-apm.md)** -- PayPal and Venmo via Braintree

### 3D Secure (3DS) Authentication

- **[Global 3DS](docs/guides/3ds-global.md)** -- Forter-powered 3DS authentication
- **[Gateway-Specific 3DS](docs/guides/3ds-gateway-specific.md)** -- Gateway-managed 3DS authentication (e.g. Worldpay)

### Customization

- **[Express Checkout](docs/guides/express-checkout.md)** -- Pre-built CardFormDropIn payment form
- **[Custom Payment Forms](docs/guides/custom-payment-forms.md)** -- Build custom payment forms with SPLTextField
- **[Theme & Styling](docs/guides/theme-and-styling.md)** -- Customize colors, typography, and dark mode
- **[Security](docs/guides/security.md)** -- Screen prevention and PCI compliance
- **[Objective-C](docs/guides/objective-c.md)** -- Objective-C integration with delegates and wrappers

## Compatibility

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| iOS | 14.0 | 18 |
| Swift | 5.10 | 5.10 |
| Xcode | 16.1 | 16.4 |

### Architecture Support

- **arm64**: Native support for all modern iOS devices
- **x86_64**: Simulator support for Intel Macs
- **Universal Binaries**: Pre-built frameworks support both architectures

## Features

- **Secure Payment Processing** -- Tokenized payment methods via Spreedly's infrastructure
- **Offsite Payments** -- PayPal, Sprel, and EBANX (Pix, Boleto, OXXO, NuPay) via Safari
- **Stripe APM** -- iDEAL, Bancontact, EPS, P24, SEPA via native Stripe PaymentSheet
- **Braintree APM** -- PayPal and Venmo payments
- **3D Secure** -- Forter/Global and Gateway-Specific 3DS
- **CVV Recaching** -- Update CVV for saved payment methods
- **Modern UI** -- SwiftUI with extensive theming and dark mode support
- **Express Checkout & Hosted Fields** -- Flexible integration options
- **UIKit & Objective-C** -- Full support for UIKit-based and Objective-C apps
- **Security** -- TLS certificate pinning, screen prevention, encrypted fields

## Known Issues

- **3DS is not a separate module:** Unlike the Android SDK (which publishes `checkout-threeds` as a standalone module), 3DS/Forter support on iOS is embedded within `SpreedlyCore` via weak linking. Merchants must add `Forter3DS` as a direct dependency to their app target for 3DS to function. Extracting 3DS into a dedicated `SpreedlyThreeDS` module is planned for a future release.

- **Release manifest does not cover all modules:** Checksum verification currently covers the three core frameworks (`SpreedlyCore`, `SpreedlySecurity`, `SpreedlyUI`). The optional modules (`SpreedlyStripeAPM`, `SpreedlyBraintree`) are not yet included. Extending the manifest to all published modules is tracked as future work.

- **No GPG artifact signing:** The Android SDK signs release artifacts with GPG. The iOS SDK currently relies on SHA-256 checksums for integrity verification. GPG signing is planned for a future release.

## Support

- **Spreedly Documentation**: [docs.spreedly.com](https://docs.spreedly.com/)
- **Support Portal**: [spreedly.com/support](https://spreedly.com/support/)
- **GitHub Issues**: [Bug reports and feature requests](https://github.com/spreedly/checkout-ios-sdk/issues)
- **Package Verification**: [PACKAGE_VERIFICATION.md](PACKAGE_VERIFICATION.md)
- **Changelog**: [CHANGELOG.md](CHANGELOG.md)

## License

Copyright 2026 Spreedly, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
