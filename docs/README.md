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
| [Privacy](guides/privacy.md) | Privacy requirements and data handling practices |
| [Troubleshooting](guides/troubleshooting.md) | Common issues and solutions |

## Development

| Document | Description |
|----------|-------------|
| [Contributing](development/CONTRIBUTING.md) | Setup, workflow, coding standards, PR process |
| [Release Process](development/RELEASE_PROCESS.md) | End-to-end release workflow and procedures |
| [Distribution](development/DISTRIBUTION.md) | SPM and CocoaPods publishing |
| [Versioning](development/VERSIONING.md) | Semantic versioning system |
| [Package Verification](development/PACKAGE_VERIFICATION.md) | Artifact checksums and verification |
| [Workflow Improvements](development/WORKFLOW_IMPROVEMENTS.md) | GitHub Actions workflows, execution flow, and CI/CD reference |
| [TestFlight Distribution](development/TESTFLIGHT_DISTRIBUTION.md) | Xcode Cloud setup and TestFlight distribution |
| [Git Hooks](development/GIT_HOOKS.md) | Commit message hooks and setup |
| [Lint Setup](development/LINT_SETUP.md) | SwiftLint configuration and local/CI usage |
| [Pull Request Guidelines](development/PULL_REQUEST_GUIDELINES.md) | PR process, review, and branch protection |
| [Secret Scanning](development/SECRET_SCANNING.md) | Credential safety and secret management |
| [Vulnerability Scanning](development/VULNERABILITY_SCANNING.md) | CodeQL, DAST, and dependency security scanning |
| [Developer Quick Reference](development/DEVELOPER_QUICK_REFERENCE.md) | PR checklist, CI requirements |
| [SDK Technical Specification](development/SDK_TECHNICAL_SPECIFICATION.md) | Architecture, modules, API surface |
| [Platform Privacy](development/PLATFORM_PRIVACY_REQUIREMENTS.md) | Privacy requirements and data handling |

### Flow Diagrams

| Document | Description |
|----------|-------------|
| [3DS Global Flow](development/3DS_GLOBAL_FLOW.md) | Forter-based 3DS flow: status, challenge, completion, result mapping |
| [3DS Gateway-Specific Flow](development/3DS_GATEWAY_SPECIFIC_FLOW.md) | Gateway 3DS flow: device fingerprint, trigger/finalize, Safari challenge, lifecycle |
| [Card Tokenization Flow](development/CARD_TOKENIZATION_FLOW.md) | Card tokenization: SecureValueContainer, encryption, API, two-result pattern |
| [Recaching Flow](development/RECACHING_FLOW.md) | CVV recaching: validation, recache API, result handling |
| [Stripe Flow](development/STRIPE_FLOW.md) | Stripe APM flow diagrams |
| [Braintree Flow](development/BRAINTREE_FLOW.md) | Braintree PayPal/Venmo flow diagrams |
| [EBANX Flow](development/EBANX_FLOW.md) | EBANX offsite payment flow diagrams |
| [Offsite Flow](development/OFFSITE_FLOW.md) | PayPal/Sprel offsite flow diagrams |

## Other

- [Changelog](CHANGELOG.md)
- [Root README](../README.md)
