# Why CocoaPods Users Need a Small Stripe Bundle Step

If you use **SpreedlyStripeAPM** with **CocoaPods**, you’ll need to add a short post-install step so Stripe’s resources are found at runtime. This doc explains why that’s needed and where the naming difference actually comes from—so it’s clear this isn’t a bug in our SDK, but how Stripe and the iOS ecosystem name things differently depending on how you install them.

**Last updated:** 2025-03

---

## The gist

When you use CocoaPods for both Spreedly and Stripe, the app can crash with something like “unable to find bundle named Stripe_StripePaymentSheet” unless we add a small fix. That happens because:

- Our Stripe APM binary is built against Stripe via **Swift Package Manager (SPM)**. In that world, resource bundles get names like `Stripe_StripePaymentSheet`.
- When you install Stripe via **CocoaPods**, Stripe’s own podspecs use different names, like `StripePaymentSheetBundle`.
- Same Stripe SDK, same features—just different names depending on whether you use SPM or CocoaPods. We don’t control either naming scheme; we just need to bridge them when you’re on CocoaPods.

We ship a small script that runs after `pod install` and copies/renames those bundles so the names line up. It’s a standard, low-risk approach and is used in production. If you use **SPM** for both Spreedly and Stripe, you don’t need this step at all—the names already match.

---

## What you see when the fix is missing

If you integrate SpreedlyStripeAPM with CocoaPods and add Stripe via CocoaPods (e.g. `pod 'StripePaymentSheet', '~> 25.0'`), the app can build fine but **crash at runtime** when you open the Stripe Payment Sheet or when Stripe tries to load images or other resources.

You’ll typically see something like:

```text
StripePaymentSheet/resource_bundle_accessor.swift:44: Fatal error: unable to find bundle named Stripe_StripePaymentSheet
```

You might get similar errors for other modules (e.g. `Stripe_StripeCore`, `Stripe_StripeUICore`). In every case, the code is looking for a bundle with an SPM-style name, but CocoaPods has only created bundles with different names.

**Who runs into this:** Anyone using SpreedlyStripeAPM and Stripe via **CocoaPods** (native iOS apps or React Native with CocoaPods for native deps). If you use **Swift Package Manager** for both, the bundle names already match and you won’t see this.

---

## Why there are two different names for the same thing

Stripe ships one iOS SDK but supports two ways to install it: **Swift Package Manager** and **CocoaPods**. Depending on which one you use, the **resource bundles** (images, localizations, etc.) get different names:

| How you install Stripe | What the bundles are called |
|------------------------|-----------------------------|
| **Swift Package Manager** | `Stripe_StripePaymentSheet`, `Stripe_StripeCore`, and similar (SPM’s `PackageName_TargetName` style) |
| **CocoaPods** | `StripePaymentSheetBundle`, `StripeCoreBundle`, and similar (from Stripe’s podspecs) |

So it’s the same Stripe codebase—just different naming depending on the install path. Neither naming is “wrong”; they’re just different.

Our **SpreedlyStripeAPM** binary is built in a project that uses Stripe via **SPM**. So the code inside that binary was compiled against SPM’s Stripe and expects SPM-style bundle names at runtime. When your app uses **CocoaPods** to pull in Stripe, CocoaPods creates bundles with the podspec names. The names don’t match, the lookup fails, and you get the crash. So we build with SPM (standard for Apple’s tooling), and when someone uses CocoaPods we add a small step to make the CocoaPods bundles visible under the names our binary expects.

---

## Where this is visible in Stripe’s own repos

You can confirm the naming split directly in Stripe’s GitHub repos.

### CocoaPods: names come from Stripe’s podspecs

In the **stripe-ios** repo, the podspecs define the bundle names CocoaPods uses:

**StripePaymentSheet.podspec**  
<https://github.com/stripe/stripe-ios/blob/master/StripePaymentSheet.podspec>

```ruby
s.ios.resource_bundle = {
  'StripePaymentSheetBundle' => ['StripePaymentSheet/StripePaymentSheet/Resources/**/*.{lproj,png,xcassets,json}', ...]
}
```

**StripeCore.podspec**  
<https://github.com/stripe/stripe-ios/blob/master/StripeCore.podspec>

```ruby
s.ios.resource_bundle = {
  'StripeCoreBundle' => ['StripeCore/StripeCore/Resources/**/*.lproj', ...]
}
```

So with CocoaPods, Stripe’s own specs say the bundles are named **StripePaymentSheetBundle**, **StripeCoreBundle**, etc.—no `Stripe_` prefix.

### Same Stripe code, two code paths

In Stripe’s source (e.g. their bundle locator files), you’ll see something like:

```swift
public static let bundleName = "StripePaymentSheetBundle"   // used when built with CocoaPods
#if SWIFT_PACKAGE
public static let spmResourcesBundle = Bundle.module       // used when built as a Swift package
#endif
```

When they’re built as a Swift package, the code uses `Bundle.module`. The **name** of that bundle isn’t set by Stripe—Swift Package Manager assigns it using its own rule: **PackageName_TargetName**. So you get names like **Stripe_StripePaymentSheet**, **Stripe_StripeCore**. When they’re built with CocoaPods, the code uses `bundleName`, which matches the podspec. Same repo, two naming schemes depending on how it’s built.

### Quick reference

| Source | CocoaPods bundle name | SPM bundle name |
|--------|------------------------|-----------------|
| Stripe’s StripePaymentSheet.podspec | `StripePaymentSheetBundle` | — |
| Stripe’s StripeCore.podspec | `StripeCoreBundle` | — |
| SPM (Bundle.module) | — | `Stripe_StripePaymentSheet`, `Stripe_StripeCore`, etc. |

So the mismatch is right there in Stripe’s distribution: one codebase, two naming conventions. We don’t control either one; we just need to account for both when you’re on CocoaPods.

---

## Why this isn’t a bug in our SDK (or in Stripe’s)

Our binary is built against Stripe via SPM, which is a normal and supported way to use Stripe. At runtime it looks for the bundle names that SPM uses—that’s consistent with how it was built.

The “problem” is only that Stripe’s **CocoaPods** distribution uses different names (by design, in their podspecs), and **SPM** uses its own convention. We can’t change Stripe’s podspecs or SPM’s behavior. The practical approach is to adapt on the app side: when you use CocoaPods, we provide a script that copies the CocoaPods bundles under the SPM-style names so our binary can find them.

So: not a bug in SpreedlyStripeAPM (we build correctly with SPM), and not a bug in Stripe (they support both SPM and CocoaPods with different names). It’s just how the ecosystem works—two install paths, two naming schemes. Our fix bridges that for CocoaPods users.

---

## What we provide: the CocoaPods bundle fix

We ship a **post_install** script that:

1. Runs after `pod install` (you add a few lines to your Podfile).
2. Makes sure the Stripe resource bundles that CocoaPods produces are also available under the SPM-style names (e.g. it copies `StripePaymentSheetBundle.bundle` so it’s also findable as `Stripe_StripePaymentSheet.bundle`).
3. Doesn’t change Stripe’s source or our XCFramework—it only adds or renames bundle copies in your app target.

**Where the script lives:**  
`checkout-ios-package/scripts/cocoapods_stripe_bundle_patcher.rb` (shipped inside the `SpreedlyStripeAPM` pod via `s.preserve_paths`)

**What to add to your Podfile:**

```ruby
post_install do |installer|
  stripe_apm_pod = installer.sandbox.pod_dir('SpreedlyStripeAPM')
  require File.join(stripe_apm_pod, 'scripts', 'cocoapods_stripe_bundle_patcher')
  SpreedlyStripeAPM::CocoaPods.apply_stripe_bundle_patch(installer)
end
```

The script is shipped inside the pod, so no manual file copy or path configuration is needed. The same `post_install` block works for both remote and local (`:path =>`) installs. Full details and troubleshooting are in the [Stripe APM guide](guides/stripe-apm.md#cocoapods-stripe-bundle-patcher).

**When you need it:**  
Only when you’re using **SpreedlyStripeAPM** and **Stripe** via **CocoaPods** (including React Native with CocoaPods for native deps). If you use **SPM** for both, the bundle names already match and you can skip this.

---

## References

| What | Where |
|------|--------|
| Stripe iOS (CocoaPods) | <https://github.com/stripe/stripe-ios> |
| Stripe iOS SPM | <https://github.com/stripe/stripe-ios-spm> |
| StripePaymentSheet.podspec | <https://github.com/stripe/stripe-ios/blob/master/StripePaymentSheet.podspec> |
| StripeCore.podspec | <https://github.com/stripe/stripe-ios/blob/master/StripeCore.podspec> |
| Spreedly Stripe APM guide (CocoaPods fix) | [guides/stripe-apm.md](guides/stripe-apm.md#cocoapods-stripe-spm-bundle-fix) |
| Spreedly troubleshooting | [guides/troubleshooting.md](guides/troubleshooting.md) |

---

## Short summary

- **What:** One extra step in the Podfile (a few lines) when using Spreedly Stripe APM with CocoaPods.
- **Why:** Stripe uses different resource bundle names when installed via SPM vs CocoaPods. Our SDK is built with SPM and expects SPM-style names; CocoaPods gives the other set of names. Same Stripe, different names by install method—you can see it in Stripe’s own podspecs and code.
- **Who needs it:** Only CocoaPods. SPM users don’t need any extra step.
- **Risk:** Low—the script only copies/renames bundles and is in use in production and in our React Native integration.
- **Evidence:** Stripe’s GitHub podspecs show the CocoaPods names (e.g. `StripePaymentSheetBundle`); SPM uses names like `Stripe_StripePaymentSheet`. We don’t control either; we just align CocoaPods output with what our binary expects.

---

For step-by-step integration and troubleshooting, see [guides/stripe-apm.md](guides/stripe-apm.md) and [guides/troubleshooting.md](guides/troubleshooting.md).
