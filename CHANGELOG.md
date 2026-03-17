## [1.2.1] - 2026-03-17

### Release Type
**Patch Version** (Bug fixes and improvements - backward compatible)

### Changes
- HC-1263 Add source field to payment method creation, migrate sdkPlatform to typed enum, and harden PCI log sanitization (#213)

### Change Requests
  - HC-1263

### PCI DSS Compliance
This release has been documented for PCI DSS compliance requirements:
- **Change Request Tracking**: All changes are tracked via Jira tickets (see above)
- **Version History**: Semantic versioning maintained (1.2.1 - Patch Version)
- **Security Validation**: All security scans and validations completed
- **SBOM**: Software Bill of Materials included in release artifacts
- **Audit Trail**: Complete release documentation available in this changelog

### Installation
```swift
// Swift Package Manager
.package(url: "https://github.com/spreedly/checkout-ios-package.git", from: "1.2.1")
```

```ruby
# CocoaPods
pod 'Spreedly', '~> 1.2.1'
```

---

# Changelog

All notable changes to the Spreedly iOS SDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- HC-1234 **`sdk_platform` global telemetry attribute**: New `sdkPlatform` field on `SpreedlyConfig` (default `.ios`). React Native bridges pass `.reactNative` to distinguish integration surface in Datadog.
- HC-1263 **`source` field on payment method creation**: All payment method creation requests (credit card JSON and offsite/APM form-encoded) now include a `source` field identifying the checkout SDK platform (e.g. `"checkout-ios"`, `"checkout-react-native"`). This syncs with the Android SDK's equivalent change (HC-1255).
- HC-1242 **`TelemetryEventsObjCBridge`**: ObjC-compatible wrapper exposing typed `TelemetryEvents` methods so ObjC consumers and bridge layers can emit telemetry without Swift-only API.
- HC-1242 **Braintree test coverage**: Added `BraintreeCheckoutFlowTests`, `BraintreeFlowResultTests`, and `BraintreePaymentTypeTests` for checkout flow, result mapping, and payment type handling.

### Fixed

- HC-1263 **`setConfig()` not propagating `sdkPlatform`**: When the SDK was already initialized, calling `Spreedly.setup()` again took the `setConfig()` path which updated the config object but never set `GlobalAttributes.shared.sdkPlatform`. This caused telemetry and the `source` field to keep the stale platform value (e.g. `"checkout-ios"`) even when `.reactNative` was passed. Now `setConfig()` propagates `sdkPlatform` to `GlobalAttributes`.
- HC-1251 **Card number field paste and display**: Pasted input (e.g. `4111-1111-1111-1111` or `4111.1111.1111.1111`) was shown with dashes/dots and non-digits were accepted. The field now normalizes all input to digits only and displays with space-separated groups only (e.g. `4111 1111 1111 1111`). Masked state also uses space formatting.
- HC-1242 **NetworkSession broken continuation**: `URLSessionNetworkSession.performRequest(_:with:)` never resumed its continuation, causing callers to hang indefinitely. Now delegates to the primary `performRequest(_:)`.
- HC-1242 **Memory leak in Bold Text observers**: `SPLTextField` and `CardFormDropIn` registered `boldTextStatusDidChangeNotification` observers but never stored or removed them. Observers are now tracked and cleaned up in `onDisappear`.
- HC-1242 **Race condition in LoggerManager**: `getEnvironmentKey()` was called on the caller's thread outside the logger queue, creating a data race when Spreedly config changed concurrently. Now called inside the serialized queue block.
- HC-1242 **Thread safety in GatewaySpecific3DSLifecycle**: `currentState` was read and written from multiple threads without synchronization. Now protected by `stateLock` via a thread-safe computed property.
- HC-1242 **APIErrorHandler design bug**: `clearFieldError(for:)` silently called `clearGeneralError()`, discarding unrelated general errors when any field error was cleared. Field-level clears are now isolated.
- HC-1242 **CardFormDropIn timing hack**: Replaced 50ms `asyncAfter` delay (race condition with `clearAllErrors()`) with deterministic `DispatchQueue.main.async` sequencing.
- HC-1242 **ObjC Stripe APM delegate leak**: `StripeAPMPaymentFlowViewController` did not nil-out `paymentDelegate` on dealloc, risking dangling-pointer callbacks. Added `dealloc` cleanup.
- HC-1249 **Xcode Cloud TestFlight build failure**: `Package.resolved` was stale (pinned to an older `checkout-ios-package` version) and Xcode Cloud ignores runtime modifications made by `ci_post_clone.sh`. The `checkout-ios-package` release workflow now updates `Package.resolved` in `checkout-ios-sdk`, runs `xcodebuild -resolvePackageDependencies` to correct the revision SHA and originHash, commits the result, and creates the `testflight-*` tag on that commit. Xcode Cloud clones at the tag and gets a correct `Package.resolved` from the start. `ci_post_clone.sh` was simplified to only generate `SpreedlyKeys.xcconfig` and verify `Package.resolved` is present — all stale Package.resolved editing logic was removed.

### Changed

- HC-1263 **`sdkPlatform` is now a `SdkPlatform` enum**: Replaced the `String?` parameter on `SpreedlyConfig` and `SpreedlyConfigGenerator` with a type-safe `SdkPlatform` enum (`.ios`, `.reactNative`). The enum's `value` property (`"checkout-ios"` / `"checkout-react-native"`) is used for both Datadog telemetry and the Core API `source` field. **Breaking**: callers passing `sdkPlatform: "react_native"` must change to `sdkPlatform: .reactNative`.
- HC-1242 **Telemetry migrated to typed events**: Replaced inline `emitTelemetryEvent(_:level:attributes:)` calls across SpreedlyUI with type-safe `TelemetryEvents.*` static methods (e.g. `TelemetryEvents.paymentSheetPresented()`, `.validationFailed(fieldErrors:errorCount:)`).
- HC-1242 **Lazy log evaluation**: All public log functions (`logVerbose`, `logDebug`, `logInfo`, `logWarn`, `logError`) now use `@autoclosure` for the message parameter with an early `isLevelEnabled` guard, avoiding string interpolation when the level is suppressed.
- HC-1242 **NetworkClient simplified**: Removed unnecessary `withCheckedThrowingContinuation { queue.async { Task { } } }` triple-wrapping in `DefaultNetworkClient.performRequest`. Now calls `executeRequest` directly via async/await.
- HC-1242 **Removed deprecated `String.hashValue`**: `SpreedlyLogger` Datadog attributes no longer include `message_hash` (non-deterministic across process launches since Swift 4.2). `unique_id` already provides deduplication.
- HC-1242 **Removed force unwraps**: `MockNetworkSession` uses `guard let` + thrown errors instead of `!`. `Spreedly.tokenFormatRegex` uses `try!` on the known-valid constant pattern instead of a `try?` + `!` fallback chain.
- HC-1242 **Dead code cleanup**: Removed commented-out PayPal/Venmo/Cryptocurrency/BankAccount/ApplePay/GooglePay payment method code from `BasePaymentMethodRequest` and `ConvenienceRequests`. Removed duplicate `.notConnectedToInternet` switch case, unused `CommonCrypto` import, `BlurBackgroundView`, `iconName(for:)`, unused `ValidatedField` methods (`reset`, `forceValidate`, `validate`) and `apiError` parameter, iOS 14 availability fallbacks (deployment target already >=14), and commented-out theme manager methods.
- HC-1242 **Example app cleanup**: Deleted `SpreedlyDevBridge.swift` (bridge APIs now in published SDK) and `TempFile.swift`. Removed unused `channel`/`redirectUrl` from gateway-specific purchase requests in both Swift and ObjC examples. Added Braintree URL scheme and PayPal/Venmo query schemes to ObjC Info.plist.
- HC-1242 **Test cleanup**: Removed 9 zero-value tests in `Forter3DSIntegrationTests` that only asserted `XCTAssertTrue(true)`. Renamed `Forter3DSDelegateErrorPathTests` to `Forter3DSDelegateMockErrorPathTests` for clarity.
- HC-1242 **Removed `GATEWAY_CHANGES.md`**: Deleted the redundant cross-gateway overview doc. Moved the unique cross-cutting content (payment methods comparison table, backend requirements quick reference, URL handling troubleshooting, React Native URL handling) into `guides/getting-started.md`. Replaced with `GATEWAY_SPECIFIC_FLOWCHARTS.md` containing detailed flow diagrams.

## [1.1.4] - 2026-03-11

### Changed
- HC-1234 Add telemetry events and attributes for payment flows, 3DS, network, and error tracking
- HC-1233 Audit fixes: version consistency, SBOM updates, documentation sync, PCI compliance improvements

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
- Extended `LogSanitizer` to cover 13–19 digit PANs, expiry dates, environment keys, JSON card payloads, and phone numbers
- Added `clearSensitiveData()` on `CreditCardDataImpl` to zero PAN, CVV, and expiry after API calls
- Changed `encryptAES()` to return `nil` on failure instead of empty string for fail-safe handling
- Masked payment tokens in all example app views using `Spreedly.maskedToken(_:)`
- SDK automatically sanitizes error messages in FailedDetails, APIErrorHandler, and logging
- Added error logging when `SecureValueContainer` encryption fails

### Changed

- Datadog initialization now skips gracefully when no client token is configured (local/debug builds)
- `SecureValueContainer.registerValue` guards against encryption failure with diagnostic logging
- Improved thread safety in `GatewaySpecific3DSLifecycle` with dedicated `NSLock` for state transitions
- Extracted `insertProcessingToken` / `removeProcessingToken` helpers in `Spreedly` for safer lock usage
- Fixed expiration date two-digit year pivot (years 50–99 now map to 1900s)
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
