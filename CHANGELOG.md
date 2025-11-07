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

