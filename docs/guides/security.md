# Security Best Practices - Spreedly iOS SDK

Protect sensitive payment data with screen prevention, secure storage, and PCI compliance.

**Estimated time:** ~10 minutes

## Table of Contents

1. [Introduction](#introduction)
2. [Screen Prevention](#screen-prevention)
3. [Secure Value Collection](#secure-value-collection)
4. [API Key Handling](#api-key-handling)
5. [Token Storage](#token-storage)
6. [PCI Compliance](#pci-compliance)
7. [Memory Management](#memory-management)
8. [Logging Security](#logging-security)
9. [Best Practices Checklist](#best-practices-checklist)
10. [Testing Security](#testing-security)
11. [Related Documentation](#related-documentation)

---

## Prerequisites

- Complete [Getting Started](getting-started.md) (SDK installed and initialized)
- Familiarity with your app's `Info.plist` and entitlements configuration

---

## Introduction

The Spreedly iOS SDK provides security features to meet PCI DSS requirements and protect sensitive payment information. It covers screen prevention, secure value collection, API key handling, token storage, and other security practices for integrating the SDK into your application.

---

## Screen Prevention

The SDK includes screen prevention features to protect sensitive payment information from unauthorized capture. This is important for PCI DSS compliance and protecting user payment data.

### What It Protects Against

- **Screenshots**: Prevents users from taking screenshots of protected content
- **Screen Recording**: Blocks screen recording of sensitive payment information
- **Screen Sharing**: Prevents content from being shared via AirPlay, screen mirroring, or other sharing methods
- **App Switcher Preview**: Automatically applies privacy overlay when the app goes to background to protect previews in the app switcher

### Three Layers of Protection

1. **View-level Protection**: Prevents screenshots, screen recordings, and screen sharing of protected views
2. **App Switcher Protection**: Automatically applies privacy overlay when app goes to background
3. **Automatic Management**: Handles lifecycle events and screen capture detection

### SwiftUI Integration

Apply screen prevention to any SwiftUI view using the `.screenPrevention()` modifier. The most effective approach is to apply it at the root screen level.

**Apply at Root Level (Recommended):**

```swift
import SwiftUI
import SpreedlyUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .screenPrevention()
        }
    }
}
```

**Apply to Sheets Separately:**

Sheets require separate protection. Apply `.screenPrevention()` inside the `.sheet()` modifier:

```swift
.sheet(isPresented: $showPaymentForm) {
    PaymentFormView()
        .screenPrevention()
}
```

**Custom Placeholder Text:**

Provide custom placeholder text that appears in screenshots, screen recordings, and app switcher previews:

```swift
WindowGroup {
    MainView()
        .screenPrevention(placeholderText: "Secure Payment")
}

// In sheets
.sheet(isPresented: $showForm) {
    PaymentFormView()
        .screenPrevention(placeholderText: "Payment Information")
}
```

**CardFormDropIn:** Apply `.screenPrevention()` to `CardFormDropIn` when presenting it. Example:

```swift
.sheet(isPresented: $showForm) {
    CardFormDropIn(
        yearFormat: yearFormat,
        nameDisplayMode: nameDisplayMode,
        onProcessingResult: { _ in }
    )
    .screenPrevention()
}
```

**Important:** Screen prevention cannot be applied to 3DS challenges (`DoChallengeIfNeeded` or `DoChallengeIfNeededViewController`) because the challenge UI is presented in a separate view controller that cannot be wrapped in the protection layer.

### UIKit Integration

**CardFormDropInViewController:** Wrap `CardFormDropInViewController` with `wrapInSecureViewController(placeholderText:)` before presenting. Example:

```swift
let dropInVC = CardFormDropInViewController(
    otherFields: [],
    yearFormat: .fourDigit,
    nameDisplayMode: .separateFields,
    onProcessingResult: { _ in }
)
let secureVC = dropInVC.wrapInSecureViewController(placeholderText: "Payment information is protected")
present(secureVC, animated: true)
```

For other UIKit view controllers, use the `wrapInSecureViewController()` extension:

```swift
import UIKit
import SpreedlyUI

let sensitiveDataVC = SensitiveDataViewController()
let secureVC = sensitiveDataVC.wrapInSecureViewController(
    placeholderText: "Payment information is protected"
)
present(secureVC, animated: true)
```

**Note:** The `placeholderText` parameter defaults to `""` and is optional.

### Objective-C Integration

For custom view controllers that display sensitive data, use `wrapInSecureViewControllerWithPlaceholderText:`:

```objc
#import <SpreedlyUI/SpreedlyUI-Swift.h>

SensitiveDataViewController *sensitiveVC = [[SensitiveDataViewController alloc] init];
UIViewController *secureVC = [sensitiveVC wrapInSecureViewControllerWithPlaceholderText:@"Secure Payment"];
[self presentViewController:secureVC animated:YES completion:nil];
```

**Note:** The `placeholderText` parameter defaults to `""` and is optional.

For root-level wrapping in `SceneDelegate` (protecting the entire app):

```objc
// In SceneDelegate scene:willConnectToSession:options:
UIViewController *secureVC = [navController wrapInSecureViewControllerWithPlaceholderText:@""];
self.window.rootViewController = secureVC;
```

---

## Secure Value Collection

The SDK uses `SecureValueContainer` to handle sensitive fields such as card number and CVV. Sensitive data never passes through your application code in plain text.

- **SecureValueContainer** handles card number and CVV collection
- **CVV is never stored locally**; it is only transmitted securely to Spreedly
- Sensitive data is encrypted using **AES-256-GCM** via CryptoKit
- When using SDK UI components, `SecureValueContainer` is managed automatically
- `SecureValueContainer` cleans up after use

---

## API Key Handling

### Never Hardcode API Keys

Never embed API keys directly in source code. Hardcoded keys can be extracted from app binaries and exposed in version control.

**Bad Practice:**

```swift
Spreedly.setup(config: SpreedlyConfig(
    environmentKey: "production_key_abc123xyz"
))
```

**Good Practice:**

Fetch credentials from your backend server. Store the environment key securely (for example, in Keychain or a secure configuration service) and load it at runtime.

```swift
// Fetch from backend before each payment session
let config = await fetchSpreedlyConfigFromBackend()
Spreedly.setup(config: config)
```

### Signature Parameters

Signature parameters (`nonce`, `signature`, `certificateToken`, `timestamp`) are **time-sensitive** and must be:

- Fetched from your backend server
- Generated fresh before each payment session
- Never stored or reused across sessions

Call `Spreedly.setup(config:)` with valid signature parameters before any tokenization, payment form presentation, or 3DS challenge flow.

**Example: Fetch signature before presenting the payment form**

```swift
// Before presenting the payment form
Task {
    let params = try await YourBackend.fetchSignatureParams()
    Spreedly.setup(config: SpreedlyConfig(
        environmentKey: "YOUR_ENV_KEY",
        forterSiteId: "YOUR_FORTER_SITE_ID",
        certificateToken: params.certificateToken,
        nonce: params.nonce,
        signature: params.signature,
        timestamp: params.timestamp
    ))
    // Now present the form
}
```

---

## Token Storage

### Use iOS Keychain for Sensitive Tokens

Store sensitive tokens (such as session tokens or refresh tokens) in the iOS Keychain. Never store them in UserDefaults or plain text files.

**Recommended:**

```swift
import Security

// Use Keychain Services for sensitive token storage
// Use Keychain Services API for secure token persistence
```

### Never Store In

- **UserDefaults** or SharedPreferences
- **Plain text files**
- **Unencrypted** local databases (Core Data, SQLite)

### Payment Method Tokens

Payment method tokens returned by Spreedly are non-sensitive and can be stored for future use (for example, to charge a saved card). Store them in Keychain if you persist them locally, or pass them to your backend for server-side storage.

---

## PCI Compliance

The SDK helps you reduce PCI DSS scope:

- **Sensitive data handling**: Card number and CVV are collected and processed within `SecureValueContainer`; no card data passes through your application code
- **No card data in merchant app**: Sensitive cardholder data is encrypted and transmitted directly to Spreedly
- **HTTPS/TLS**: All network communication uses HTTPS/TLS
- **Screen prevention**: Protects against screenshot and screen recording capture of payment forms

---

## Memory Management

Proper memory management prevents leaks and reduces the risk of sensitive data lingering in memory.

### Cancel Combine Subscriptions

When using Combine publishers (for example, `subscribeToPaymentResults`), cancel subscriptions when views disappear:

```swift
.onDisappear {
    cancellable?.cancel()
    cancellable = nil
}
```

### SecureValueContainer Cleanup

`SecureValueContainer` cleans up after use. When using programmatic recaching, ensure you call `SecureValueContainer.shared.stopCollection()` when finished, or rely on the SDK's automatic cleanup when using UI components.

---

## Logging Security

The SDK's logging system automatically redacts sensitive data via `LogSanitizer`:

- **Card numbers** (13-19 digit PANs) are sanitized in log output
- **Expiry dates** are redacted when preceded by expiry-related keywords
- **API keys**, environment keys, and credentials are redacted
- **CVV/CVC** and other sensitive fields are never logged
- **Phone numbers** and emails are redacted in sensitive contexts
- **Card data in JSON payloads** (e.g. `"number": "4111..."`) is caught
- **URL path tokens** (`transactions/TOKEN/...`) are masked — both versioned (`/v1/transactions/TOKEN`) and non-versioned paths are caught
- **Token identification heuristic**: a path segment is treated as a token only if it is 6+ characters _and_ contains at least one digit, which prevents false positives on endpoint names like `restricted`

### URL Token Sanitization (Defense in Depth)

URL path tokens are sanitized at two layers:

1. **`NetworkClient.extractEndpointPath()`** masks token-like segments _before_ the message is even constructed. This is the primary defense.
2. **`LogSanitizer`** regex catches any tokens that survive in the final log string. The regex matches `transactions/<token>` and `payment_methods/<token>` with or without a `/v1/` prefix.

Both layers use the same heuristic: a segment is a token candidate if it is 6+ alphanumeric characters containing at least one digit. This avoids masking legitimate endpoint names (e.g. `payment_methods/restricted`).

If you add new API endpoints that contain sensitive identifiers in the URL path, update both `extractEndpointPath()` in `NetworkClient.swift` and the `urlPathTokenPattern` regex in `SpreedlyLogger.swift`.

### Production Recommendations

Use `SpreedlyLoggerConfiguration` presets for one-step setup:

```swift
#if DEBUG
Spreedly.configureLogging(.debug)     // console on, min .debug
#else
Spreedly.configureLogging(.production) // console off, Datadog at .warn
#endif
```

Or use fine-grained control:

```swift
Spreedly.setLogLevel(.none)           // suppress all console output
Spreedly.setDatadogLogLevel(.error)   // Datadog receives errors only
Spreedly.disableLogging()             // equivalent to setLogLevel(.none)
```

- Avoid `.debug` and `.verbose` in production builds
- Never log CVV or full card numbers in your own code

### Custom Logger PCI Compliance

When you inject a custom logger via `Spreedly.setLogger(_:)`:

- **All messages are sanitized** before delivery — card numbers, CVV, tokens, API keys, and PII are redacted by `LogSanitizer` before your code receives them
- **Error objects** are passed as-is so you can inspect `NSError` domain/code
- The SDK holds a **weak** reference — keep a strong reference elsewhere
- Your logger's own `minLogLevel` is respected, so set it to `.warn` or `.error` in production to minimize noise

```swift
// Production-safe custom logger
final class ProductionLogger: SpreedlyLogger {
    var minLogLevel: LogLevel = .error  // only errors in production

    func verbose(tag: String, message: String, error: Error?) { }
    func debug(tag: String, message: String, error: Error?)   { }
    func info(tag: String, message: String, error: Error?)    { }
    func warn(tag: String, message: String, error: Error?)    { }
    func error(tag: String, message: String, error: Error?) {
        // Safe to log — message is already PCI-sanitized by the SDK
        YourObservabilityService.logError(tag: tag, message: message, error: error)
    }
    func isLoggable(level: LogLevel) -> Bool {
        level.shouldLog(minLevel: minLogLevel)
    }
}
```

### os_log Persistence

The SDK uses Apple's unified logging (`os_log`) for console output. Be aware that `os_log` output can persist in the system log store and may be exported via `sysdiagnose` or accessed through device management profiles. For production apps, use `Spreedly.configureLogging(.production)` or `Spreedly.disableLogging()` to suppress all SDK console output.

### Third-Party SDK Logging

The Spreedly SDK does not control logging from third-party SDKs it depends on (Braintree, Stripe, Datadog). These SDKs have their own logging systems that may output payment-related information. You should configure these independently:

- **Braintree**: Refer to [Braintree iOS SDK documentation](https://developer.paypal.com/braintree/docs/start/hello-client/ios/v5) for logging configuration.
- **Stripe**: Refer to [Stripe iOS SDK documentation](https://docs.stripe.com/payments/accept-a-payment?platform=ios) for controlling log output.
- **Datadog**: The Spreedly SDK initializes Datadog via a build-time injected client token. Spreedly sanitizes all messages before sending. If you also use Datadog directly in your app, ensure your own logs do not contain PCI data.

### Error Message Sanitization

The SDK automatically sanitizes all public-facing error messages in `FailedDetails`, `APIErrorHandler`, and logging. Merchants no longer need to call `sanitizeForDisplay()` — error descriptions returned by `getDescription()` and similar APIs are already safe to log or display.

For displaying masked payment tokens in your UI (e.g., "•••• 4242"), use `Spreedly.maskedToken(_:)`. For logging, use the SDK's `logInfo`/`logError` functions, which auto-sanitize output.

---

## Best Practices Checklist

- [ ] Apply `.screenPrevention()` to payment forms and custom views displaying sensitive data
- [ ] Fetch signature parameters from your backend before each payment session
- [ ] Cancel Combine subscriptions in `onDisappear` (or `dealloc` for Objective-C)
- [ ] Use Keychain for sensitive token storage; never use UserDefaults or plain text
- [ ] Set log level to `.warn` or `.error` in production
- [ ] Never log CVV or full card numbers
- [ ] Never hardcode API keys; fetch from backend or secure configuration
- [ ] Use HTTPS for all network communications
- [ ] Protect app switcher previews (screen prevention handles this automatically when applied)

---

## Testing Security

### Test Screenshot Prevention

1. Apply `.screenPrevention()` to a view
2. Take a screenshot (Command+Shift+3 on simulator, or device buttons)
3. Verify the screenshot shows placeholder text or blank content

### Test Screen Recording Prevention

1. Start screen recording on your device (Control Center to Screen Recording)
2. Navigate to a protected view
3. Verify the recording shows placeholder text or blank content

### Test App Switcher Protection

1. Navigate to a protected view
2. Put the app in background (home gesture or button)
3. Open app switcher
4. Verify the app preview shows blur overlay or placeholder text

---

## Related Documentation

- [getting-started.md](getting-started.md) - SDK setup and initialization
- [error-handling.md](error-handling.md) - Error handling and troubleshooting
- [recaching.md](recaching.md) - CVV recaching and saved payment methods
