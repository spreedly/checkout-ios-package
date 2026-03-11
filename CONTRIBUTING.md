# Contributing to Spreedly iOS SDK

We welcome contributions of any kind including bug fixes, new features, documentation improvements, and test coverage.

## Getting Started

1. Fork the [checkout-ios-sdk](https://github.com/spreedly/checkout-ios-sdk) source repository (not this distribution package)
2. Create a feature branch from `main` using the naming convention `HC-<ticket>-<short-description>`
3. Make your changes and ensure all tests pass
4. Submit a pull request

> **Note:** This repository (`checkout-ios-package`) is a **distribution-only** repo containing pre-built XCFrameworks. All source code changes happen in the [checkout-ios-sdk](https://github.com/spreedly/checkout-ios-sdk) repository. The release workflow automatically builds and publishes frameworks here.

## Development Requirements

- macOS 14+
- Xcode 16.1+ (16.4 recommended)
- Swift 5.10+
- iOS 14.0+ deployment target
- [SwiftLint](https://github.com/realm/SwiftLint) for code style enforcement

## Branch Naming

All branches must follow the pattern:

```
HC-<ticket-number>-<short-description>
```

Examples: `HC-1234-add-apple-pay`, `HC-567-fix-3ds-timeout`

## Commit Messages

All commit messages must begin with a Jira ticket prefix:

```
HC-<ticket-number> <description>
```

Examples: `HC-1234 Add Apple Pay support`, `HC-567 Fix 3DS challenge timeout`

## Pull Request Process

1. Ensure your branch is up to date with `main`
2. Verify all tests pass locally
3. Run SwiftLint and fix any violations
4. Create a PR with the title format `HC-<ticket> <description>`
5. Fill in the PR template with summary, description, and type of change
6. Request review from the iOS SDK team

## Code Style

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use SwiftLint rules defined in the project `.swiftlint.yml`
- All public APIs must have documentation comments
- Prefer value types (`struct`, `enum`) over reference types where appropriate
- Use `@objc` annotations for APIs that need Objective-C compatibility

## PCI Compliance

The Spreedly iOS SDK handles payment card data. All contributions must follow these rules:

- **Never** log or print raw card numbers, CVVs, or expiry dates
- Use `LogSanitizer.sanitize()` for any output that may contain sensitive data
- Use `SecureValueContainer` for sensitive values that persist beyond a single function scope
- Use `maskedToken(_:)` to display tokens (first 4 + last 4 characters only)
- New payment UI components must use `ScreenPreventionSecureView` or `ScreenPreventionManager.shared`
- Never store card data in persistent storage (UserDefaults, Keychain, files)

## Testing

- All new features require unit tests
- UI components require snapshot tests where applicable
- Run the full test suite before submitting a PR:
  ```bash
  xcodebuild test -workspace Spreedly.xcworkspace -scheme SpreedlyCore -destination 'platform=iOS Simulator,name=iPhone 16'
  ```

## Reporting Issues

- Use [GitHub Issues](https://github.com/spreedly/checkout-ios-sdk/issues) for bug reports and feature requests
- Include SDK version, iOS version, Xcode version, and steps to reproduce
- For security vulnerabilities, see [SECURITY.md](SECURITY.md)

## License

By contributing, you agree that your contributions will be licensed under the [Apache License 2.0](LICENSE).
