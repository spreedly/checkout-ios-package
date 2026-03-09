# Spreedly iOS SDK Integration Guide

This guide has been reorganized into focused, topic-specific documents. Start with the Getting Started guide below, then follow the guide for your use case.

## Getting Started

**[Getting Started](docs/guides/getting-started.md)** -- Installation, initialization, and your first payment

## All Guides

### Payments

| Guide | Description |
|-------|-------------|
| [Getting Started](docs/guides/getting-started.md) | Install, initialize, and process your first payment |
| [Express Checkout](docs/guides/express-checkout.md) | Pre-built CardFormDropIn payment form |
| [Custom Payment Forms](docs/guides/custom-payment-forms.md) | Build your own payment UI with SPLTextField |
| [Recaching](docs/guides/recaching.md) | CVV recaching for saved payment methods |
| [Error Handling](docs/guides/error-handling.md) | Error types, retry logic, user-friendly messages |

### Offsite & Alternative Payment Methods

| Guide | Description |
|-------|-------------|
| [Offsite Payments](docs/guides/offsite-payments.md) | PayPal, Sprel via Safari |
| [EBANX APM](docs/guides/ebanx-apm.md) | Pix, Boleto, OXXO, NuPay, Rapipago via EBANX |
| [Stripe APM](docs/guides/stripe-apm.md) | iDEAL, Bancontact, EPS, P24, SEPA via Stripe PaymentSheet |
| [Braintree APM](docs/guides/braintree-apm.md) | PayPal and Venmo via Braintree |

### 3D Secure (3DS) Authentication

| Guide | Description |
|-------|-------------|
| [3DS Global](docs/guides/3ds-global.md) | Forter-based 3D Secure authentication |
| [3DS Gateway-Specific](docs/guides/3ds-gateway-specific.md) | Gateway-managed 3DS authentication (e.g. Worldpay) |

### Customization & Platform Support

| Guide | Description |
|-------|-------------|
| [Theme & Styling](docs/guides/theme-and-styling.md) | Colors, typography, dark mode |
| [Security](docs/guides/security.md) | Screen prevention, PCI compliance |
| [Objective-C](docs/guides/objective-c.md) | Objective-C integration with delegates and wrappers |
