# Troubleshooting - Spreedly iOS SDK

Common integration issues and their solutions.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Build Errors](#build-errors)
- [Runtime Issues](#runtime-issues)
- [Payment Flow Issues](#payment-flow-issues)
- [3DS Issues](#3ds-issues)
- [Theme Issues](#theme-issues)
- [Objective-C Issues](#objective-c-issues)
- [Xcode Cloud / CI Issues](#xcode-cloud--ci-issues)
- [Getting Help](#getting-help)

---

## Installation Issues

### SPM: "No such module 'SpreedlyCore'"

**Cause:** The package dependency was added but the product wasn't linked to your target.

**Fix:**
1. In Xcode, select your app target > **General** > **Frameworks, Libraries, and Embedded Content**
2. Click **+** and add `SpreedlyCore`, `SpreedlySecurity`, and `SpreedlyUI`
3. Clean build folder (**Product > Clean Build Folder**) and rebuild

### SPM: Package resolution fails

**Cause:** Cached package data is stale or network issues.

**Fix:**
1. **File > Packages > Reset Package Caches**
2. **File > Packages > Resolve Package Versions**
3. If using a private repo, verify your GitHub token has read access

### CocoaPods: Pod not found

**Cause:** The podspec source is not configured or the repo is private.

**Fix for private repos:**
```ruby
pod 'SpreedlyCore', :git => 'https://{GitToken}@github.com/spreedly/checkout-ios-package.git'
```

Replace `{GitToken}` with a GitHub personal access token that has read access.

---

## Build Errors

### "Missing required module 'SpreedlySecurity'"

**Cause:** `SpreedlyUI` depends on both `SpreedlyCore` and `SpreedlySecurity`. All three core modules must be included.

**Fix:** Add all three required modules:
```swift
.product(name: "SpreedlyCore", package: "checkout-ios-package"),
.product(name: "SpreedlySecurity", package: "checkout-ios-package"),
.product(name: "SpreedlyUI", package: "checkout-ios-package"),
```

### "Framework not found Forter3DS"

**Cause:** 3DS support requires `Forter3DS` as a direct dependency in your app target. It is weak-linked from `SpreedlyCore` and not bundled.

**Fix:** Add `Forter3DS` to your app's SPM dependencies or CocoaPods Podfile. See the [3DS Global guide](3ds-global.md) for setup instructions.

### Bitcode errors

**Cause:** The pre-built XCFrameworks do not include Bitcode (Apple deprecated Bitcode in Xcode 14).

**Fix:** Disable Bitcode in your target's build settings: **Build Settings > Enable Bitcode > No**.

### "Duplicate symbols" or "Multiple commands produce"

**Cause:** Multiple versions of the SDK are being linked, or both SPM and CocoaPods are pulling in the same framework.

**Fix:** Use only one package manager. If migrating from CocoaPods to SPM, remove the pods first (`pod deintegrate`), then add SPM packages.

---

## Runtime Issues

### Crash on launch: "Library not loaded"

**Cause:** A framework is linked but not embedded in the app bundle.

**Fix:** In your target's **General > Frameworks, Libraries, and Embedded Content**, set all Spreedly frameworks to **Embed & Sign**.

### "Environment key is missing" or payment calls return 401

**Cause:** `Spreedly.shared` was not initialized with valid credentials before making API calls.

**Fix:** Initialize the SDK before presenting any payment UI:
```swift
Spreedly.shared.setCredentials(
    environmentKey: "your-env-key",
    token: token,
    nonce: nonce,
    timestamp: timestamp,
    certificateToken: certToken,
    signature: signature
)
```

### Card form is blank or fields don't appear

**Cause:** The `CardFormDropIn` view has zero height because it's not given enough space in the layout.

**Fix:** Ensure the parent view gives the form enough vertical space. In a `ScrollView` or `VStack`, the form will size itself. Avoid placing it inside a fixed-height container that's too small.

---

## Payment Flow Issues

### `onProcessingResult` fires but no `PaymentResult` arrives

**Cause:** You're not subscribed to the async payment results publisher.

**Fix:** Subscribe to payment results before presenting the form:
```swift
Spreedly.shared.subscribeToPaymentResults { paymentResult in
    switch paymentResult {
    case .success(let result):
        // Handle success
    case .failure(let error):
        // Handle failure
    }
}
```

For Objective-C, set the `paymentDelegate` on the `Spreedly.shared` instance.

### Offsite payment returns to app but status is unknown

**Cause:** The URL scheme or universal link handler is not forwarding the return URL to the SDK.

**Fix:** In your `AppDelegate` or `SceneDelegate`:
```swift
func application(_ app: UIApplication, open url: URL, options: [...]) -> Bool {
    Spreedly.shared.handleOffsiteReturn(url: url)
    return true
}
```

### Stripe APM PaymentSheet doesn't appear

**Cause:** The `StripeAPMConfig` is missing required fields, or the purchase hasn't been created on the backend yet.

**Fix:** Ensure your backend creates the purchase first and returns the `clientSecret`. Pass all required config:
```swift
let config = StripeAPMConfig(
    clientSecret: clientSecret,
    merchantDisplayName: "Your Store",
    returnURL: "yourapp://stripe-redirect"
)
```

---

## 3DS Issues

### 3DS challenge never appears

**Cause:** `Forter3DS` framework is not linked, or `doChallengeIfNeeded` is not called after payment creation.

**Fix:**
1. Verify `Forter3DS` is added as a dependency (see [3DS Global guide](3ds-global.md))
2. After receiving a payment result that requires 3DS, call `doChallengeIfNeeded()`
3. Subscribe to challenge results via `subscribeToThreeDSChallengeResults`

### Gateway-specific 3DS: Safari opens but nothing happens

**Cause:** The challenge URL from the gateway response is malformed or the gateway didn't return a 3DS challenge.

**Fix:** Check the `rawErrorResponse` in the payment failure details for the actual gateway response. Verify your backend is passing the 3DS challenge URL correctly.

---

## Theme Issues

### Custom theme not applying

**Cause:** Theme priority conflict. Component-level themes override global themes.

**Fix:** Check the theme priority order:
1. Custom theme passed directly to the component (highest)
2. Environment theme (`.spreedlyTheme()` modifier)
3. Global theme (`SpreedlyThemeManager.setGlobalTheme()`)
4. Default theme (lowest)

If a component has an explicit `theme` parameter, the global theme is ignored for that component.

### Dark mode not switching automatically

**Cause:** Only one theme was set, or both `theme` and `darkTheme` use the same value.

**Fix:** Set both light and dark themes:
```swift
SpreedlyThemeManager.setGlobalTheme(lightTheme: lightTheme, darkTheme: darkTheme)
```

See the [Theme & Styling guide](theme-and-styling.md) for details.

---

## Objective-C Issues

### "SpreedlyTheme" not accessible from Objective-C

**Cause:** `SpreedlyTheme` is a Swift-only protocol.

**Fix:** Use `SPLThemeConfig` for Objective-C theme configuration:
```objc
SPLThemeConfig *config = [[SPLThemeConfig alloc]
    initWithPrimaryColorHex:@"#0077C8"
    secondaryColorHex:@"#AFB4B5"
    formBorderColorHex:@"#D9D9D9"
    formBackgroundColorHex:@"#FFFFFF"
    fieldBackgroundColorHex:@"#F8F9FA"
    fieldLabelColorHex:@"#6C757D"
    borderRadius:8.0];
```

### Delegate methods not being called

**Cause:** The delegate object is being deallocated (not retained).

**Fix:** Store a strong reference to the delegate object. Common pattern:
```objc
@property (nonatomic, strong) CardFormDropInViewController *dropInVC;
```

---

## Xcode Cloud / CI Issues

### Build fails with "missing xcconfig"

**Cause:** `SpreedlyKeys.xcconfig` contains secrets and is gitignored. CI needs to generate it.

**Fix:** Use a `ci_post_clone.sh` script to generate the xcconfig from environment variables:
```bash
cat > "$CI_PRIMARY_REPOSITORY_PATH/Example/SpreedlySDKExample/SpreedlyKeys.xcconfig" << EOF
SPREEDLY_ENVIRONMENT_KEY = ${SPREEDLY_ENVIRONMENT_KEY}
SPREEDLY_SERVER_URL = https:/$()/your-server.example.com/api/v1
EOF
```

### Package.resolved desync

**Cause:** Local `Package.resolved` doesn't match what CI resolves.

**Fix:** Re-resolve packages locally and commit the updated `Package.resolved`:
1. **File > Packages > Reset Package Caches**
2. **File > Packages > Resolve Package Versions**
3. Commit the updated `Package.resolved` files

---

## Getting Help

- **GitHub Issues**: [Bug reports and feature requests](https://github.com/spreedly/checkout-ios-sdk/issues)
- **Spreedly Support**: [spreedly.com/support](https://spreedly.com/support/)
- **Spreedly Documentation**: [docs.spreedly.com](https://docs.spreedly.com/)
- **Security Issues**: See [SECURITY.md](../../SECURITY.md)
