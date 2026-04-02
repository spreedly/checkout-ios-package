# Migration Guide

Use this guide when moving between SDK versions published in `checkout-ios-package`.

## Recommended migration flow

1. Identify current and target versions.
2. Review [CHANGELOG.md](../../CHANGELOG.md) entries between those versions.
3. Apply any required API/config updates in your app.
4. Validate end-to-end payment paths in a staging environment.
5. Roll out gradually, then monitor errors and support signals.

## Migration checklist

| Area | Verify |
|------|--------|
| Initialization | `initializeSDK()` and `setup(config:)` still called in correct app lifecycle points |
| Auth payload | Backend still returns fresh signed params per session |
| UI forms | `CardFormDropIn` or `SPLTextField` flows still render and validate correctly |
| 3DS/APM | Enabled payment methods complete successfully |
| Error handling | Existing `PaymentResult` handling still covers failure/canceled/timeout paths |
| Privacy/security | Data handling and screenshot protection behavior unchanged |
| Objective-C (if applicable) | Delegates and wrappers compile and behave as expected |

## If you hit regressions

- Revert to your previous package version pin.
- Collect repro steps and sanitized logs.
- Open a support request: [spreedly.com/support](https://spreedly.com/support/)

## Related

- [Versioning and Upgrades](versioning-and-upgrades.md)
- [Troubleshooting](troubleshooting.md)
- [Error Handling](error-handling.md)
