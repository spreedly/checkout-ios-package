# Package Verification Guide

This guide explains how to verify the authenticity and integrity of Spreedly iOS SDK packages using SHA-256 checksums.

## Overview

Each release of the Spreedly iOS SDK includes SHA-256 checksums for all distributed packages. These checksums allow you to:

- **Verify authenticity**: Ensure packages haven't been tampered with
- **Ensure integrity**: Confirm packages were downloaded completely and correctly
- **Detect corruption**: Identify any transmission or storage errors

## Checksum Files

Each framework package includes a corresponding `.sha256` checksum file:

- `SpreedlyCore.zip.sha256` - Checksum for SpreedlyCore framework
- `SpreedlySecurity.zip.sha256` - Checksum for SpreedlySecurity framework
- `SpreedlyUI.zip.sha256` - Checksum for SpreedlyUI framework
- `SpreedlyStripeAPM.zip.sha256` - Checksum for SpreedlyStripeAPM framework
- `SpreedlyBraintree.zip.sha256` - Checksum for SpreedlyBraintree framework

## Locating Checksums

Checksums are distributed alongside packages in the package repository:

```
package-repo/
├── SpreedlyCore.zip
├── SpreedlyCore.zip.sha256
├── SpreedlySecurity.zip
├── SpreedlySecurity.zip.sha256
├── SpreedlyUI.zip
├── SpreedlyUI.zip.sha256
├── SpreedlyStripeAPM.zip
├── SpreedlyStripeAPM.zip.sha256
├── SpreedlyBraintree.zip
└── SpreedlyBraintree.zip.sha256
```

## Verification Methods

### Method 1: Using `shasum` (macOS/Linux)

The `shasum` command is available on macOS and most Linux distributions.

#### Verify a single package:

```bash
# Download the package and checksum file
# Example: SpreedlyCore.zip and SpreedlyCore.zip.sha256

# Verify using the checksum file
shasum -a 256 -c SpreedlyCore.zip.sha256
```

If your `.sha256` file contains a path prefix (for example `distribution/SpreedlyCore.zip`), run the command from a directory that matches that path or adjust the file path accordingly.

Expected output on success:
```
SpreedlyCore.zip: OK
```

Expected output on failure:
```
SpreedlyCore.zip: FAILED
shasum: WARNING: 1 computed checksum did NOT match
```

#### Verify manually:

```bash
# Calculate the SHA-256 hash of the downloaded file
shasum -a 256 SpreedlyCore.zip

# Compare with the checksum file
cat SpreedlyCore.zip.sha256
```

The hashes should match exactly.

### Method 2: Using `sha256sum` (Linux)

On Linux systems, you can use `sha256sum`:

```bash
# Verify using the checksum file
sha256sum -c SpreedlyCore.zip.sha256

# Or verify manually
sha256sum SpreedlyCore.zip
cat SpreedlyCore.zip.sha256
```

### Method 3: Using OpenSSL

OpenSSL is available on most platforms:

```bash
# Calculate SHA-256 hash
openssl dgst -sha256 SpreedlyCore.zip

# Compare with checksum file
cat SpreedlyCore.zip.sha256
```

### Method 4: Programmatic Verification (Swift)

For automated verification in your build process:

```swift
import Foundation
import CryptoKit

func verifyChecksum(filePath: String, expectedChecksum: String) -> Bool {
    guard let fileData = FileManager.default.contents(atPath: filePath) else {
        return false
    }
    
    let hash = SHA256.hash(data: fileData)
    let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
    
    // Remove whitespace and newlines from expected checksum
    let cleanExpected = expectedChecksum.trimmingCharacters(in: .whitespacesAndNewlines)
    
    return hashString == cleanExpected
}

// Usage
let filePath = "/path/to/SpreedlyCore.zip"
let expectedChecksum = "abc123..." // From .sha256 file

if verifyChecksum(filePath: filePath, expectedChecksum: expectedChecksum) {
    print("✅ Checksum verified successfully")
} else {
    print("❌ Checksum verification failed")
}
```

### Method 5: Automated Verification Script

Create a verification script for batch checking:

```bash
#!/bin/bash

# verify_packages.sh - Verify all framework packages

set -e

FRAMEWORKS=("SpreedlyCore" "SpreedlySecurity" "SpreedlyUI")

for framework in "${FRAMEWORKS[@]}"; do
    PACKAGE="${framework}.zip"
    CHECKSUM_FILE="${PACKAGE}.sha256"
    
    if [ ! -f "$PACKAGE" ]; then
        echo "❌ Package not found: $PACKAGE"
        exit 1
    fi
    
    if [ ! -f "$CHECKSUM_FILE" ]; then
        echo "❌ Checksum file not found: $CHECKSUM_FILE"
        exit 1
    fi
    
    echo "Verifying $framework..."
    if shasum -a 256 -c "$CHECKSUM_FILE"; then
        echo "✅ $framework verified successfully"
    else
        echo "❌ $framework verification failed"
        exit 1
    fi
done

echo "✅ All packages verified successfully"
```

## Swift Package Manager Integration

Swift Package Manager automatically verifies checksums when using binary targets with URLs:

```swift
.binaryTarget(
    name: "SpreedlyCore",
    url: "https://github.com/spreedly/checkout-ios-package/releases/download/1.3.8-rc.3/SpreedlyCore.zip",
    checksum: "abc123..." // SHA-256 checksum
)
```

SPM will:
1. Download the package
2. Calculate its SHA-256 hash
3. Compare with the provided checksum
4. Reject the package if checksums don't match

**Always verify checksums are correctly specified in your Package.swift file.**

## Best Practices

### Before Integration

1. **Always download from official sources**: Only download packages from the official Spreedly package repository
2. **Verify checksums**: Always verify checksums before integrating packages
3. **Check the source URL**: Confirm you're pointing at the official Spreedly package repository
4. **Review release notes**: Check release notes for any security updates or changes

### During Integration

1. **Automate verification**: Include checksum verification in your CI/CD pipeline
2. **Monitor for mismatches**: Set up alerts if checksum verification fails
3. **Document versions**: Keep records of verified package versions and checksums

### Security Considerations

1. **Secure storage**: Store checksum files securely and verify their integrity
2. **HTTPS only**: Always download packages over HTTPS
3. **Verify checksum files**: Ensure checksum files themselves haven't been tampered with
4. **Regular updates**: Keep track of package updates and re-verify when upgrading

## Troubleshooting

### Checksum Mismatch

If checksum verification fails:

1. **Re-download the package**: The download may have been corrupted
2. **Verify network connection**: Ensure a stable connection during download
3. **Check file integrity**: Ensure the file wasn't modified after download
4. **Contact support**: If issues persist, contact Spreedly support

### Missing Checksum Files

If checksum files are missing:

1. **Check release artifacts**: Ensure you're accessing the correct release version
2. **Re-fetch the release**: Pull the artifacts again from the official Spreedly package repository
3. **Contact support**: Report missing checksum files to Spreedly support

### Verification Script Errors

If automated verification fails:

1. **Check file paths**: Ensure paths to packages and checksum files are correct
2. **Verify permissions**: Ensure read permissions on all files
3. **Update tools**: Ensure `shasum` or `sha256sum` is available and up to date

## Example: Complete Verification Workflow

```bash
#!/bin/bash

# Complete package verification workflow

set -e

VERSION="1.3.8-rc.3"
REPO_URL="https://github.com/spreedly/checkout-ios-package"
DOWNLOAD_DIR="./packages/${VERSION}"

# Create download directory
mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

# Download packages and checksums
echo "Downloading packages..."
curl -L -O "${REPO_URL}/releases/download/${VERSION}/SpreedlyCore.zip"
curl -L -O "${REPO_URL}/releases/download/${VERSION}/SpreedlyCore.zip.sha256"
curl -L -O "${REPO_URL}/releases/download/${VERSION}/SpreedlySecurity.zip"
curl -L -O "${REPO_URL}/releases/download/${VERSION}/SpreedlySecurity.zip.sha256"
curl -L -O "${REPO_URL}/releases/download/${VERSION}/SpreedlyUI.zip"
curl -L -O "${REPO_URL}/releases/download/${VERSION}/SpreedlyUI.zip.sha256"

# Verify all packages
echo "Verifying checksums..."
shasum -a 256 -c SpreedlyCore.zip.sha256
shasum -a 256 -c SpreedlySecurity.zip.sha256
shasum -a 256 -c SpreedlyUI.zip.sha256

echo "✅ All packages verified successfully"
```

## Additional Resources

- [SHA-256 Specification](https://csrc.nist.gov/publications/detail/fips/180/4/final)
- [Swift Package Manager Documentation](https://swift.org/package-manager/)
- [Package Security Best Practices](https://swift.org/package-manager/)

## Support

If you encounter issues with package verification:

1. Check this guide for troubleshooting steps
2. Review the release notes for the specific version
3. Contact Spreedly support with:
   - Package version and framework name
   - Checksum verification error messages
   - Download source and method used

---

**Last Updated**: Version 1.3.8-rc.3  
**Maintained By**: Spreedly Security Team

