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
| [EBANX APM](guides/ebanx-apm.md) | Pix, Boleto, OXXO, NuPay via EBANX |
| [Stripe APM](guides/stripe-apm.md) | iDEAL, Bancontact, EPS, P24, SEPA via Stripe |
| [Braintree APM](guides/braintree-apm.md) | PayPal and Venmo via Braintree |
| [3DS Global](guides/3ds-global.md) | Forter-based 3D Secure authentication |
| [3DS Gateway-Specific](guides/3ds-gateway-specific.md) | Gateway-managed 3DS authentication (e.g. Worldpay) |
| [Objective-C](guides/objective-c.md) | Objective-C integration with delegates and wrappers |
| [Privacy](guides/privacy.md) | Privacy requirements and data handling practices |
| [Troubleshooting](guides/troubleshooting.md) | Common issues and solutions |
| [Testing Guide](guides/testing-guide.md) | Test cards, environment setup, and flow-by-flow testing |
| [Versioning and Upgrades](guides/versioning-and-upgrades.md) | SemVer expectations, upgrade checklist, rollback guidance |
| [Migration](guides/migration.md) | Version-to-version migration steps for package consumers |

## SDK Engineering Docs

This repository focuses on public distribution and merchant integration guides.

For source-code architecture, CI/CD workflows, and release engineering runbooks, use the SDK repository docs:

- [checkout-ios-sdk/SpreedlyDocs/README.md](https://github.com/spreedly/checkout-ios-sdk/tree/main/SpreedlyDocs)

Version references in SDK docs can lag briefly after a package release. Use this package repository (`README.md`, `CHANGELOG.md`, and `guides/getting-started.md`) as the canonical install-version source.

## Other

- [Go-Live Index](GO_LIVE_INDEX.md)
- [Changelog](../CHANGELOG.md)
- [Security](../SECURITY.md)
- [Package Verification](../PACKAGE_VERIFICATION.md)
- [Guide Sync Policy](SYNC_POLICY.md)
- [Root README](../README.md)
