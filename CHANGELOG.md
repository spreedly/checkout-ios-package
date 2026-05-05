## [1.3.7] - 2026-05-05

### Release Type
**Patch Version** (Bug fixes and improvements - backward compatible)

### Change Requests
  - HC-1369

### PCI DSS Compliance
This release has been documented for PCI DSS compliance requirements:
- **Change Request Tracking**: All changes are tracked via Jira tickets (see above)
- **Version History**: Semantic versioning maintained (1.3.7 - Patch Version)
- **Security Validation**: All security scans and validations completed
- **SBOM**: Software Bill of Materials included in release artifacts
- **Audit Trail**: Complete release documentation available in this changelog

### Installation
```swift
// Swift Package Manager
.package(url: "https://github.com/spreedly/checkout-ios-package.git", from: "1.3.7")
```

```ruby
# CocoaPods
pod 'SpreedlyCore',      :git => 'https://github.com/spreedly/checkout-ios-package.git', :tag => '1.3.7'
pod 'SpreedlySecurity',  :git => 'https://github.com/spreedly/checkout-ios-package.git', :tag => '1.3.7'
pod 'SpreedlyUI',        :git => 'https://github.com/spreedly/checkout-ios-package.git', :tag => '1.3.7'
```

---

## [1.3.6] - 2026-05-05

### Release Type
**Patch Version** (Bug fixes and improvements - backward compatible)

### Change Requests
  - HC-1369

### PCI DSS Compliance
This release has been documented for PCI DSS compliance requirements:
- **Change Request Tracking**: All changes are tracked via Jira tickets (see above)
- **Version History**: Semantic versioning maintained (1.3.6 - Patch Version)
- **Security Validation**: All security scans and validations completed
- **SBOM**: Software Bill of Materials included in release artifacts
- **Audit Trail**: Complete release documentation available in this changelog

### Installation
```swift
// Swift Package Manager
.package(url: "https://github.com/spreedly/checkout-ios-package.git", from: "1.3.6")
```

```ruby
# CocoaPods
pod 'SpreedlyCore',      :git => 'https://github.com/spreedly/checkout-ios-package.git', :tag => '1.3.6'
pod 'SpreedlySecurity',  :git => 'https://github.com/spreedly/checkout-ios-package.git', :tag => '1.3.6'
pod 'SpreedlyUI',        :git => 'https://github.com/spreedly/checkout-ios-package.git', :tag => '1.3.6'
```

---

## [1.3.4] - 2026-04-27

### Release Type
**Patch Version** (Bug fixes and improvements - backward compatible)

### Changes
- HC-1317 Add runtime integrity checks, security blocking, and version bump to 1.3.4 (#237)

### Change Requests
  - HC-1317

### PCI DSS Compliance
This release has been documented for PCI DSS compliance requirements:
- **Change Request Tracking**: All changes are tracked via Jira tickets (see above)
- **Version History**: Semantic versioning maintained (1.3.4 - Patch Version)
- **Security Validation**: All security scans and validations completed
- **SBOM**: Software Bill of Materials included in release artifacts
- **Audit Trail**: Complete release documentation available in this changelog

### Installation
```swift
// Swift Package Manager
.package(url: "https://github.com/spreedly/checkout-ios-package.git", from: "1.3.4")
```

```ruby
# CocoaPods
pod 'SpreedlyCore',      :git => 'https://github.com/spreedly/checkout-ios-package.git', :tag => '1.3.4'
pod 'SpreedlySecurity',  :git => 'https://github.com/spreedly/checkout-ios-package.git', :tag => '1.3.4'
pod 'SpreedlyUI',        :git => 'https://github.com/spreedly/checkout-ios-package.git', :tag => '1.3.4'
```

---

# Changelog

All notable changes to the Spreedly iOS SDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Security

- HC-1369 **GPG-signed release tags**: Stable release tags are GPG-signed by the Spreedly iOS Release Bot. Verify any tag with `git tag -v X.Y.Z`. Contact Spreedly Support to obtain the verification key.

### Added

- **Runtime security protections** (`SecurityManager`): Centralized runtime integrity checks in `SpreedlyCore`. Includes debugger detection (sysctl `P_TRACED`), jailbreak/environment integrity (sandbox write test, dylib injection scan, filesystem artifact detection), and memory protection utilities (memset_s zeroing, scoped access pattern). All checks use public POSIX/Darwin/Foundation APIs — App Store safe.

- **Merchant opt-in jailbreak blocking**: New `blockJailbrokenDevices` property on `SpreedlyConfig` (defaults to `false`). When enabled, `Spreedly.setup(config:)` refuses to initialize on compromised devices and sets `Spreedly.initializationError` with a `SpreedlySecurityError` describing which signals fired. Works from both Swift and Objective-C.

- **Static blocking flag**: New `Spreedly.blockJailbrokenDevices` static property for merchants using `initializeSDK()` without a config object. Set before calling `initializeSDK()`.

- **`Spreedly.isDeviceTrusted`**: Read-only computed property that returns `false` when the device fails integrity checks and the SDK is blocked. Merchants can check this at any point.

- **3-layer security blocking**: When blocking is enabled on a compromised device, the SDK prevents all operations across three layers:
  - **Network layer**: `BlockedNetworkClient` injected into the blocked instance — every network call throws immediately, preventing any data from leaving the device.
  - **UI layer**: SwiftUI views (`CardFormDropIn`, `CVVRecachingView`, `DoChallengeIfNeeded`, `SPLTextField`) render as invisible when blocked, preventing card data entry. UIKit entry points (Stripe, Braintree, Offsite `present()` methods) reject at the call site via `SecurityManager.shared.allowPaymentOperation(provider:)`.
  - **3DS layer**: Forter 3DS and Gateway-Specific 3DS integrations check `SecurityManager.shared.isDeviceBlocked` and emit failure results.

- **Security telemetry**: New `security_check_completed` and `sdk_init_blocked` events emitted during SDK initialization for Datadog observability.

### Changed

- **Renamed `Spreedly.isOperational` → `Spreedly.isDeviceTrusted`**: The new name aligns with industry conventions (Apple `canMakePayments`, Google `isReadyToPay`) and clearly communicates that the check reflects device integrity status rather than general SDK readiness.

- **Auto-dismiss on blocked devices**: `CardFormDropIn`, `CVVRecachingView`, and `DoChallengeIfNeeded` now automatically dismiss their sheets when presented on a blocked device — merchants no longer need to guard presentations with `isDeviceTrusted` checks. Custom forms using `SPLTextField` directly still require a manual check (see [Custom Payment Forms](guides/custom-payment-forms.md#prerequisites)).

- **Defense-in-depth: `handleStripeReturnURL` gated**: `SpreedlyStripeAPMCheckout.handleStripeReturnURL(_:)` now checks `SecurityManager.shared.isDeviceBlocked` and returns `false` immediately on blocked devices. In practice the flow starts from `present()` which is already gated, so exploitation was unlikely — but the guard closes the gap for defense-in-depth.

### Added (Documentation & Governance)

- **Jailbreak blocking reference in `security.md`**: Per-component behavior table, error channel mapping, and testing instructions for `blockJailbrokenDevices`.
- **Jailbreak blocking quick-start in `getting-started.md`**: Setup snippet and link to full security guide.
- **Blocked-device notes in `express-checkout.md` and `recaching.md`**: Auto-dismiss behavior documented for `CardFormDropIn` and `CVVRecachingView`.
- **`SECURITY_CHECKLIST.md`**: Reusable checklist for new modules covering runtime integrity, telemetry, sensitive data, and code comments.
- **`runtime-security-enforcement.mdc` cursor rule**: Enforces `SecurityManager` checks at all payment entry points, with patterns for SwiftUI, UIKit, APM, and URL handlers.
- **Security step in `new-payment-module` skill**: Mandatory Step 2b wiring `allowPaymentOperation` and `isDeviceBlocked` checks before module scaffolding continues.
- **Blocked-device layering in `ARCHITECTURE.md`**: Documents how blocking propagates across network, UI, APM, and 3DS layers.
- **Runtime integrity section in `CONTRIBUTING.md`**: Adds `SecurityManager` requirements to the existing security guidance for contributors.

### Fixed

- HC-1317 **`initializeSDK()` recovery path**: `initializeSDK()` now clears a previous security block when the device assessment passes. Previously only `setup(config:)` had the recovery logic, so a blocked SDK could not recover through `initializeSDK()` even when the environment became clean.

### Security

- HC-1313 **Binary hardening**: API endpoint strings are no longer visible in plain text when inspecting the compiled framework binary. Covers `SpreedlyCore` and `SpreedlyStripeAPM` modules.

- HC-1314 **Release binary hardening via symbol stripping**: Enabled `DEPLOYMENT_POSTPROCESSING`, `STRIP_INSTALLED_PRODUCT`, `STRIP_STYLE=non-global`, `STRIP_SWIFT_SYMBOLS`, `DEAD_CODE_STRIPPING`, and `COPY_PHASE_STRIP` in the Release configuration of all 6 framework projects (SpreedlyCore, SpreedlySecurity, SpreedlyUI, SpreedlyStripeAPM, SpreedlyBraintree, SpreedlyAnalytics).

  **Before**: Distributed binaries shipped with full symbol tables — SpreedlyCore arm64 slice had 6,038 nlist entries (5,591 local symbols) exposing internal class names, method selectors, and implementation flow.

  **After**: Local symbol table entries reduced to 1 per architecture slice (99.98% reduction). String table dropped from 434 KB to 13 KB (97% reduction). Binary size reduced ~8%. All 102 public API symbols preserved. dSYM generation and crash symbolication unaffected.

  CI workflow (`build-frameworks.yml`) also passes strip settings as CLI overrides for belt-and-suspenders. Verification script (`build-integrity-verify-optimization.sh`) now warns if local symbols exceed threshold, catching accidental regressions.

### Changed

- HC-1315 **Symbol obfuscation — ABI metadata suppression**: Added `-Xfrontend -empty-abi-descriptor` to all 6 framework Release configs and CI build workflow.

  **Issue**: The Swift compiler generates `.abi.json` files inside each XCFramework slice containing a complete blueprint of every type — every class, struct, enum, protocol, their properties, methods, parameter types, return types, conformances, and memory layout. An attacker could open these files and read the full SDK internals without even using a disassembler.

  **What we did**: Added the `-Xfrontend -empty-abi-descriptor` compiler flag to all 6 framework project Release configs and both device/simulator CI build steps. This tells the compiler to emit empty stubs instead of full metadata.

  **Before**: Each `.abi.json` was ~2.4 MB per architecture slice (~36 MB across all 15 files in the distributed package), exposing every internal type definition.

  **After**: Each `.abi.json` reduced to 149 bytes (empty stub) — 99.99% reduction. The `.swiftinterface` files that consumers need for compilation are unaffected.

- HC-1315 **Symbol obfuscation — access level tightening**: Removed `public` from 10 network-layer implementation types that are not merchant-facing API.

  **Issue**: HC-1314 added `STRIP_STYLE=non-global` which strips `internal` symbols from the binary. But 10 network-layer types were unnecessarily marked `public`, so the stripper left them in. An attacker running `nm | swift-demangle` could see type names like `AuthenticationInterceptor` (reveals auth injection exists), `RetryInterceptor` (reveals retry strategy), `DefaultNetworkClient` (reveals HTTP pipeline architecture), and `NetworkClientBuilder` (reveals builder pattern) — mapping the SDK's internal network architecture.

  **What we did**: Removed `public` from these 10 types across 4 files: `NetworkInterceptor` + `AuthenticationInterceptor` + `RetryInterceptor` (NetworkInterceptor.swift), `NetworkClient` + `DefaultNetworkClient` + `NetworkClientBuilder` (NetworkClient.swift), `NetworkSession` + `URLSessionNetworkSession` + `MockNetworkSession` (NetworkSession.swift), `NetworkResponse` (NetworkResponse.swift). Swift defaults them to `internal`, and `STRIP_STYLE=non-global` from HC-1314 then strips them from the binary.

  **After**: All 10 type names gone from `nm` output. An attacker no longer knows the SDK uses interceptors, a builder pattern, or what the network architecture looks like. Three types (`NetworkRequest`, `BasicNetworkRequest`, `HTTPMethod`) remain `public` because merchant-facing API types inherit from them — but these reveal only that HTTP requests exist, not how they're built or authenticated.

  **No breaking changes**: None of the internalized types were used by merchants or sibling modules. Tests access them via `@testable import`. All test targets, sibling modules (SpreedlyUI, SpreedlyBraintree, SpreedlyStripeAPM), and both Example apps (Swift + ObjC) build and pass.

### Fixed

- HC-1312 **Duplicate ObjC class resolution**: Eliminated runtime `objc: Class X is implemented in both` warnings caused by third-party dependencies (Stripe, Datadog, Braintree) being loaded twice — once baked into our XCFrameworks and once built from source by the package manager. Root cause: `checkout-ios-package` declared explicit SPM/CocoaPods dependencies on libraries already statically linked into the framework binaries, causing the Objective-C runtime to load two copies of every class.

  **Stripe fix** (SPM + CocoaPods): Added a CI build step (`embed-stripe-resources.sh`) that embeds Stripe's 6 resource bundles (localizations, `form_specs.json`, 3DS2 assets) directly into `SpreedlyStripeAPM.framework` during the archive process. This allows removing the `stripe-ios-spm` dependency and `SpreedlyStripeAPMDeps` target from `Package.swift`, and the `StripePaymentSheet` dependency from the podspec — without breaking Stripe's internal `Bundle(for: BundleFinder.self)` resource resolution.

  **Datadog fix** (CocoaPods only): Removed `s.dependency 'DatadogCore'` and `s.dependency 'DatadogLogs'` from `SpreedlyCore.podspec`. These are code-only dependencies already embedded in `SpreedlyCore.xcframework`. SPM was unaffected because `Package.swift` never declared these dependencies.

  **Braintree fix** (CocoaPods only): Removed `s.dependency 'Braintree/Core'`, `Braintree/PayPal`, `Braintree/Venmo`, and `Braintree/DataCollector` from `SpreedlyBraintree.podspec`. Same pattern — code already embedded in the XCFramework.

  Follows Apple's guidance from WWDC 2019 "Binary Frameworks in Swift" (Session 416): embed third-party code and resources inside your vendored framework rather than requiring consumers to separately resolve the same dependency.

### Added

- HC-1311 **Knowledge-transfer comments**: Added step-numbered flow annotations and "KT Overview" doc comments across SDK source (`Spreedly.swift`, `ValidatedField`, `SPLTextField`, `CardFormDropIn`, `BraintreeFlowController`, `SpreedlyStripeAPMCheckout`, `OffsitePaymentSafariFlow`) and all Example app payment flow views to onboard new engineers faster.

- HC-1311 **CocoaPods custom xcconfig guide**: New section in `getting-started.md` explaining wrapper xcconfig pattern when merchants use custom `.xcconfig` files alongside CocoaPods. Matching troubleshooting entry added.

- HC-1311 **CI workflow documentation**: Added full workflow reference to `.github/workflows/README.md` covering test-and-lint, PR validation, CodeQL, nightly, and DAST triggers.

- HC-1311 **DAST xcconfig stub**: Added `SpreedlyKeys.xcconfig` placeholder generation step in `dast-security.yml` so DAST builds don't fail when the gitignored file is missing.

### Changed

- HC-1324 **Version bump 1.3.2 → 1.3.3**: Updated `Version.xcconfig`, `SpreedlyVersion.swift`, `README.md`, and all doc version references across 11 files.

- HC-1311 **Version bump 1.3.0 → 1.3.1**: Updated `Version.xcconfig`, `SpreedlyVersion.swift`, `README.md`, and all doc version references.

- HC-1311 **Pin Forter3DS to exact 2.1.0**: Changed Forter3DS dependency from `from: "2.1.0"` (up-to-next-major) to `exact: "2.1.0"` in `Package.swift` and all Xcode project files. Updated guides (`getting-started`, `3ds-global`, `3ds-gateway-specific`) and dev docs (`3DS_GLOBAL_FLOW`, `DISTRIBUTION`, `FORTER3DS_DISTRIBUTION_PROPOSAL`, `SDK_TECHNICAL_SPECIFICATION`) to reflect exact pinning.

- HC-1311 **Package.resolved re-resolve (1.2.8 → 1.3.0)**: Updated Example app `Package.resolved` to latest published `checkout-ios-package` tag. Documented silent-drift risk and re-resolve requirement in `RELEASE_PROCESS.md`, `TESTFLIGHT_DISTRIBUTION.md`, and `VERSIONING.md`.

- HC-1311 **3DS gateway-specific flow annotations**: Added step-by-step callout comments to all code examples (SwiftUI, UIKit+Combine, Notification+Delegate, ObjC) in `3ds-gateway-specific.md` and `3DS_GATEWAY_SPECIFIC_FLOW.md`.

### Removed

- HC-1311 **Dead code and "Android parity" references**: Removed unused `cryptoData` case from `PaymentMethodType` and stripped "mirrors Android SDK" / "cross-platform parity" narrative from source comments and telemetry docs.

- HC-1301 **Version source of truth and release parity**: Introduced repo-root `Version.xcconfig` (`SPREEDLY_SDK_VERSION`) and `SpreedlyVersion.swift` (`SpreedlySDK.version`), wired all framework targets to `MARKETING_VERSION` from the xcconfig, and updated telemetry via `GlobalAttributes`. **Release SDK** reads the version from files (no workflow version-bump input), validates xcconfig/Swift match, gates on duplicate tags, generates optional GPG-signed `release-manifest-vX.Y.Z.json`, creates an SDK repo GitHub Release, and improves package/SDK doc sync. Added `.github/scripts/release.sh` (pre-flight) and `generate-release-manifest.sh`. Documented maintainer quick paths in VERSIONING, RELEASE_PROCESS, README, getting-started, CONTRIBUTING, TestFlight, SDK technical spec, and workflows README.

- **Documentation parity with Android SDK**: Added three new docs to match Android's documentation coverage:
  - `guides/testing-guide.md` — Merchant-facing testing guide with test card numbers, EBANX test data, 3DS test scenarios, flow-by-flow testing steps, error scenario testing, and a production readiness checklist.
  - `development/TESTING_GUIDE.md` — SDK developer testing guide with quick-reference commands, coverage thresholds (95% line / 93% branch), test module inventory, XCTest naming conventions, protocol-based mocking patterns, and CI integration details.
  - `development/DATADOG_INTEGRATION.md` — Datadog integration guide with zero-config quick start, configuration table, global attribute reference, LogSanitizer redaction rules, custom logger setup, Datadog query examples, and troubleshooting.

- HC-1278 **Gitleaks secret scanning (CI + pre-commit)**: Added `.gitleaks.toml`, `.gitleaksignore`, `.github/workflows/secret-scanning.yml` (Gitleaks SARIF upload, iOS Spreedly pattern grep, failing summary job), and a **`pre-commit`** hook running `gitleaks protect --staged`, installed via `setup-git-hooks.sh`. Documented in `development/SECRET_SCANNING.md`, `development/GIT_HOOKS.md`, `development/CONTRIBUTING.md`, and `.github/workflows/README.md`. CI scans the checked-out tree only (`--no-git`) so new leaks in tracked files are gated without blocking on legacy history.

### Changed

- HC-1278 **Gitleaks: allowlist `*.md`**: Markdown files are excluded from Gitleaks path matching in `.gitleaks.toml` so README and doc code fences do not trip generic default rules (e.g. illustrative AWS/Sidekiq-shaped strings). Source, plist, and xcconfig remain scanned; **GitHub Secret Scanning** still applies to pushes. Documented in `development/SECRET_SCANNING.md`.

- HC-1278 **When scanning runs (contributor docs)**: Documented timing for local `pre-commit` vs GitHub **Secret Scanning** workflow (PRs, pushes to `main`/`develop`, post-merge push) in `development/CONTRIBUTING.md`, `development/GIT_HOOKS.md`, and `development/SECRET_SCANNING.md`; noted in `scripts/hooks/pre-commit` header.

- HC-1278 **Secret scanning documentation alignment**: Removed unreleased changelog entry and cross-links that bundled a git-history rewrite runbook with HC-1278; `development/SECRET_SCANNING.md` now frames the `.github/scripts/` + `scripts/` automation stack, adds operator notes (SARIF, Stripe `pk_*` shapes in rules), a generic GitHub sensitive-data link, `*Tests/` policy (fake tokens only), and a **Maintainers: after merge** checklist (branch protection on **Security Scan Summary**, contributor Gitleaks/hooks announcement). Added a **Security and credential scanning** section to root `README.md` and listed `secret-scanning.yml` in `development/WORKFLOW_IMPROVEMENTS.md`.

- HC-1278 **Secret scanning in dev quick reference and TestFlight docs**: Updated `development/DEVELOPER_QUICK_REFERENCE.md` with Secret Scanning as a required PR check, local Gitleaks/hooks setup, failure guidance, and related-doc links. Added `development/TESTFLIGHT_DISTRIBUTION.md` section clarifying Gitleaks runs on GitHub only, not Xcode Cloud.

- HC-1278 **Secret scanning (Swift + xcconfig)**: Extended `.gitleaks.toml` and **Spreedly pattern scan** with multi-shape Swift literals for `environmentKey`, `certificateToken`, `forterSiteId` (**8+ hex**, matching `SPREEDLY_FORTER_SITE_ID`), `nonce`, `signature`, `accessSecret`, `spreedlyApiKey`, Stripe publishable keys (`pk_*` with **underscore** suffix per real `STRIPE_PUBLISHABLE_KEY` values), and long `clientSecret`. Added **xcconfig-only** Gitleaks rules and CI greps keyed like `SpreedlyKeys.xcconfig.example` (`SPREEDLY_ENVIRONMENT_KEY`, `SPREEDLY_FORTER_SITE_ID`, `SPREEDLY_API_KEY`, `STRIPE_PUBLISHABLE_KEY`, `*_GATEWAY_TOKEN`, `SPREEDLY_ACCESS_SECRET`). Documented in `development/SECRET_SCANNING.md` and `.github/workflows/README.md`.

- HC-1302 **Gateway-specific 3DS documentation improvements**: Clarified `DoChallengeIfNeeded` as the recommended entry point versus the programmatic `startFlow` API. Added `TransactionStatus` JSON decoding guidance and code snippets to the merchant guide. Documented the two `checkTransactionStatus` calls made by `DoChallengeIfNeeded`, the `onStatusUpdate` callback, frictionless/direct-challenge lifecycle paths, and a cross-platform key-types reference table. Updated `3ds-gateway-specific.md`, `3DS_GATEWAY_SPECIFIC_FLOW.md`, and `GATEWAY_SPECIFIC_FLOWCHARTS.md`.

- HC-1302 **Documentation accuracy audit**: Corrected integration guides and SDK technical documentation for global and gateway-specific 3DS, Stripe APM cancel semantics, Braintree URL handling, `PaymentResult` and `subscribeToPaymentResults`, `reset()` behavior, recaching, testing flows, architecture and Datadog wiring, CI workflow README, and SwiftLint job behavior. Aligned DocC and SpreedlyUI README examples with current APIs. Synced distribution and install snippets to **checkout-ios-package 1.3.0** (SPM `from:`, CocoaPods `~> 1.3` / `:tag`).

- HC-1302 **Version 1.3.0 alignment**: Aligned `Version.xcconfig`, `SpreedlyVersion.swift`, README, and integration docs with latest published checkout-ios-package **1.3.0**. WCAG example-app UI tests use criterion name wording only so strings are not confused with SDK patch versions.

### Removed

- **Remove unsupported Rapipago payment method**: Removed `.rapipago` from `OffsitePaymentMethodType` and `OffsiteGateway` enums. Rapipago was added as an enum case but was never implemented or supported on any platform. All documentation references removed from ebanx-apm, getting-started, offsite-payments guides, and READMEs.

- HC-1278 **Local Gitleaks fixture scripts and example-app comments**: Removed `scripts/verify-spreedly-config-manager-gitleaks.sh`, `scripts/gitleaks-local-test-snippets.example`, and the optional Gitleaks verification comment block from `SpreedlyConfigManager.swift` so the tree does not contain secret-shaped sample strings or matrix tooling. Contributors continue to rely on **`gitleaks protect --staged`** (when hooks are installed) and **`secret-scanning.yml`** in CI.

- HC-1302 **Remove unsupported NuPay Recurrent payment method**: Removed `.nupayRecurrent` from `OffsitePaymentMethodType` enum and all documentation references (ebanx-apm, getting-started, offsite-payments guides, EBANX_FLOW dev doc). NuPay Recurrent was declared in the enum but never implemented in the SDK or example app.

### Fixed

- HC-1302 **CI `hashFiles` timeout on cache keys**: `test-and-lint`, CodeQL, and nightly workflows used deep `**/*.pbxproj` globs in `actions/cache` keys; GitHub’s `hashFiles` helper can exceed its 120s limit and fail the job before tests run. Cache keys now hash explicit `…/project.pbxproj` paths (and CodeQL includes `SpreedlyCore`’s `Package.resolved`). See `development/WORKFLOW_IMPROVEMENTS.md`.

- HC-1302 **Objective-C example app token display**: Result screens now use `Spreedly.maskedToken` for transaction and recache token labels (including accessibility) so full tokens are not shown in the demo UI.

- HC-1301 **Release workflow YAML validation**: Removed `secrets` from `if:` and from boolean `env` expressions on the GPG import and release-manifest steps. GitHub rejects those expressions (secrets are not available when workflow conditionals are evaluated), which produced a workflow file error and zero jobs on push. Signing is now gated with shell checks on `SIGNING_KEY` only.

- HC-1278 **Gitleaks SARIF upload token permissions**: The Gitleaks job in `secret-scanning.yml` now grants **`actions: read`** (with `security-events: write`) so `github/codeql-action/upload-sarif` can call the Actions API for workflow-run metadata, eliminating **“Resource not accessible by integration”** annotations when the scan itself is clean. Documented in `.github/workflows/README.md` and `development/WORKFLOW_IMPROVEMENTS.md`. SARIF upload remains **`continue-on-error`** as a safety net.

- HC-1278 **Secret Scanning workflow (Spreedly job + SARIF upload)**: The Spreedly pattern scan step failed on GitHub-hosted runners with bash parse errors (`unexpected EOF while looking for matching '''`) from YAML-injected inline scripts and from unsafe `grep -E "$VAR"` when EREs contained literal quotes. The scan now runs from `.github/scripts/spreedly-ios-pattern-scan.sh` with `printf`-built patterns using a safe `qc="[\"']"` quote class (no fragile `'\''` escaping). Long EREs still use temp files + `grep -f`. The Gitleaks SARIF upload step is `continue-on-error: true` when the code scanning API returns "Resource not accessible" while Gitleaks passed. The Spreedly grep pass excludes `*.example` template files.

- HC-1278 **Swift secret regex and `String` types**: Gitleaks and CI patterns used `(?::\s*String\?)?` on `let`/`var` lines, which matched only Swift’s optional `String?` and not plain `: String`. Updated to `(?::\s*String\??)?` so assignments align with real Swift (and with values shaped like `SpreedlyKeys.xcconfig.example`). Added a key-to-shape table in `.gitleaks.toml` comments.

- HC-1274 **Pending/processing status UI in merchant examples**: SwiftUI and Objective-C payment example flows displayed `processing` and `pending` states as success or error messages, which made in-progress transactions look final. Status handling now renders a dedicated pending message style across Offsite, EBANX, Stripe APM, and Braintree examples so intermediate gateway states are shown consistently and clearly.

## [1.2.7] - 2026-03-20

Major focus of this release: **Stripe APM distribution and payment flow fixes**. HC-1268 resolves CocoaPods and SPM issues so merchants using SpreedlyStripeAPM get transitive Stripe dependencies automatically. HC-1179 fixes the pending-vs-processing status discrepancy for Stripe APM payments (iDEAL, SEPA). Also includes source field and sdkPlatform enum (HC-1263), thread safety and internal refactoring (HC-1242), Xcode Cloud TestFlight fix (HC-1249), and comprehensive documentation audit (HC-1265).

### Added

- HC-1234 **`sdk_platform` global telemetry attribute**: New `sdkPlatform` field on `SpreedlyConfig` (default `.ios`). React Native bridges pass `.reactNative` to distinguish integration surface in Datadog.
- HC-1263 **`source` field on payment method creation**: All payment method creation requests (credit card JSON and offsite/APM form-encoded) now include a `source` field identifying the checkout SDK platform (e.g. `"checkout-ios"`, `"checkout-react-native"`). This syncs with the Android SDK's equivalent change (HC-1255).
- HC-1242 **`TelemetryEventsObjCBridge`**: ObjC-compatible wrapper exposing typed `TelemetryEvents` methods so ObjC consumers and bridge layers can emit telemetry without Swift-only API.
- HC-1242 **Braintree test coverage**: Added `BraintreeCheckoutFlowTests`, `BraintreeFlowResultTests`, and `BraintreePaymentTypeTests` for checkout flow, result mapping, and payment type handling.

### Fixed

- HC-1179 **Stripe APM pending vs processing discrepancy**: iOS showed "pending" for Stripe APM payments (e.g. iDEAL, SEPA) while Android and Web showed "processing". The SDK now awaits Spreedly's transaction redirect endpoint (`GET .../transaction/{token}/redirect`) before the first status poll, matching Android's approach. In web flows this redirect happens naturally via the browser; for native PaymentSheet flows the SDK triggers it programmatically so Spreedly can sync status with Stripe before polling.
- HC-1263 **`setConfig()` not propagating `sdkPlatform`**: When the SDK was already initialized, calling `Spreedly.setup()` again took the `setConfig()` path which updated the config object but never set `GlobalAttributes.shared.sdkPlatform`. This caused telemetry and the `source` field to keep the stale platform value (e.g. `"checkout-ios"`) even when `.reactNative` was passed. Now `setConfig()` propagates `sdkPlatform` to `GlobalAttributes`.
- HC-1251 **Card number field paste and display**: Pasted input (e.g. `4111-1111-1111-1111` or `4111.1111.1111.1111`) was shown with dashes/dots and non-digits were accepted. The field now normalizes all input to digits only and displays with space-separated groups only (e.g. `4111 1111 1111 1111`). Masked state also uses space formatting.
- HC-1242 **NetworkSession broken continuation**: `URLSessionNetworkSession.performRequest(_:with:)` never resumed its continuation, causing callers to hang indefinitely. Now delegates to the primary `performRequest(_:)`.
- HC-1242 **Memory leak in Bold Text observers**: `SPLTextField` and `CardFormDropIn` registered `boldTextStatusDidChangeNotification` observers but never stored or removed them. Observers are now tracked and cleaned up in `onDisappear`.
- HC-1242 **Race condition in LoggerManager**: `getEnvironmentKey()` was called on the caller's thread outside the logger queue, creating a data race when Spreedly config changed concurrently. Now called inside the serialized queue block.
- HC-1242 **Thread safety in GatewaySpecific3DSLifecycle**: `currentState` was read and written from multiple threads without synchronization. Now protected by `stateLock` via a thread-safe computed property.
- HC-1242 **APIErrorHandler design bug**: `clearFieldError(for:)` silently called `clearGeneralError()`, discarding unrelated general errors when any field error was cleared. Field-level clears are now isolated.
- HC-1242 **CardFormDropIn timing hack**: Replaced 50ms `asyncAfter` delay (race condition with `clearAllErrors()`) with deterministic `DispatchQueue.main.async` sequencing.
- HC-1242 **ObjC Stripe APM delegate leak**: `StripeAPMPaymentFlowViewController` did not nil-out `paymentDelegate` on dealloc, risking dangling-pointer callbacks. Added `dealloc` cleanup.
- HC-1249 **Xcode Cloud TestFlight build failure**: `Package.resolved` was stale (pinned to an older `checkout-ios-package` version) and Xcode Cloud ignores runtime modifications made by `ci_post_clone.sh`. The `checkout-ios-package` release workflow now updates `Package.resolved` in `checkout-ios-sdk`, runs `xcodebuild -resolvePackageDependencies` to correct the revision SHA and originHash, commits the result, and creates the `testflight-*` tag on that commit. Xcode Cloud clones at the tag and gets a correct `Package.resolved` from the start. `ci_post_clone.sh` was simplified to only generate `SpreedlyKeys.xcconfig` and verify `Package.resolved` is present — all stale Package.resolved editing logic was removed.

### Changed

- **Documentation audit**: Optional Dependencies table now lists SpreedlyBraintree as primary Braintree module (not Braintree sub-packages). Added explicit "Do not use pod SpreedlyForter3DS" warning. Synced checkout-ios-package getting-started with SdkPlatform enum (not strings). Clarified Info.plist keys (add per integration, not all three). Updated Venmo AASA warning to reflect current status.
- HC-1265 **Documentation audit (Forter 3DS)**: Corrected install instructions for Forter3DS. The `SpreedlyForter3DS` module does not exist yet; docs now direct merchants to add Forter3DS directly — SPM from `https://bitbucket.org/forter-mobile/forter-ios.git`, CocoaPods via `pod 'Forter3DS', :git => '...'`. Removed all references to the non-existent SpreedlyForter3DS pod. Added Forter3DS to the optional modules list in getting-started. Clarified that a dedicated SpreedlyForter3DS module is planned for a future release.
- HC-1263 **`sdkPlatform` is now a `SdkPlatform` enum**: Replaced the `String?` parameter on `SpreedlyConfig` and `SpreedlyConfigGenerator` with a type-safe `SdkPlatform` enum (`.ios`, `.reactNative`). The enum's `value` property (`"checkout-ios"` / `"checkout-react-native"`) is used for both Datadog telemetry and the Core API `source` field. **Breaking**: callers passing `sdkPlatform: "react_native"` must change to `sdkPlatform: .reactNative`.
- HC-1242 **Telemetry migrated to typed events**: Replaced inline `emitTelemetryEvent(_:level:attributes:)` calls across SpreedlyUI with type-safe `TelemetryEvents.*` static methods (e.g. `TelemetryEvents.paymentSheetPresented()`, `.validationFailed(fieldErrors:errorCount:)`).
- HC-1242 **Lazy log evaluation**: All public log functions (`logVerbose`, `logDebug`, `logInfo`, `logWarn`, `logError`) now use `@autoclosure` for the message parameter with an early `isLevelEnabled` guard, avoiding string interpolation when the level is suppressed.
- HC-1242 **NetworkClient simplified**: Removed unnecessary `withCheckedThrowingContinuation { queue.async { Task { } } }` triple-wrapping in `DefaultNetworkClient.performRequest`. Now calls `executeRequest` directly via async/await.
- HC-1242 **Removed deprecated `String.hashValue`**: `SpreedlyLogger` Datadog attributes no longer include `message_hash` (non-deterministic across process launches since Swift 4.2). `unique_id` already provides deduplication.
- HC-1242 **Removed force unwraps**: `MockNetworkSession` uses `guard let` + thrown errors instead of `!`. `Spreedly.tokenFormatRegex` uses `try!` on the known-valid constant pattern instead of a `try?` + `!` fallback chain.
- HC-1242 **Dead code cleanup**: Removed commented-out PayPal/Venmo/Cryptocurrency/BankAccount/ApplePay/GooglePay payment method code from `BasePaymentMethodRequest` and `ConvenienceRequests`. Removed duplicate `.notConnectedToInternet` switch case, unused `CommonCrypto` import, `BlurBackgroundView`, `iconName(for:)`, unused `ValidatedField` methods (`reset`, `forceValidate`, `validate`) and `apiError` parameter, iOS 14 availability fallbacks (deployment target already >=14), and commented-out theme manager methods.
- HC-1242 **Example app cleanup**: Deleted `SpreedlyDevBridge.swift` (bridge APIs now in published SDK) and `TempFile.swift`. Removed unused `channel`/`redirectUrl` from gateway-specific purchase requests in both Swift and ObjC examples. Added Braintree URL scheme and PayPal/Venmo query schemes to ObjC Info.plist.
- HC-1242 **Test cleanup**: Removed 9 zero-value tests in `Forter3DSIntegrationTests` that only asserted `XCTAssertTrue(true)`. Renamed `Forter3DSDelegateErrorPathTests` to `Forter3DSDelegateMockErrorPathTests` for clarity.
- HC-1242 **Removed `GATEWAY_CHANGES.md`**: Deleted the redundant cross-gateway overview doc. Moved the unique cross-cutting content (payment methods comparison table, backend requirements quick reference, URL handling troubleshooting, React Native URL handling) into `guides/getting-started.md`. Replaced with `GATEWAY_SPECIFIC_FLOWCHARTS.md` containing detailed flow diagrams.

## [1.1.4] - 2026-03-11

### Changed
- HC-1234 Add telemetry events and attributes for payment flows, 3DS, network, and error tracking
- HC-1233 Audit fixes: version consistency, SBOM updates, documentation sync, PCI compliance improvements

## [1.1.3] - 2026-03-09

### Changed
- HC-1223 fix TestFlight validation by removing nested framework embed from SPLAccessibility (#207)

## [1.1.2] - 2026-03-09

### Changed
- HC-1223 fix Xcode Cloud build by migrating to SPM and generating xcconfig on CI (#206)

## [1.1.1] - 2026-03-09

### Changed
- HC-1223 update version references and documentation for 1.1.0 release (#205)

## [1.1.0] - 2026-03-09

### Added

- **Stripe APM Module** (`SpreedlyStripeAPM`): Stripe Alternative Payment Methods via native PaymentSheet
    - Supports iDEAL, Bancontact, EPS, P24, SEPA Debit
    - `SpreedlyStripeAPMCheckout` entry point with `StripeAPMConfig`
    - Backend-initiated flow: merchant creates purchase, SDK presents Stripe PaymentSheet
    - Automatic status polling after PaymentSheet completion
- **Braintree APM Module** (`SpreedlyBraintree`): Braintree PayPal and Venmo payments
    - `SpreedlyBraintreeCheckout` entry point with `BraintreeCheckoutConfig`
    - `BraintreePaymentType` enum for PayPal and Venmo selection
    - Nonce-based flow with merchant `/confirm.json` call
    - `BraintreeURLHandler` for deep link return handling
    - Full Objective-C support via `BraintreeURLHandlerObjC`
- **EBANX Offsite Payments**: Pix, Boleto Bancario, NuPay, NuPay Recurrent, OXXO, Rapipago via EBANX
    - Dedicated `OffsitePaymentMethodType` entries for each EBANX payment method
    - `DocumentId` support for EBANX-required customer identification
- **Gateway-Specific 3DS**: Gateway-managed 3D Secure authentication (e.g. Worldpay)
    - `GatewaySpecific3DSIntegration` for lifecycle management
    - Safari-based challenge presentation
    - Automatic status polling with device fingerprint handling
    - `GatewaySpecific3DSLifecycle` and `GatewaySpecific3DSEvent` models
- **Offsite Payment Integration**: Safari-based offsite payment flow for PayPal and Sprel
    - `SpreedlyOffsiteCheckout` with `SFSafariViewController` presentation
    - `handleOffsiteReturn(url:)` for universal link and custom scheme return handling
    - Dual `PaymentResult` delivery (initial token + completion status)
- **CVV Recaching**: `SpreedlyCVVRecachingView` for updating CVV on saved payment methods
    - Bottom sheet and dialog presentation modes via `ScreenPresentationMode`
    - `RecacheConfig` and `SavedCardInfo` for configuration
- **Screen Prevention**: `ScreenPreventionSecureView` blocks screenshots and screen recording for PCI compliance
- **Secure Value Container**: `SecureValueContainer` with AES-GCM encryption for sensitive card data lifecycle
- **Log Sanitization**: Automatic redaction of card numbers, tokens, and secrets in logs
- **Objective-C Support**: Full Objective-C compatibility via delegates, bridges, and `@objc` annotations
    - `SpreedlyPaymentDelegate`, `SpreedlyThreeDSChallengeDelegate`
    - `CardFormDropInViewController`, `SPLTextFieldViewController`, `CVVRecachingViewController`
    - `SPLThemeConfig`, `SpreedlyThemeManagerObjC`
- **Additional Fields**: Billing and shipping address fields passed directly to payment processing
    - `AdditionalField` enum with firstName, lastName, address, city, state, zip, country, phone, email, shipping fields
- **Card Brand Detection**: 50+ card brands with BIN pattern matching, Luhn validation, and brand-specific rules
    - Visa, Mastercard, Amex, Discover, JCB, Maestro, UnionPay, Elo, Dankort, Mada, Verve, and more
    - Custom validation algorithms for Naranja, Creditel, Passcard/Edenred
- **Theming**: Full theming system with light/dark mode support
    - `SpreedlyTheme` with colors, typography, spacing, border radius, shadows
    - Predefined `SpreedlyLightTheme` and `SpreedlyDarkTheme`
    - Dynamic Type and Bold Text accessibility support
- **Localization**: Localized strings for Core, UI, Braintree, and Stripe APM modules
- **DocC Documentation**: Documentation catalogs for SpreedlyCore, SpreedlyUI, SpreedlySecurity, and SpreedlyAnalytics

### Security

- Removed hardcoded Datadog client token from source; now injected at build time via CI secret
- Extended `LogSanitizer` to cover 13–19 digit PANs, expiry dates, environment keys, JSON card payloads, and phone numbers
- Added `clearSensitiveData()` on `CreditCardDataImpl` to zero PAN, CVV, and expiry after API calls
- Changed `encryptAES()` to return `nil` on failure instead of empty string for fail-safe handling
- Masked payment tokens in all example app views using `Spreedly.maskedToken(_:)`
- SDK automatically sanitizes error messages in FailedDetails, APIErrorHandler, and logging
- Added error logging when `SecureValueContainer` encryption fails

### Changed

- Datadog initialization now skips gracefully when no client token is configured (local/debug builds)
- `SecureValueContainer.registerValue` guards against encryption failure with diagnostic logging
- Improved thread safety in `GatewaySpecific3DSLifecycle` with dedicated `NSLock` for state transitions
- Extracted `insertProcessingToken` / `removeProcessingToken` helpers in `Spreedly` for safer lock usage
- Fixed expiration date two-digit year pivot (years 50–99 now map to 1900s)
- Replaced deprecated `UIApplication.shared.windows` with `connectedScenes` in theme detection
- Canceled previous Stripe APM checkout before presenting a new one to prevent stale state
- Downgraded swift-tools-version from 6.1 to 6.0 for broader compatibility

### Documentation

- Updated security guide with os_log persistence warnings, third-party SDK logging guidance, and `rawErrorResponse` handling
- Recommended `.none` log level for production builds
- Updated CocoaPods install examples to `~> 1.1` across README and getting-started guide
- Fixed broken markdown link in Stripe flow doc
- Removed outdated migration guide from SpreedlyUI DocC catalog
- Added CVV recaching accessibility hints

## [1.0.0] - 2026-03-08

### Added

- Initial release of Spreedly iOS SDK
- **SpreedlyCore**: Core payment processing, API client, 3DS (Forter global), models, and Combine publishers
- **SpreedlyUI**: Card form drop-in (`CardFormDropIn`), hosted fields (`SPLTextField`), card brand icons, validation
- **SpreedlySecurity**: AES-GCM encryption (`SPLSecurity`), secure value storage (`SecureValueContainer`)
- **SpreedlyAnalytics**: Logging and observability
- Swift Package Manager and CocoaPods distribution via `checkout-ios-package`
- Example app with SwiftUI and Objective-C demonstrations

### Compatibility

- iOS 14.0+ (minimum deployment target)
- Swift 5.10+
- Xcode 16.1+

---

## Versioning

This project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html):

- **MAJOR** version for incompatible API changes
- **MINOR** version for backwards-compatible functionality additions
- **PATCH** version for backwards-compatible bug fixes

### Support

- **Minimum iOS**: 14.0
- **Swift**: 5.10+
- **Xcode**: 16.1+

For detailed integration guides, see the [documentation index](README.md).
