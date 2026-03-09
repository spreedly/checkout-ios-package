## [1.1.0] - 2026-03-09

### Release Type
**Minor Version** (New features - backward compatible)

### Changes
- HC-1223 fix Build Validation failures in test-and-lint CI workflow (#203)
- HC-1193: Add comprehensive documentation, expand test coverage, and cleanup SDK structure (#202)
- HC-1209: iOS optimize ci/cd time (#201)
- HC-1216 Migrate gateway-specific 3DS challenge from WKWebView to SFSafariViewController (#200)
- HC-1209: Optimize CI Workflows for CodeQL and Testing (#199)

### Change Requests
  - HC-1193
  - HC-1209
  - HC-1216
  - HC-1223

### PCI DSS Compliance
This release has been documented for PCI DSS compliance requirements:
- **Change Request Tracking**: All changes are tracked via Jira tickets (see above)
- **Version History**: Semantic versioning maintained (1.1.0 - Minor Version)
- **Security Validation**: All security scans and validations completed
- **SBOM**: Software Bill of Materials included in release artifacts
- **Audit Trail**: Complete release documentation available in this changelog

### Installation
```swift
// Swift Package Manager
.package(url: "https://github.com/spreedly/checkout-ios-package.git", from: "1.1.0")
```

```ruby
# CocoaPods
pod 'Spreedly', '~> 1.1.0'
```

---

# Changelog

All notable changes to the Spreedly iOS SDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Stripe APM Module** (`SpreedlyStripeAPM`): Stripe Alternative Payment Methods via native PaymentSheet
    - Supports iDEAL, Bancontact, EPS, P24, SEPA Debit
    - `SpreedlyStripeAPMCheckout` entry point with `StripeAPMConfig`
    - Backend-initiated flow: merchant creates purchase, SDK presents Stripe PaymentSheet
    - Automatic status polling after PaymentSheet completion
- **Braintree APM Module** (`SpreedlyBraintree`): Braintree PayPal and Venmo payments
    - `SpreedlyBraintreeCheckout` entry point with `BraintreeCheckoutConfig`
    - `BraintreePaymentType` enum for PayPal and Venmo selection
    - Nonce-based flow with merchant `/confirm.json` call
    - `BraintreeURLHandler` for deep link return handling
    - Full Objective-C support via `BraintreeURLHandlerObjC`
- **EBANX Offsite Payments**: Pix, Boleto Bancario, NuPay, NuPay Recurrent, OXXO, Rapipago via EBANX
    - Dedicated `OffsitePaymentMethodType` entries for each EBANX payment method
    - `DocumentId` support for EBANX-required customer identification
- **Gateway-Specific 3DS**: Gateway-managed 3D Secure authentication (e.g. Worldpay)
    - `GatewaySpecific3DSIntegration` for lifecycle management
    - Safari-based challenge presentation
    - Automatic status polling with device fingerprint handling
    - `GatewaySpecific3DSLifecycle` and `GatewaySpecific3DSEvent` models
- **Offsite Payment Integration**: Safari-based offsite payment flow for PayPal and Sprel
    - `SpreedlyOffsiteCheckout` with `SFSafariViewController` presentation
    - `handleOffsiteReturn(url:)` for universal link and custom scheme return handling
    - Dual `PaymentResult` delivery (initial token + completion status)
- **CVV Recaching**: `SpreedlyCVVRecachingView` for updating CVV on saved payment methods
    - Bottom sheet and dialog presentation modes via `ScreenPresentationMode`
    - `RecacheConfig` and `SavedCardInfo` for configuration
- **Screen Prevention**: `ScreenPreventionSecureView` blocks screenshots and screen recording for PCI compliance
- **Secure Value Container**: `SecureValueContainer` with AES-GCM encryption for sensitive card data lifecycle
- **Log Sanitization**: Automatic redaction of card numbers, tokens, and secrets in logs
- **Objective-C Support**: Full Objective-C compatibility via delegates, bridges, and `@objc` annotations
    - `SpreedlyPaymentDelegate`, `SpreedlyThreeDSChallengeDelegate`
    - `CardFormDropInViewController`, `SPLTextFieldViewController`, `CVVRecachingViewController`
    - `SPLThemeConfig`, `SpreedlyThemeManagerObjC`
- **Additional Fields**: Billing and shipping address fields passed directly to payment processing
    - `AdditionalField` enum with firstName, lastName, address, city, state, zip, country, phone, email, shipping fields
- **Card Brand Detection**: 50+ card brands with BIN pattern matching, Luhn validation, and brand-specific rules
    - Visa, Mastercard, Amex, Discover, JCB, Maestro, UnionPay, Elo, Dankort, Mada, Verve, and more
    - Custom validation algorithms for Naranja, Creditel, Passcard/Edenred
- **Theming**: Comprehensive theming system with light/dark mode support
    - `SpreedlyTheme` with colors, typography, spacing, border radius, shadows
    - Predefined `SpreedlyLightTheme` and `SpreedlyDarkTheme`
    - Dynamic Type and Bold Text accessibility support
- **Localization**: Localized strings for Core, UI, Braintree, and Stripe APM modules
- **DocC Documentation**: Documentation catalogs for SpreedlyCore, SpreedlyUI, SpreedlySecurity, and SpreedlyAnalytics

## [1.0.0] - 2026-03-08

### Added

- Initial release of Spreedly iOS SDK
- **SpreedlyCore**: Core payment processing, API client, 3DS (Forter global), models, and Combine publishers
- **SpreedlyUI**: Card form drop-in (`CardFormDropIn`), hosted fields (`SPLTextField`), card brand icons, validation
- **SpreedlySecurity**: AES-GCM encryption (`SPLSecurity`), secure value storage (`SecureValueContainer`)
- **SpreedlyAnalytics**: Logging and observability
- Swift Package Manager and CocoaPods distribution via `checkout-ios-package`
- Example app with SwiftUI and Objective-C demonstrations

### Compatibility

- iOS 14.0+ (minimum deployment target)
- Swift 5.10+
- Xcode 16.1+

---

## Versioning

This project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html):

- **MAJOR** version for incompatible API changes
- **MINOR** version for backwards-compatible functionality additions
- **PATCH** version for backwards-compatible bug fixes

### Support

- **Minimum iOS**: 14.0
- **Swift**: 5.10+
- **Xcode**: 16.1+

For detailed integration guides, see the [documentation index](README.md).
