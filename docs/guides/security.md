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

The Spreedly iOS SDK provides security features to help you achieve PCI DSS compliance and protect sensitive payment information. It covers screen prevention, secure value collection, API key handling, token storage, and other security practices for integrating the SDK into your application.

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

The SDK uses `SecureValueContainer` to handle sensitive fields such as card number and CVV. This ensures that sensitive data never passes through your application code in plain text.

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

The SDK is designed to help you reduce PCI DSS scope:

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

The SDK's logging system automatically redacts sensitive data:

- **Card numbers** are sanitized in log output
- **API keys** and credentials are redacted
- **CVV** and other sensitive fields are never logged

### Production Recommendations

- Set log level to `.warn` or `.error` in production
- Never log CVV or full card numbers
- Use appropriate log levels (avoid `logDebug` and `logVerbose` in production)

```swift
#if DEBUG
Spreedly.setLogLevel(.debug)
#else
Spreedly.setLogLevel(.warn)
#endif
```

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
