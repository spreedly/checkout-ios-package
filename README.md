# Spreedly iOS SDK

[![GitHub Package](https://img.shields.io/badge/GitHub%20Package-1.3.8-blue)](https://github.com/spreedly/checkout-ios-package/releases)
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
    .package(url: "https://github.com/spreedly/checkout-ios-package", from: "1.3.8")
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
pod 'SpreedlyCore', '~> 1.3'
pod 'SpreedlySecurity', '~> 1.3'
pod 'SpreedlyUI', '~> 1.3'

# Optional — add as needed
# pod 'SpreedlyStripeAPM', '~> 1.3'
# pod 'SpreedlyBraintree', '~> 1.3'
```

If you use **SpreedlyStripeAPM** with CocoaPods, you **must** add this `post_install` block. Without it the app crashes at runtime: `Fatal error: unable to find bundle named Stripe_StripePaymentSheet`. The script is shipped inside the pod; no manual file copy needed.

```ruby
post_install do |installer|
  stripe_apm_pod = installer.sandbox.pod_dir('SpreedlyStripeAPM')
  require File.join(stripe_apm_pod, 'scripts', 'cocoapods_stripe_bundle_patcher')
  SpreedlyStripeAPM::CocoaPods.apply_stripe_bundle_patch(installer)
end
```

## Modules

| Module | Product | Description |
|--------|---------|-------------|
| **Core** | `SpreedlyCore` | Core payment processing, API client, 3DS, offsite payments (required) |
| **Security** | `SpreedlySecurity` | Encryption and secure field storage (required) |
| **UI** | `SpreedlyUI` | Pre-built payment forms and hosted field components (required) |
| **Stripe APM** | `SpreedlyStripeAPM` | Stripe APM via native PaymentSheet (iDEAL, Bancontact, EPS, P24, SEPA) |
| **Stripe Radar** | `SpreedlyStripeRadar` | **Session ID only** — headless Radar device data (`radar_session_id` for fraud signals). Does not include Payment Sheet or checkout UI. Independent of `SpreedlyStripeAPM`. |
| **Braintree** | `SpreedlyBraintree` | Braintree PayPal and Venmo payments |

## Integration Guides

For detailed integration guides, code samples, and the example merchant app, see the [checkout-ios-example](https://github.com/spreedly/checkout-ios-example) repository. It includes step-by-step guides for all payment flows, 3DS, theming, error handling, Objective-C support, and more.

## SDK Lifecycle

| Major Version | Status | Released | Deprecated | End-of-Life |
|---|---|---|---|---|
| 1.x.x | Active | March 2026 | --- | --- |

More information about versioning and the SDK lifecycle can be found in the [CHANGELOG](CHANGELOG.md).

## Stability & Compatibility Guarantees

The Spreedly iOS SDK follows [Semantic Versioning 2.0.0](https://semver.org/):

- **Patch** releases (`x.y.Z`) contain only bug fixes. No public API changes.
- **Minor** releases (`x.Y.0`) may add new public API. Existing API remains source- and binary-compatible.
- **Major** releases (`X.0.0`) may contain breaking changes. A migration guide is published with every major release.

### What Constitutes a Breaking Change

The following changes are considered breaking and will only ship in a **major** release:

- Removal or rename of any `public` / `open` symbol
- Changing the signature of an existing public method or initializer
- Changing observable behavior that merchants rely on (e.g. callback semantics, error types)
- Raising the minimum iOS deployment target
- Removing support for a dependency manager (SPM or CocoaPods)

### Deprecation Policy

- Deprecated API is annotated with `@available(*, deprecated, message:)` and documented in the [CHANGELOG](CHANGELOG.md).
- Deprecated API remains functional for at least **one minor release cycle** after the deprecation notice.
- Deprecated API is removed only in the next **major** release, unless a security issue requires earlier removal.

### Support Window

- The **current major** version receives active feature development and bug fixes.
- The **previous major** version (N-1) receives critical bug fixes and security patches for **12 months** after the new major ships.
- Older major versions are end-of-life and receive no further updates.

### Version Pinning

All `Spreedly*` frameworks in a single app build must use the **same version**. Pin explicitly:

- **SPM:** `from: "1.3.8"` (accepts compatible minor/patch updates)
- **CocoaPods:** `~> X.Y` (accepts compatible patch updates within the minor)

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
- **Security** -- HTTPS/TLS, screen prevention, encrypted fields

## Known Issues

- **3DS is not a separate module:** 3DS/Forter support on iOS is embedded within `SpreedlyCore` via weak linking. Merchants must add `Forter3DS` as a direct dependency to their app target for 3DS to function. Extracting 3DS into dedicated modules (`SpreedlyForter3DS` for Global 3DS and `SpreedlyGateway3DS` for Gateway-Specific) is planned for a future release.

> **Forter3DS (3DS Global):** Forter3DS is **not** part of the Spreedly package. Add it directly from Forter's Bitbucket: `https://bitbucket.org/forter-mobile/forter-ios.git` (exactly 2.1.0). Without it, the app crashes when 3DS is triggered.

- **Checksum validation workflows vary by release artifact set:** SHA-256 checksum files are published for core and optional modules. Always verify checksums for the specific artifacts your app consumes.

- **GPG-signed release tags:** Stable release tags are GPG-signed with Spreedly's iOS release key. Contact Spreedly Support to obtain the public verification key and run `git tag -v X.Y.Z`. SHA-256 checksums for framework zips are also available for binary artifact verification — see [PACKAGE_VERIFICATION.md](PACKAGE_VERIFICATION.md).

## Support

- **Spreedly Documentation**: [docs.spreedly.com](https://docs.spreedly.com/)
- **Support Portal**: [spreedly.com/support](https://spreedly.com/support/)
- **GitHub Issues**: [Bug reports and feature requests](https://github.com/spreedly/checkout-ios-package/issues)
- **Package Verification (checksums)**: [PACKAGE_VERIFICATION.md](PACKAGE_VERIFICATION.md)
- **Changelog**: [CHANGELOG.md](CHANGELOG.md)
- **Security**: [SECURITY.md](SECURITY.md)

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

## Legal

- [Terms of Service](https://legal.spreedly.com/#terms)
- [Privacy Policy](https://legal.spreedly.com/#privacy-policy)
- [License](LICENSE) (Apache 2.0)

