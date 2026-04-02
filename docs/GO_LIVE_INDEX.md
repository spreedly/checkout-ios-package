# Go-Live Index (iOS SDK)

Main entry point for **production readiness** docs in this repo. Each link points to the source of truth, so steps are not repeated on this page.

**Scope:** iOS SDK frameworks (XCFrameworks), GitHub Actions CI/CD, Xcode Cloud / TestFlight, and Datadog telemetry wired in the SDK. It does **not** cover Spreedly Core / backend operations, Android, Web, or React Native SDKs.

## Where each team should start

| Team | Start here |
|----------|------------|
| Engineering | [CONTRIBUTING](development/CONTRIBUTING.md), [Workflow Improvements / CI/CD](development/WORKFLOW_IMPROVEMENTS.md), [Release Process](development/RELEASE_PROCESS.md), [Architecture](development/ARCHITECTURE.md) |
| QA | [Release Gate Criteria](development/RELEASE_PROCESS.md#release-gate-criteria), [QA Verification Checklist](development/RELEASE_PROCESS.md#9-qa-verification-checklist), [TestFlight Distribution](development/TESTFLIGHT_DISTRIBUTION.md), [CONTRIBUTING -- Testing](development/CONTRIBUTING.md#testing) |
| DevOps / release | [Deployment Runbook](development/WORKFLOW_IMPROVEMENTS.md#deployment-runbook-sdk-artifact), [Release Process](development/RELEASE_PROCESS.md), [Package Verification](development/PACKAGE_VERIFICATION.md), [Distribution](development/DISTRIBUTION.md) |
| Customer success / support | [Getting Started](guides/getting-started.md), [Production Integration Checklist](guides/getting-started.md#production-integration-checklist), [Customer Troubleshooting](guides/error-handling.md#customer-troubleshooting), [Privacy](guides/privacy.md) |

## Section guide

| Section | Topic | Document |
|---------|-------|----------|
| 1 | Deployment / CI-CD / rollback | [Deployment Runbook](development/WORKFLOW_IMPROVEMENTS.md#deployment-runbook-sdk-artifact), [Testing Matrix](development/WORKFLOW_IMPROVEMENTS.md#testing-matrix), [When Builds Fail](development/WORKFLOW_IMPROVEMENTS.md#when-builds-fail) |
| 2 | Test strategy / release gates / sign-off | [Release Gate Criteria](development/RELEASE_PROCESS.md#release-gate-criteria), [QA Verification Checklist](development/RELEASE_PROCESS.md#9-qa-verification-checklist) |
| 3 | Architecture | [ARCHITECTURE.md](development/ARCHITECTURE.md) |
| 4 | Contribution | [CONTRIBUTING.md](development/CONTRIBUTING.md) |
| 5 | Monitoring / telemetry | [Telemetry Spec -- Operational Readiness](development/TELEMETRY_SPEC.md#operational-readiness), [Event Catalog](development/TELEMETRY_SPEC.md#event-catalog) |
| 6 | Customer integration docs | [Getting Started](guides/getting-started.md), [Production Integration Checklist](guides/getting-started.md#production-integration-checklist), [Root README](../README.md) |
| 7a | Customer troubleshooting | [Error Handling -- Customer Troubleshooting](guides/error-handling.md#customer-troubleshooting) |
| 7b | Engineering troubleshooting docs | [When Builds Fail](development/WORKFLOW_IMPROVEMENTS.md#when-builds-fail), [Release Troubleshooting](development/RELEASE_PROCESS.md#11-troubleshooting), [Troubleshooting Guide](guides/troubleshooting.md) |
| 8 | Release strategy | [Release Strategy](development/RELEASE_PROCESS.md#release-strategy), [Versioning](development/VERSIONING.md) |

## Go-live readiness checklist

| Item | Verify | Owner | Status |
|------|--------|-------|--------|
| PR CI green | [Workflow overview](development/WORKFLOW_IMPROVEMENTS.md#overview-of-all-github-actions-workflows) + branch protection | `[TBD]` | `[ ]` |
| Release workflow documented | [Deployment Runbook](development/WORKFLOW_IMPROVEMENTS.md#deployment-runbook-sdk-artifact) | `[TBD]` | `[ ]` |
| Secrets present in GitHub | [Secret Scanning](development/SECRET_SCANNING.md) | `[TBD]` | `[ ]` |
| Release gates agreed | [Release Gate Criteria](development/RELEASE_PROCESS.md#release-gate-criteria) | `[TBD]` | `[ ]` |
| Sign-off template in use | [Release Gate Criteria -- Sign-off](development/RELEASE_PROCESS.md#release-gate-criteria) | `[TBD]` | `[ ]` |
| Observability plan | [Operational Readiness](development/TELEMETRY_SPEC.md#operational-readiness) | `[TBD]` | `[ ]` |
| Customer docs linked | [Production Integration Checklist](guides/getting-started.md#production-integration-checklist) | `[TBD]` | `[ ]` |
| Support playbook | [Customer Troubleshooting](guides/error-handling.md#customer-troubleshooting) | `[TBD]` | `[ ]` |
| Architecture understood | [ARCHITECTURE.md](development/ARCHITECTURE.md) | `[TBD]` | `[ ]` |
| Legal / privacy | [Privacy](guides/privacy.md), [Platform Privacy](development/PLATFORM_PRIVACY_REQUIREMENTS.md) | `[TBD]` | `[ ]` |

## See also

- [Documentation index](README.md)
- [Changelog](CHANGELOG.md)
