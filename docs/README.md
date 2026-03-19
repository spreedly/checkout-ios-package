# Spreedly iOS SDK Documentation

## Integration Guides

| Guide | Description |
|-------|-------------|
| [Getting Started](guides/getting-started.md) | Installation, initialization, first payment |
| [Express Checkout](guides/express-checkout.md) | Pre-built CardFormDropIn payment form |
| [Custom Payment Forms](guides/custom-payment-forms.md) | Build your own payment UI with SPLTextField |
| [Theme and Styling](guides/theme-and-styling.md) | Colors, typography, dark mode |
| [Error Handling](guides/error-handling.md) | Error types, retry logic, user-friendly messages |
| [Security](guides/security.md) | Screen prevention, PCI compliance |
| [Recaching](guides/recaching.md) | CVV recaching for saved payment methods |
| [Offsite Payments](guides/offsite-payments.md) | PayPal, Sprel via Safari |
| [EBANX APM](guides/ebanx-apm.md) | Pix, Boleto, OXXO, NuPay, Rapipago via EBANX |
| [Stripe APM](guides/stripe-apm.md) | iDEAL, Bancontact, EPS, P24, SEPA via Stripe |
| [Braintree APM](guides/braintree-apm.md) | PayPal and Venmo via Braintree |
| [3DS Global](guides/3ds-global.md) | Forter-based 3D Secure authentication |
| [3DS Gateway-Specific](guides/3ds-gateway-specific.md) | Gateway-managed 3DS authentication (e.g. Worldpay) |
| [Objective-C](guides/objective-c.md) | Objective-C integration with delegates and wrappers |
| [Troubleshooting](guides/troubleshooting.md) | Common integration issues and solutions |

## Development

Development documentation (contributing, flow diagrams, release process) lives in the **checkout-ios-sdk** (source) repository. Links below point to the SDK repo.

| Document | Description |
|----------|-------------|
| [Contributing](https://github.com/spreedly/checkout-ios-sdk/blob/main/SpreedlyDocs/development/CONTRIBUTING.md) | Setup, workflow, coding standards, PR process |
| [Release Process](https://github.com/spreedly/checkout-ios-sdk/blob/main/SpreedlyDocs/development/RELEASE_PROCESS.md) | End-to-end release workflow and procedures |
| [Distribution](https://github.com/spreedly/checkout-ios-sdk/blob/main/SpreedlyDocs/development/DISTRIBUTION.md) | SPM and CocoaPods publishing |
| [Versioning](https://github.com/spreedly/checkout-ios-sdk/blob/main/SpreedlyDocs/development/VERSIONING.md) | Semantic versioning system |
| [Package Verification](https://github.com/spreedly/checkout-ios-sdk/blob/main/SpreedlyDocs/development/PACKAGE_VERIFICATION.md) | Artifact checksums and verification |
| [Workflow Improvements](https://github.com/spreedly/checkout-ios-sdk/blob/main/SpreedlyDocs/development/WORKFLOW_IMPROVEMENTS.md) | GitHub Actions workflows, execution flow, and CI/CD reference |
| [TestFlight Distribution](https://github.com/spreedly/checkout-ios-sdk/blob/main/SpreedlyDocs/development/TESTFLIGHT_DISTRIBUTION.md) | Xcode Cloud setup and TestFlight distribution |
| [Git Hooks](https://github.com/spreedly/checkout-ios-sdk/blob/main/SpreedlyDocs/development/GIT_HOOKS.md) | Commit message hooks and setup |
| [Lint Setup](https://github.com/spreedly/checkout-ios-sdk/blob/main/SpreedlyDocs/development/LINT_SETUP.md) | SwiftLint configuration and local/CI usage |
| [Pull Request Guidelines](https://github.com/spreedly/checkout-ios-sdk/blob/main/SpreedlyDocs/development/PULL_REQUEST_GUIDELINES.md) | PR process, review, and branch protection |
| [Secret Scanning](https://github.com/spreedly/checkout-ios-sdk/blob/main/SpreedlyDocs/development/SECRET_SCANNING.md) | Credential safety and secret management |
| [Vulnerability Scanning](https://github.com/spreedly/checkout-ios-sdk/blob/main/SpreedlyDocs/development/VULNERABILITY_SCANNING.md) | CodeQL, DAST, and dependency security scanning |
| [Developer Quick Reference](https://github.com/spreedly/checkout-ios-sdk/blob/main/SpreedlyDocs/development/DEVELOPER_QUICK_REFERENCE.md) | PR checklist, CI requirements |
| [SDK Technical Specification](https://github.com/spreedly/checkout-ios-sdk/blob/main/SpreedlyDocs/development/SDK_TECHNICAL_SPECIFICATION.md) | Architecture, modules, API surface |
| [Platform Privacy](https://github.com/spreedly/checkout-ios-sdk/blob/main/SpreedlyDocs/development/PLATFORM_PRIVACY_REQUIREMENTS.md) | Privacy requirements and data handling |

### Flow Diagrams

| Document | Description |
|----------|-------------|
| [3DS Global Flow](https://github.com/spreedly/checkout-ios-sdk/blob/main/SpreedlyDocs/development/3DS_GLOBAL_FLOW.md) | Forter-based 3DS flow: status, challenge, completion, result mapping |
| [3DS Gateway-Specific Flow](https://github.com/spreedly/checkout-ios-sdk/blob/main/SpreedlyDocs/development/3DS_GATEWAY_SPECIFIC_FLOW.md) | Gateway 3DS flow: device fingerprint, trigger/finalize, Safari challenge, lifecycle |
| [Card Tokenization Flow](https://github.com/spreedly/checkout-ios-sdk/blob/main/SpreedlyDocs/development/CARD_TOKENIZATION_FLOW.md) | Card tokenization: SecureValueContainer, encryption, API, two-result pattern |
| [Recaching Flow](https://github.com/spreedly/checkout-ios-sdk/blob/main/SpreedlyDocs/development/RECACHING_FLOW.md) | CVV recaching: validation, recache API, result handling |
| [Stripe Flow](https://github.com/spreedly/checkout-ios-sdk/blob/main/SpreedlyDocs/development/STRIPE_FLOW.md) | Stripe APM flow diagrams |
| [Braintree Flow](https://github.com/spreedly/checkout-ios-sdk/blob/main/SpreedlyDocs/development/BRAINTREE_FLOW.md) | Braintree PayPal/Venmo flow diagrams |
| [EBANX Flow](https://github.com/spreedly/checkout-ios-sdk/blob/main/SpreedlyDocs/development/EBANX_FLOW.md) | EBANX offsite payment flow diagrams |
| [Offsite Flow](https://github.com/spreedly/checkout-ios-sdk/blob/main/SpreedlyDocs/development/OFFSITE_FLOW.md) | PayPal/Sprel offsite flow diagrams |

## Other

- [Stripe CocoaPods bundle naming](STRIPE_COCOAPODS_BUNDLE_NAMING.md) — Why CocoaPods users need a bundle fix (root cause and evidence)
- [Changelog](CHANGELOG.md)
- [Root README](../README.md)
