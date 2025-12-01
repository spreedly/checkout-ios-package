## [0.0.60] - 2025-12-01

### Release Type
**Patch Version** (Bug fixes and improvements - backward compatible)

### Changes
- Enhance CVV recaching and payment method retention features (#129)

### Change Requests
  - No Jira tickets found in commit messages

### PCI DSS Compliance
This release has been documented for PCI DSS compliance requirements:
- **Change Request Tracking**: All changes are tracked via Jira tickets (see above)
- **Version History**: Semantic versioning maintained (0.0.60 - Patch Version)
- **Security Validation**: All security scans and validations completed
- **SBOM**: Software Bill of Materials included in release artifacts
- **Audit Trail**: Complete release documentation available in this changelog

### Installation
```swift
// Swift Package Manager
.package(url: "https://github.com/spreedly/checkout-ios-package.git", from: "0.0.60")
```

```ruby
# CocoaPods
pod 'Spreedly', '~> 0.0.60'
```

---

## [0.0.59] - 2025-11-27

### Release Type
**Patch Version** (Bug fixes and improvements - backward compatible)

### Changes
- Hc 543 iOS use merchant reaching ap is in example (#128)
- Enhance SPLTextField to support dynamic placeholder and validation logic. Introduced a new property to track custom placeholders and updated the effective required status for CVC fields based on card type. Improved validation handling to ensure accurate feedback during user input, particularly for optional CVV scenarios. (#127)
- Hc 523 i os security checklist save sourcemaps on datadog (#126)

### Change Requests
  - No Jira tickets found in commit messages

### PCI DSS Compliance
This release has been documented for PCI DSS compliance requirements:
- **Change Request Tracking**: All changes are tracked via Jira tickets (see above)
- **Version History**: Semantic versioning maintained (0.0.59 - Patch Version)
- **Security Validation**: All security scans and validations completed
- **SBOM**: Software Bill of Materials included in release artifacts
- **Audit Trail**: Complete release documentation available in this changelog

### Installation
```swift
// Swift Package Manager
.package(url: "https://github.com/spreedly/checkout-ios-package.git", from: "0.0.59")
```

```ruby
# CocoaPods
pod 'Spreedly', '~> 0.0.59'
```

---

## [0.0.54] - 2025-11-18

### Release Type
**Patch Version** (Bug fixes and improvements - backward compatible)

### Changes
- Moved to ui component instead of modifier (#125)
- Increase CodeQL workflow timeout from 30 to 45 minutes for improved a… (#124)

### Change Requests
  - No Jira tickets found in commit messages

### PCI DSS Compliance
This release has been documented for PCI DSS compliance requirements:
- **Change Request Tracking**: All changes are tracked via Jira tickets (see above)
- **Version History**: Semantic versioning maintained (0.0.54 - Patch Version)
- **Security Validation**: All security scans and validations completed
- **SBOM**: Software Bill of Materials included in release artifacts
- **Audit Trail**: Complete release documentation available in this changelog

### Installation
```swift
// Swift Package Manager
.package(url: "https://github.com/spreedly/checkout-ios-package.git", from: "0.0.54")
```

```ruby
# CocoaPods
pod 'Spreedly', '~> 0.0.54'
```

---

## [0.0.53] - 2025-11-17

### Release Type
**Patch Version** (Bug fixes and improvements - backward compatible)

### Changes
- Hc 527 i os code ql workflow timeout issue (#123)
- Fixed issue with Elo (#122)
- Enhance CVC field handling in SpreedlyUI by updating placeholder and required messages to reflect optional status based on card type. Refactor SPLTextField to use a state variable for the placeholder, ensuring dynamic updates when card type changes. Add localization for "optional" text to improve user experience. (#121)
- Refactor test setup and teardown processes to utilize SingletonTestHelper for synchronous singleton resets. This change enhances test reliability by ensuring all singleton states are properly reset before and after each test, eliminating the need for manual state clearing in individual test cases. (#119)
- Hc 498 native i os the security code always accepts 3 4 digit (#120)

### Change Requests
  - No Jira tickets found in commit messages

### PCI DSS Compliance
This release has been documented for PCI DSS compliance requirements:
- **Change Request Tracking**: All changes are tracked via Jira tickets (see above)
- **Version History**: Semantic versioning maintained (0.0.53 - Patch Version)
- **Security Validation**: All security scans and validations completed
- **SBOM**: Software Bill of Materials included in release artifacts
- **Audit Trail**: Complete release documentation available in this changelog

### Installation
```swift
// Swift Package Manager
.package(url: "https://github.com/spreedly/checkout-ios-package.git", from: "0.0.53")
```

```ruby
# CocoaPods
pod 'Spreedly', '~> 0.0.53'
```

---

## [0.0.52] - 2025-11-14

### Release Type
**Patch Version** (Bug fixes and improvements - backward compatible)

### Changes
- Implemented basic Recaching (#118)
- Enhance card type detection in CardTypeDetector by adding support for UATP, UnionPay, Routex, Favacard, Copeplus, Cliper, and Tarjeta Axis. Updated formatting patterns for new card types to improve accuracy in card number presentation. (#117)
- Refactor card number masking logic in CardTypeDetector to dynamically determine digits to reveal based on card type and length. This enhancement improves the accuracy of masked card number formatting while preserving spaces, ensuring better user experience and validation consistency. (#116)
- Remove  Visa 19-digit card type from CardType enum and related logic in CardTypeDetector. Updated card number formatting and display properties to reflect the change, ensuring cleaner code and improved card type handling. (#115)
- Refactor SPLTextField to format card numbers before processing input (#114)
- Fixed by enabling observers even when the theme is not set (#113)
- Hc 489 i os issue with debug symbol paths in released package (#112)

### Change Requests
  - No Jira tickets found in commit messages

### PCI DSS Compliance
This release has been documented for PCI DSS compliance requirements:
- **Change Request Tracking**: All changes are tracked via Jira tickets (see above)
- **Version History**: Semantic versioning maintained (0.0.52 - Patch Version)
- **Security Validation**: All security scans and validations completed
- **SBOM**: Software Bill of Materials included in release artifacts
- **Audit Trail**: Complete release documentation available in this changelog

### Installation
```swift
// Swift Package Manager
.package(url: "https://github.com/spreedly/checkout-ios-package.git", from: "0.0.52")
```

```ruby
# CocoaPods
pod 'Spreedly', '~> 0.0.52'
```

---

## [0.0.51] - 2025-11-07

### Release Type
**Patch Version** (Bug fixes and improvements - backward compatible)

### Changes
- Enhance release workflow for iOS code signing and XCFramework re-signing

### Change Requests
  - No Jira tickets found in commit messages

### PCI DSS Compliance
This release has been documented for PCI DSS compliance requirements:
- **Change Request Tracking**: All changes are tracked via Jira tickets (see above)
- **Version History**: Semantic versioning maintained (0.0.51 - Patch Version)
- **Security Validation**: All security scans and validations completed
- **SBOM**: Software Bill of Materials included in release artifacts
- **Audit Trail**: Complete release documentation available in this changelog

### Installation
```swift
// Swift Package Manager
.package(url: "https://github.com/spreedly/checkout-ios-package.git", from: "0.0.51")
```

```ruby
# CocoaPods
pod 'Spreedly', '~> 0.0.51'
```

---

## [0.0.50] - 2025-11-07

### Release Type
**Patch Version** (Bug fixes and improvements - backward compatible)

### Changes
- Add script to remove DebugSymbolsPath references from XCFramework Info.plist files

### Change Requests
  - No Jira tickets found in commit messages

### PCI DSS Compliance
This release has been documented for PCI DSS compliance requirements:
- **Change Request Tracking**: All changes are tracked via Jira tickets (see above)
- **Version History**: Semantic versioning maintained (0.0.50 - Patch Version)
- **Security Validation**: All security scans and validations completed
- **SBOM**: Software Bill of Materials included in release artifacts
- **Audit Trail**: Complete release documentation available in this changelog

### Installation
```swift
// Swift Package Manager
.package(url: "https://github.com/spreedly/checkout-ios-package.git", from: "0.0.50")
```

```ruby
# CocoaPods
pod 'Spreedly', '~> 0.0.50'
```

---

## [0.0.49] - 2025-11-07

### Release Type
**Patch Version** (Bug fixes and improvements - backward compatible)

### Changes
- Refactor Package.swift parsing and dependency mapping in release workflow (#111)

### Change Requests
  - No Jira tickets found in commit messages

### PCI DSS Compliance
This release has been documented for PCI DSS compliance requirements:
- **Change Request Tracking**: All changes are tracked via Jira tickets (see above)
- **Version History**: Semantic versioning maintained (0.0.49 - Patch Version)
- **Security Validation**: All security scans and validations completed
- **SBOM**: Software Bill of Materials included in release artifacts
- **Audit Trail**: Complete release documentation available in this changelog

### Installation
```swift
// Swift Package Manager
.package(url: "https://github.com/spreedly/checkout-ios-package.git", from: "0.0.49")
```

```ruby
# CocoaPods
pod 'Spreedly', '~> 0.0.49'
```

---

# Changelog

All notable changes to the Spreedly iOS SDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial changelog

---

## [0.0.47] - 2025-11-07

### Release Type
**Patch Version** (Bug fixes and improvements - backward compatible)

### Changes
- Enhance theming support in SpreedlyUI SDK (#110)
- Enhance card type handling and validation in SpreedlyUI (#109)
- Enhance SPLTextField for improved card number handling and validation (#108)
- Enhance screen prevention documentation and examples in Spreedly iOS SDK (#107)
- Update integration guide and add user-focused README for Spreedly iOS SDK (#106)
- Enhance screen prevention features in Spreedly iOS SDK (#105)
- Implement additional field validation in credit card processing (#104)
- Hc 441 i os security readiness checklist handle changelog and versioning (#103)
- Enhance package verification process and documentation (#102)
- Add privacy documentation for Spreedly iOS SDK (#100)
- Enhance release workflow to include CodeQL Advanced security scan checks (#99)
- Refactor release workflow to extract and upload dSYM files from XCFrameworks (#98)
- Hc 430 i os security readiness checklist add GitHub workflow to generate sbo ms (#97)
- Hc 432 i os security readiness checklist update GitHub workflow for dynamic application security testing dast (#96)
- Add canPerformAction method to FormFieldType and implement SensitiveEntryTextField for action management (#94)
- Add background observer to clear CVC field after 3 minutes in background (#93)
- Fixed Compilation issue with removed function (#89)
- Added sanitization to Datadog Logger (#88)
- Hc 426 i os security readiness checklist add GitHub workflow to sign and notarize xc frameworks (#87)
- Added debug logs in the workflow (#86)

### Change Requests
  - No Jira tickets found in commit messages

### PCI DSS Compliance
This release has been documented for PCI DSS compliance requirements:
- **Change Request Tracking**: All changes are tracked via Jira tickets (see above)
- **Version History**: Semantic versioning maintained (0.0.47 - Patch Version)
- **Security Validation**: All security scans and validations completed
- **SBOM**: Software Bill of Materials included in release artifacts
- **Audit Trail**: Complete release documentation available in this changelog

### Installation
```swift
// Swift Package Manager
.package(url: "https://github.com/spreedly/checkout-ios-package.git", from: "0.0.47")
```

```ruby
# CocoaPods
pod 'Spreedly', '~> 0.0.47'
```

---

