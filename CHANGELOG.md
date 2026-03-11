# Changelog

All notable changes to the Spreedly iOS SDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

> **PCI DSS Compliance:** All releases are documented for PCI DSS compliance. Changes are tracked via Jira tickets (HC-prefixed), security scans are completed before each release, and a Software Bill of Materials (`sbom.json`) is included in release artifacts.

## [Unreleased]

No unreleased changes.

## [1.1.4] - 2026-03-11

### Changed
- HC-1233 audit fixes: version consistency, SBOM updates, documentation sync, PCI compliance improvements

## [1.1.3] - 2026-03-09

### Changed
- HC-1223 fix TestFlight validation by removing nested framework embed from SPLAccessibility (#207)

## [1.1.2] - 2026-03-09

### Changed
- HC-1223 fix Xcode Cloud build by migrating to SPM and generating xcconfig on CI (#206)

## [1.1.1] - 2026-03-09

### Changed
- HC-1223 update version references and documentation for 1.1.0 release (#205)

## [1.1.0] - 2026-03-09

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
- **Theming**: Full theming system with light/dark mode support
    - `SpreedlyTheme` with colors, typography, spacing, border radius, shadows
    - Predefined `SpreedlyLightTheme` and `SpreedlyDarkTheme`
    - Dynamic Type and Bold Text accessibility support
- **Localization**: Localized strings for Core, UI, Braintree, and Stripe APM modules
- **DocC Documentation**: Documentation catalogs for SpreedlyCore, SpreedlyUI, SpreedlySecurity, and SpreedlyAnalytics

### Security

- Removed hardcoded Datadog client token from source; now injected at build time via CI secret
- Extended `LogSanitizer` to cover 13-19 digit PANs, expiry dates, environment keys, JSON card payloads, and phone numbers
- Added `clearSensitiveData()` on `CreditCardDataImpl` to zero PAN, CVV, and expiry after API calls
- Changed `encryptAES()` to return `nil` on failure instead of empty string for fail-safe handling
- Masked payment tokens in all example app views using `maskedToken()`
- Sanitized error messages via `sanitizeForDisplay()` / `LogSanitizer` before logging or UI display
- Added error logging when `SecureValueContainer` encryption fails

### Changed

- HC-1223 fix Build Validation failures in test-and-lint CI workflow (#203)
- HC-1193: Add expanded documentation, expand test coverage, and cleanup SDK structure (#202)
- HC-1209: iOS optimize ci/cd time (#201)
- HC-1216 Migrate gateway-specific 3DS challenge from WKWebView to SFSafariViewController (#200)
- HC-1209: Optimize CI Workflows for CodeQL and Testing (#199)
- Datadog initialization now skips gracefully when no client token is configured (local/debug builds)
- `SecureValueContainer.registerValue` guards against encryption failure with diagnostic logging
- Improved thread safety in `GatewaySpecific3DSLifecycle` with dedicated `NSLock` for state transitions
- Extracted `insertProcessingToken` / `removeProcessingToken` helpers in `Spreedly` for safer lock usage
- Fixed expiration date two-digit year pivot (years 50-99 now map to 1900s)
- Replaced deprecated `UIApplication.shared.windows` with `connectedScenes` in theme detection
- Canceled previous Stripe APM checkout before presenting a new one to prevent stale state
- Downgraded swift-tools-version from 6.1 to 6.0 for broader compatibility

### Documentation

- Updated security guide with os_log persistence warnings, third-party SDK logging guidance, and `rawErrorResponse` handling
- Recommended `.none` log level for production builds
- Updated CocoaPods install examples to `~> 1.1` across README and getting-started guide
- Fixed broken markdown link in Stripe flow doc
- Removed outdated migration guide from SpreedlyUI DocC catalog
- Added CVV recaching accessibility hints

### Change Requests
  - HC-1193
  - HC-1209
  - HC-1216
  - HC-1223
  - HC-1231
  - HC-1233

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
