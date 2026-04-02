# Versioning and Upgrades

This guide explains how package consumers should interpret SDK versions and safely upgrade.

## Versioning model

The SDK follows Semantic Versioning: `MAJOR.MINOR.PATCH`.

- **PATCH**: bug fixes and low-risk improvements
- **MINOR**: backward-compatible feature additions
- **MAJOR**: breaking changes that require code updates

## Before upgrading

1. Read [CHANGELOG.md](../../CHANGELOG.md) for the target version.
2. Check if any breaking changes are called out.
3. Confirm required modules (`SpreedlyCore`, `SpreedlySecurity`, `SpreedlyUI`, optional APM modules) are unchanged for your app.
4. Validate your iOS deployment target remains compatible.

## Upgrade checklist

| Step | What to do |
|------|------------|
| Pin target version | Update SPM/CocoaPods version to the target release |
| Build clean | Clean build folder and rebuild all app targets |
| Run critical flows | Card payment, 3DS, and any enabled APMs |
| Verify logging and telemetry | Confirm expected logs and non-sensitive telemetry behavior |
| Validate ObjC surface (if used) | Re-test delegate callbacks and bridge usage |
| Confirm rollback | Keep previous stable version pin documented |

## Rollback strategy

- **SPM**: pin back to the previous known-good version tag.
- **CocoaPods**: revert pod version constraints and run `pod install`.
- Re-run smoke tests after rollback.

## Related

- [Migration](migration.md)
- [Getting Started](getting-started.md)
- [CHANGELOG.md](../../CHANGELOG.md)
