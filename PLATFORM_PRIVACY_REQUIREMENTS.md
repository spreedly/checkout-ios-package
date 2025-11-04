# Platform-Specific Privacy Requirements

## Overview

This document outlines the privacy requirements and data handling practices for the Spreedly iOS SDK. The SDK is designed with privacy-first principles, ensuring that sensitive payment card data is processed securely and never stored persistently.

## Data Handling Principles

### Payment Card Data
- **Processing**: Payment card data is processed in memory only
- **Storage**: Card data is never stored on the device or in persistent storage
- **Transmission**: Card data is sent to Spreedly for tokenization via TLS (Transport Layer Security) encrypted connections

### Data Collection
- **None**: The SDK does not collect any personal data or user information
- **Purpose**: The SDK only facilitates the processing of payment card data for tokenization

### Persistent Storage
- **None**: The SDK does not use persistent storage for card data
- **Memory Only**: All card data operations occur in memory and are cleared immediately after processing

### User Tracking
- **None**: The SDK does not track users or collect analytics data
- **No Tracking**: No user behavior tracking, analytics, or profiling is performed

### Third-Party Sharing
- **Spreedly Only**: Card data is shared exclusively with Spreedly for the purpose of tokenization
- **No Third Parties**: No other third-party services receive card data or user information

## iOS-Specific Requirements

### Privacy Manifest (PrivacyInfo.xcprivacy)

The SDK includes a `PrivacyInfo.xcprivacy` file that declares:
- **NSPrivacyCollectedDataTypes**: Empty array (no data collection)
- **NSPrivacyTracking**: Not used
- **NSPrivacyTrackingDomains**: Not used
- **NSPrivacyAccessedAPITypes**: Declares only required APIs for core functionality

This manifest is automatically included in the SDK distribution and ensures compliance with Apple's App Privacy requirements.

### Platform Compliance

The SDK complies with:
- Apple's App Privacy requirements
- iOS App Store privacy guidelines
- Payment Card Industry Data Security Standard (PCI DSS) requirements
- General Data Protection Regulation (GDPR) requirements

## Data Transmission Security

All data transmission to Spreedly:
- Uses TLS 1.2 or higher
- Encrypts card data in transit
- Uses secure, authenticated endpoints
- Validates SSL certificates
- Does not transmit unencrypted card data

## Developer Responsibilities

When integrating the Spreedly iOS SDK:
1. **Do not store card data**: Never store card data in your app's persistent storage
2. **Use secure transmission**: Ensure your app uses secure network connections
3. **Follow PCI DSS guidelines**: Implement appropriate security measures in your application
4. **Respect user privacy**: Do not collect additional user data beyond what is necessary for payment processing

## Privacy Policy Integration

When using the Spreedly iOS SDK, you should include in your app's privacy policy:
- That payment card data is processed by Spreedly
- That card data is not stored on the device
- That data transmission is encrypted
- That no user tracking or analytics is performed by the SDK

## Support

For questions about privacy and data handling:
- Review the [Spreedly Privacy Policy](https://www.spreedly.com/privacy)
- Contact Spreedly support for privacy-related inquiries
- Review the [Integration Guide](INTEGRATION_GUIDE.md) for implementation details

## Version History

- **1.0.0** (Initial Release): Initial privacy documentation and PrivacyInfo.xcprivacy manifest

