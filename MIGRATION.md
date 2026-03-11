# Migration Guide

This guide helps you upgrade between major and minor versions of the Spreedly iOS SDK.

## Migrating to 1.1.x from 1.0.x

### New Modules

Version 1.1.0 introduces two optional payment modules. No changes are required to existing integrations -- these are additive.

**SpreedlyStripeAPM** -- Stripe Alternative Payment Methods (iDEAL, Bancontact, EPS, P24, SEPA):

```swift
// Package.swift
.product(name: "SpreedlyStripeAPM", package: "checkout-ios-package")
```

```ruby
# CocoaPods
pod 'SpreedlyStripeAPM', '~> 1.1'
```

**SpreedlyBraintree** -- Braintree PayPal and Venmo:

```swift
// Package.swift
.product(name: "SpreedlyBraintree", package: "checkout-ios-package")
```

```ruby
# CocoaPods
pod 'SpreedlyBraintree', '~> 1.1'
```

### New Features (No Breaking Changes)

- **EBANX offsite payments**: Pix, Boleto, OXXO, NuPay, Rapipago via EBANX
- **Gateway-specific 3DS**: Gateway-managed 3D Secure authentication (e.g. Worldpay)
- **CVV recaching**: `SpreedlyCVVRecachingView` for updating CVV on saved payment methods
- **Screen prevention**: `ScreenPreventionSecureView` for PCI-compliant screenshot blocking
- **Objective-C support**: Full ObjC compatibility via delegates, bridges, and view controllers

### Deprecated APIs

The following theme APIs were removed in 1.1.0:

| Removed API | Replacement |
|---|---|
| `SpreedlyThemeManager.setDarkTheme()` | `SpreedlyThemeManager.setGlobalTheme(lightTheme:darkTheme:)` |
| `SpreedlyThemeManager.setLightTheme()` | `SpreedlyThemeManager.setGlobalTheme(lightTheme:darkTheme:)` |
| `SpreedlyThemeManager.resetToDefaultTheme()` | `SpreedlyThemeManager.setGlobalTheme(lightTheme:darkTheme:)` with default themes |

### Build Requirements

| Requirement | 1.0.x | 1.1.x |
|---|---|---|
| swift-tools-version | 6.1 | 6.0 (broadened for compatibility) |
| iOS minimum | 14.0 | 14.0 |
| Swift | 5.10+ | 5.10+ |
| Xcode | 16.1+ | 16.1+ |

### Behavioral Changes

- **Datadog initialization** now skips gracefully when no client token is configured, instead of failing
- **Expiration date parsing**: Two-digit years 50-99 now correctly map to the 1900s (previously mapped to 2000s)
- **Theme detection**: Uses `connectedScenes` instead of deprecated `UIApplication.shared.windows`

---

## Future Migration Notes

This section will be updated when breaking changes are introduced in future major versions.
