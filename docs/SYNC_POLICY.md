# Guide Sync Policy (SDK -> Package)

`checkout-ios-sdk/SpreedlyDocs/guides/` is the source of truth for merchant integration content.

`checkout-ios-package/docs/guides/` is the public distribution copy for package consumers.

## Sync rule

When any merchant-facing guide changes in `checkout-ios-sdk`, sync the corresponding file in `checkout-ios-package` in the same change cycle (same PR series or same release cycle).

## Version skew exception

If a package release is published before SDK docs are refreshed, treat `checkout-ios-package` as the canonical source for install version pins until SDK docs catch up.

## Scope

Sync these guide families at minimum:

- Getting started, error handling, troubleshooting
- Security and privacy
- Objective-C
- Offsite/APM guides (Stripe, Braintree, EBANX)
- 3DS guides (global and gateway-specific)

## Out of scope for package repo

Do not mirror SDK-internal engineering docs (CI/CD runbooks, architecture internals, release engineering internals). Link to SDK repo docs when needed.

## QA before publishing

1. No broken links in `docs/README.md` and guides.
2. Version examples are consistent across `README.md`, `CHANGELOG.md`, and `guides/getting-started.md`.
3. Privacy, security, and troubleshooting statements match current SDK behavior.
