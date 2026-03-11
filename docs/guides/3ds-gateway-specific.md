# Gateway-Specific 3DS - Spreedly iOS SDK

Integrate gateway-driven 3DS authentication for gateways like Worldpay.

**Estimated time:** ~15 minutes

## Table of Contents

1. [Introduction](#introduction)
2. [How the Challenge Works](#how-the-challenge-works)
3. [Prerequisites](#prerequisites)
4. [Flow](#flow)
5. [Purchase Response Checks](#purchase-response-checks)
6. [Events](#events)
7. [SwiftUI Integration](#swiftui-integration)
8. [UIKit Integration (Swift + Combine)](#uikit-integration-swift--combine)
9. [UIKit (Notification + Delegate)](#uikit-notification--delegate)
10. [Objective-C Integration](#objective-c-integration)
11. [Device Fingerprint Polling](#device-fingerprint-polling)
12. [Result Handling](#result-handling)
13. [Deprecated APIs](#deprecated-apis)
14. [Troubleshooting](#troubleshooting)
15. [Related Documentation](#related-documentation)

---

## Introduction

### When to Use

Use gateway-specific 3DS when your payment gateway explicitly requires its own 3DS implementation. Examples include Worldpay and other gateways that handle 3DS authentication through their own flow rather than the global Forter-based flow.

### Global vs Gateway-Specific Comparison

| Flow | Backend responsibility | App responsibility |
|------|------------------------|---------------------|
| **3DS Global (Forter)** | Purchase/authorize; return `transaction_token` when 3DS required | Present challenge UI; SDK calls complete/status; handle result |
| **3DS Gateway-Specific** | Purchase; when SDK signals, call `/complete.json` | Present challenge UI; on trigger, call backend; finalize with response; handle result |

For a full comparison table and detailed flow diagrams, see [3ds-global.md](3ds-global.md).

---

## How the Challenge Works

When you present `DoChallengeIfNeeded`, the SDK manages two internal phases automatically:

| Phase | Mechanism | User-visible? |
|-------|-----------|---------------|
| **Device fingerprint** | Hidden WKWebView (background, non-interactive) | No — runs silently |
| **Challenge** | `ASWebAuthenticationSession` | Yes — system-managed secure browser with visible URL bar |

**Device fingerprint:** The SDK injects a hidden 1×1 WKWebView to collect device fingerprint data. This is non-interactive and follows industry standard practice for 3DS device data collection.

**Challenge (`ASWebAuthenticationSession`):** When the gateway requires user interaction (e.g. OTP entry or biometric verification), the SDK presents `ASWebAuthenticationSession` — Apple's endorsed API for web-based authentication. The browser shows the bank's domain (anti-phishing) and intercepts the callback URL scheme automatically, so **no `Info.plist` registration or `onOpenURL` handler is needed** for the default flow. Challenge completion is detected by status polling (every 2 seconds). The `redirect_url` triggers the auth session callback, providing immediate dismissal.

**User cancellation:** If the user taps **"Cancel"** in the authentication session during the challenge, the SDK treats it as a failure and emits `ThreeDSChallengeResult` with `isFailure == true`. The error message will contain `"3DS challenge canceled by user"`. Handle this in your `isFailure` branch.

> **Note:** You do not need to manage the auth session presentation or dismissal. The SDK handles this automatically. Your `DoChallengeIfNeeded` view displays a loading spinner while both phases run; the auth session is presented on top when the challenge phase begins. No `Info.plist` URL scheme or `onOpenURL` handler is required for the default flow.

---

## Prerequisites

Same as global 3DS, plus:

1. Complete [getting-started.md](getting-started.md) (installation, basic setup).
2. Ensure `Spreedly.initializeSDK()` is called at app launch (e.g., in your `App.init()` or `AppDelegate`).
3. Call `Spreedly.setup(config:)` with environment key and signature parameters before any 3DS calls.
4. A gateway that requires gateway-specific 3DS (e.g. Worldpay).
5. **No `Info.plist` URL scheme needed for 3DS.** The SDK uses `ASWebAuthenticationSession`, which intercepts the callback internally. Only register `$(PRODUCT_BUNDLE_IDENTIFIER).spreedly3ds` in `Info.plist` if you use the external Safari escape hatch.
6. When creating the purchase/authorize on your backend, include these parameters:

| Parameter | Value | Purpose |
|-----------|-------|---------|
| `attempt_3dsecure` | `true` | Tells Spreedly to attempt 3DS authentication |
| `redirect_url` | *(Recommended)* Use `GatewaySpecific3DSIntegration.redirectUrl()` | Triggers the auth session callback for immediate dismissal. The SDK also detects completion via polling as a fallback. |
| `callback_url` | Your backend URL | For server-to-server notifications |
| `channel` | `"app"` | Identifies this as a mobile transaction |

The SDK detects that gateway-specific 3DS is needed from the transaction response.

**Example backend purchase call:**

```json
{
  "transaction": {
    "payment_method_token": "...",
    "amount": 1999,
    "currency_code": "USD",
    "attempt_3dsecure": true,
    "redirect_url": "yourapp.spreedly3ds://3ds/redirect",
    "callback_url": "https://yourbackend.com/callback",
    "channel": "app"
  }
}
```

> **Note:** `redirect_url` is recommended. Including it triggers the `ASWebAuthenticationSession` callback for immediate dismissal. The SDK also detects challenge completion via polling as a fallback.

**Example SDK purchase call (Swift):**

```swift
let response = try await client.purchase(
    paymentMethodToken: card.paymentMethodToken,
    amount: amountInCents,
    currencyCode: "USD",
    useGatewaySpecific3DS: true,
    redirectUrl: GatewaySpecific3DSIntegration.redirectUrl()
)
```

**Example SDK purchase call (Objective-C):**

```objc
NSString *redirectUrl = [GatewaySpecific3DSObjCBridge redirectUrl];

[client purchaseWithPaymentMethodToken:card.paymentMethodToken
                                amount:amountInCents
                          currencyCode:@"USD"
                  useGatewaySpecific3DS:YES
                           redirectUrl:redirectUrl
                            completion:^(PurchaseResponse *response, NSError *error) {
    // Handle response
}];
```

### Redirect URL Helpers

The SDK provides helpers to generate a standardized redirect URL based on your app's bundle identifier. This follows the same convention as the Android SDK.

| Method | Returns |
|--------|---------|
| `GatewaySpecific3DSIntegration.deepLinkScheme` | `{bundleId}.spreedly3ds` |
| `GatewaySpecific3DSIntegration.redirectUrl()` | `{bundleId}.spreedly3ds://3ds/redirect` |
| `GatewaySpecific3DSIntegration.redirectUrl(path: "custom")` | `{bundleId}.spreedly3ds://custom` |

**Objective-C equivalents:**

| Method | Returns |
|--------|---------|
| `GatewaySpecific3DSObjCBridge.deepLinkScheme` | `{bundleId}.spreedly3ds` |
| `[GatewaySpecific3DSObjCBridge redirectUrl]` | `{bundleId}.spreedly3ds://3ds/redirect` |
| `[GatewaySpecific3DSObjCBridge redirectUrlWithPath:@"custom"]` | `{bundleId}.spreedly3ds://custom` |

In the **default flow** (`ASWebAuthenticationSession`), the SDK intercepts this redirect automatically — **no `Info.plist` registration or `onOpenURL` handler is needed**.

If you use the **external Safari escape hatch** (opening the challenge in Safari.app), you must also register the scheme in `Info.plist` and handle the URL in `onOpenURL`.

---

## Flow

1. **Backend purchase/authorize** returns `transaction.token`.
2. **App presents** `DoChallengeIfNeeded` with the transaction token. The SDK shows a loading spinner, runs device fingerprint in a hidden WKWebView, and auto-presents `ASWebAuthenticationSession` if a challenge is required (see [How the Challenge Works](#how-the-challenge-works)).
3. **SDK emits** `GatewaySpecific3DSTriggerCompletion` when your backend must call `/complete.json`.
4. **App calls** `GatewaySpecific3DSIntegration.finalizeTransaction(for:transaction:)` with the `/complete.json` response.
5. **SDK emits** `ThreeDSChallengeResult` with the final outcome.

**Note:** The `/complete.json` call must be made by your backend. The app should call your backend endpoint, which in turn calls Spreedly. The exact Spreedly endpoint is:

- **Method:** `POST`
- **Path:** `https://core.spreedly.com/v1/transactions/{token}/complete.json`

Replace `{token}` with the transaction token from the `GatewaySpecific3DSTriggerCompletion` event.

**Important:** If you present `DoChallengeIfNeeded`, the SDK handles the 3DS lifecycle internally. Follow only the steps in this guide.

---

## Purchase Response Checks

After your backend returns a purchase/authorize response:

- If `response.errors` is non-empty: surface the error and stop the flow.
- If `transaction` is missing: treat it as an error and stop the flow.
- If `transaction.state == "pending"` or `transaction.scaAuthentication?.requiredAction == "device_fingerprint"`: present the challenge UI.
- If `transaction.state == "succeeded"`: show success immediately and skip the challenge UI.

When showing error messages during gateway-specific flows, use your normal error handling to decide what to display to the user.

---

## Events

| Event | Meaning |
|-------|---------|
| `GatewaySpecific3DSTriggerCompletion` | The SDK needs your backend to call `/complete.json`. The event provides the transaction token. |
| `ThreeDSChallengeResult` | Final 3DS outcome (success, failure, or canceled). Handle all three cases in your subscriber. |
| `gatewaySpecific3DSChallengeReadyPublisher` / `subscribeToGatewaySpecific3DSChallengeReady(_:)` | Notifies when the challenge UI is ready to be displayed. Subscribe before starting the flow to receive the event when the challenge view can be presented. |

---

## GatewaySpecific3DSIntegration

The main integration point for gateway-specific 3DS flows.

### Starting a Flow

- **`startFlow(transactionToken:statusResponse:presentingViewController:)`** — Starts the gateway-specific 3DS flow. Call this instead of presenting `DoChallengeIfNeeded` when you want programmatic control. Pass the transaction token, the status response from your backend, and the view controller that will present the challenge UI.

### Managing Flows

- **`cancelFlow(for:)`** — Cancels an active flow for a given transaction token. Call this to programmatically abort a 3DS flow. The SDK will emit `ThreeDSChallengeResult` with `isCanceled == true`.

- **`getLifecycle(for:)`** → `GatewaySpecific3DSLifecycle?` — Retrieves the lifecycle object for a transaction. Returns `nil` if no active flow exists for the given token.

### Finalizing

- **`finalizeTransaction(for:transaction:)`** — Pass the `/complete.json` response to the SDK so it can emit `ThreeDSChallengeResult`. Call this when `GatewaySpecific3DSTriggerCompletion` fires and your backend has returned a non-succeeded transaction.

---

## GatewaySpecific3DSLifecycle

The lifecycle manager for gateway-specific 3DS flows. Obtain an instance via `GatewaySpecific3DSIntegration.getLifecycle(for:)`.

### Public Methods

- **`start()`** — Starts the lifecycle (device fingerprint, polling, etc.).
- **`finalize(transaction:)`** — Finalizes the flow with the transaction from `/complete.json`. Use when your backend has returned the complete response.
- **`stop()`** — Stops the lifecycle and cleans up resources.

### Public Property

- **`state`** (read-only) — The current state of the lifecycle. Use this to query progress or determine if the flow is still active.

---

## SwiftUI Integration

Subscribe to both `subscribeToThreeDSChallengeResults` and `subscribeToGatewaySpecific3DSTriggerCompletion` before presenting the challenge. On trigger, call your backend to invoke `/complete.json`. If the response state is `succeeded`, show success immediately; otherwise call `finalizeTransaction`.

**Note:** Store subscription cancellables and cancel them in `onDisappear` (SwiftUI) or `dealloc` (UIKit/Obj-C) to prevent memory leaks.

```swift
@State private var show3DSChallenge = false
@State private var transactionToken: String?
@State private var challengeCancellable: AnyCancellable?
@State private var triggerCancellable: AnyCancellable?
@State private var errorMessage: String?
@State private var successMessage: String?

var body: some View {
    // Your payment UI
    .sheet(isPresented: $show3DSChallenge) {
        if let token = transactionToken {
            DoChallengeIfNeeded(transactionToken: token) {
                show3DSChallenge = false
            }
        }
    }
    .onAppear {
        // Final 3DS outcome.
        challengeCancellable = Spreedly.shared().subscribeToThreeDSChallengeResults { result in
            if result.isSuccess {
                successMessage = "Payment successful"
                show3DSChallenge = false
            } else if result.isFailure {
                errorMessage = result.error?.localizedDescription ?? "Payment failed"
                show3DSChallenge = false
            } else if result.isCanceled {
                errorMessage = "Payment canceled"
                show3DSChallenge = false
            }
        }

        // Trigger to call /complete.json on your backend.
        triggerCancellable = Spreedly.shared().subscribeToGatewaySpecific3DSTriggerCompletion { event in
            Task {
                // Your backend should call /complete.json and return the transaction.
                let transaction = try await backend.complete(transactionToken: event.token)
                if transaction.state?.lowercased() == "succeeded" {
                    await MainActor.run {
                        successMessage = "Payment successful"
                        show3DSChallenge = false
                    }
                    return
                }
                await MainActor.run {
                    GatewaySpecific3DSIntegration.finalizeTransaction(
                        for: event.token,
                        transaction: transaction
                    )
                }
            }
        }
    }
    .onDisappear {
        challengeCancellable?.cancel()
        triggerCancellable?.cancel()
    }
}

// Call this after your purchase/authorize response.
func handlePurchaseResponse(_ response: PurchaseResponse) {
    guard response.errors?.isEmpty ?? true else {
        errorMessage = "Purchase failed"
        return
    }
    guard let transaction = response.transaction else {
        errorMessage = "Missing transaction"
        return
    }
    transactionToken = transaction.token

    let state = transaction.state?.lowercased() ?? ""
    let requiredAction = transaction.scaAuthentication?.requiredAction?.lowercased() ?? ""
    if state == "succeeded" {
        successMessage = "Payment successful"
    } else if state == "pending" || requiredAction == "device_fingerprint" {
        show3DSChallenge = true
    }
}
```

---

## UIKit Integration (Swift + Combine)

Same pattern as SwiftUI: subscribe to both events in `viewDidLoad`, present the challenge when needed, and handle the trigger by calling your backend and then `finalizeTransaction`.

```swift
final class GatewaySpecific3DSViewController: UIViewController {
    private var challengeCancellable: AnyCancellable?
    private var triggerCancellable: AnyCancellable?
    private var transactionToken: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Final 3DS outcome.
        challengeCancellable = Spreedly.shared().subscribeToThreeDSChallengeResults { [weak self] result in
            if result.isSuccess {
                // show success
                self?.dismiss(animated: true)
            } else if result.isFailure {
                // show error
                self?.dismiss(animated: true)
            } else if result.isCanceled {
                // show cancel
                self?.dismiss(animated: true)
            }
        }

        // Trigger to call /complete.json on your backend.
        triggerCancellable = Spreedly.shared().subscribeToGatewaySpecific3DSTriggerCompletion { [weak self] event in
            Task {
                // Your backend should call /complete.json and return the transaction.
                let transaction = try await backend.complete(transactionToken: event.token)
                if transaction.state?.lowercased() == "succeeded" {
                    await MainActor.run { self?.dismiss(animated: true) }
                    return
                }
                await MainActor.run {
                    GatewaySpecific3DSIntegration.finalizeTransaction(
                        for: event.token,
                        transaction: transaction
                    )
                }
            }
        }
    }

    func handlePurchaseResponse(_ response: PurchaseResponse) {
        guard response.errors?.isEmpty ?? true,
              let transaction = response.transaction else { return }
        transactionToken = transaction.token

        let state = transaction.state?.lowercased() ?? ""
        let requiredAction = transaction.scaAuthentication?.requiredAction?.lowercased() ?? ""
        if state == "succeeded" { return }
        if state == "pending" || requiredAction == "device_fingerprint" {
            presentChallenge()
        }
    }

    private func presentChallenge() {
        guard let token = transactionToken else { return }
        let vc = DoChallengeIfNeededViewController(
            transactionToken: token,
            onDismiss: { [weak self] in self?.dismiss(animated: true) }
        )
        present(vc, animated: true)
    }
}
```

---

## UIKit (Notification + Delegate)

Use `NotificationCenter` to observe `GatewaySpecific3DSTriggerCompletion` and implement `SpreedlyThreeDSChallengeDelegate` for the final outcome.

```swift
final class GatewaySpecific3DSViewController: UIViewController, SpreedlyThreeDSChallengeDelegate {
    private var transactionToken: String?
    private var triggerObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        Spreedly.shared().threeDSChallengeDelegate = self

        // Notification posted when the SDK needs your backend to call /complete.json.
        triggerObserver = NotificationCenter.default.addObserver(
            forName: .gatewaySpecific3DSTriggerCompletion,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let token = note.userInfo?["transactionToken"] as? String else { return }
            Task {
                // Your backend should call /complete.json and return the transaction.
                let transaction = try await backend.complete(transactionToken: token)
                if transaction.state?.lowercased() == "succeeded" {
                    await MainActor.run { /* Show success, dismiss challenge */ }
                    return
                }
                await MainActor.run {
                    GatewaySpecific3DSIntegration.finalizeTransaction(
                        for: token,
                        transaction: transaction
                    )
                }
            }
        }
    }

    deinit {
        if let observer = triggerObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // Final 3DS outcome.
    func threeDSChallengeDidComplete(_ result: ThreeDSChallengeResult) {
        if result.isSuccess {
            // show success
        } else if result.isFailure {
            // show error
        } else if result.isCanceled {
            // show cancel
        }
    }
}
```

---

## Objective-C Integration

Set the delegate before presenting. Use `NSNotificationCenter` to observe `GatewaySpecific3DSTriggerCompletion`. When the trigger fires, call your backend to invoke `/complete.json` (your backend calls `POST https://core.spreedly.com/v1/transactions/{token}/complete.json`), then pass the raw response data to `GatewaySpecific3DSObjCBridge.finalizeTransactionForTransactionToken:completeResponseData:error:`.

### Objective-C API Reference

- **`GatewaySpecific3DSObjCBridge.finalizeTransactionForTransactionToken:completeResponseData:error:`** — Finalizes the transaction with raw response data from `/complete.json`. Pass the transaction token and the `NSData` from your backend's complete response. On success, the error pointer is set to `nil`; on failure, it is populated. The final result is delivered via `SpreedlyThreeDSChallengeDelegate` (`threeDSChallengeDidComplete:`).

- **`GatewaySpecific3DSTriggerNotification`** — The notification name used to observe when the SDK needs your backend to call `/complete.json`. The `userInfo` dictionary contains `transactionToken` (the transaction token). In Swift, use `Notification.Name.gatewaySpecific3DSTriggerCompletion`; in Objective-C, use the string constant `@"GatewaySpecific3DSTriggerCompletion"`.

```objc
@interface GatewaySpecific3DSViewController () <SpreedlyThreeDSChallengeDelegate>
@property (nonatomic, strong) NSString *transactionToken;
@property (nonatomic, strong) id gatewaySpecificTriggerObserver;
@end

@implementation GatewaySpecific3DSViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set delegate before presenting. Delegate receives final 3DS outcome.
    [Spreedly shared].threeDSChallengeDelegate = self;

    // Notification posted when the SDK needs your backend to call /complete.json.
    __weak typeof(self) weakSelf = self;
    self.gatewaySpecificTriggerObserver = [[NSNotificationCenter defaultCenter]
        addObserverForName:@"GatewaySpecific3DSTriggerCompletion"
                    object:nil
                     queue:[NSOperationQueue mainQueue]
                usingBlock:^(NSNotification *note) {
                    NSString *transactionToken = note.userInfo[@"transactionToken"];
                    if (!transactionToken.length) return;
                    [weakSelf handleGatewaySpecificTriggerWithToken:transactionToken];
                }];
}

- (void)presentChallenge {
    if (!self.transactionToken) return;
    DoChallengeIfNeededViewController *challengeVC = [[DoChallengeIfNeededViewController alloc]
        initWithTransactionToken:self.transactionToken
        onDismiss:^{
            // Challenge dismissed
        }];
    [self presentViewController:challengeVC animated:YES completion:nil];
}

- (void)handleGatewaySpecificTriggerWithToken:(NSString *)transactionToken {
    // Call your backend to invoke POST https://core.spreedly.com/v1/transactions/{token}/complete.json
    [yourBackend completeTransactionWithToken:transactionToken
                                 completion:^(NSData *responseData, NSError *error) {
        if (error) {
            // Handle error, dismiss challenge
            return;
        }
        if (!responseData) {
            // Handle empty response
            return;
        }

        // Parse the /complete.json response using PurchaseResponse.fromJSONData:error:
        NSError *parseErr = nil;
        PurchaseResponse *completeResponse = [PurchaseResponse fromJSONData:responseData error:&parseErr];
        if (completeResponse.transaction &&
            [[completeResponse.transaction.state lowercaseString] isEqualToString:@"succeeded"]) {
            // Show success, dismiss challenge
            return;
        }

        // Otherwise finalize with the raw response data.
        NSError *finalizeError = nil;
        [GatewaySpecific3DSObjCBridge finalizeTransactionForTransactionToken:transactionToken
                                                          completeResponseData:responseData
                                                                         error:&finalizeError];
        if (finalizeError) {
            // Handle finalize error
        }
        // Final result delivered via delegate
    }];
}

- (void)dealloc {
    if (self.gatewaySpecificTriggerObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.gatewaySpecificTriggerObserver];
        self.gatewaySpecificTriggerObserver = nil;
    }
}

// Implement delegate (final 3DS outcome)
- (void)threeDSChallengeDidComplete:(ThreeDSChallengeResult *)result {
    if (result.isSuccess) {
        // show success
    } else if (result.isFailure) {
        // show error
    } else if (result.isCanceled) {
        // show cancel
    }
}

@end
```

---

## Device Fingerprint Polling

The SDK polls `status.json` every 2 seconds for up to approximately 20 seconds (10 attempts). If it times out or receives a Worldpay postMessage, it emits `GatewaySpecific3DSTriggerCompletion` so you can call `/complete.json` on your backend.

---

## Result Handling

- `/complete.json` returns a `transaction.state`. If it is `succeeded`, you can show success immediately and exit the flow.
- For any other state (`pending`, `failed`, etc.), call `GatewaySpecific3DSIntegration.finalizeTransaction(for:transaction:)` so the SDK can emit `ThreeDSChallengeResult`.
- Always handle all `ThreeDSChallengeResult` outcomes in your subscriber: `isSuccess`, `isFailure`, `isCanceled`.
- In `subscribeToThreeDSChallengeResults`, explicitly branch on `isSuccess`/`isFailure`/`isCanceled` so you know where to show success, show errors, or treat user cancel.
- **Auth session cancellation:** If the user taps "Cancel" in the authentication session during the challenge, the SDK emits `isFailure` (not `isCanceled`) with an error message containing `"3DS challenge canceled by user"`. Check for this string in your `isFailure` handler if you want to distinguish user cancellation from other failures.
- `isCanceled` is emitted only when `GatewaySpecific3DSIntegration.cancelFlow(for:)` is called programmatically.
- If the error message contains `"Forced Failure"` (case-insensitive), use your normal error handling to decide what to display to the user.

---

## Deprecated APIs

### `getChallengeContainerView(for:)` — DEPRECATED

> **Deprecated:** This method always returns `nil` and should not be used.

`GatewaySpecific3DSIntegration.getChallengeContainerView(for:)` previously returned the `WKWebView` used for the challenge. Since the challenge is now presented via `ASWebAuthenticationSession`, this method **always returns `nil`**.

If your code calls `getChallengeContainerView`, you can safely remove those calls. No replacement is needed — the SDK manages the auth session presentation and dismissal automatically.

---

## Troubleshooting

**Trigger never fires**

- Ensure you subscribed to `subscribeToGatewaySpecific3DSTriggerCompletion` (or the notification) before presenting `DoChallengeIfNeeded`.
- Verify your gateway is configured for gateway-specific 3DS (e.g. Worldpay).
- Check that the device fingerprint step completes; the trigger fires after polling timeout or when the gateway posts completion.

**Final result not received**

- Ensure `SpreedlyThreeDSChallengeDelegate` is set (Objective-C) or you are subscribed to `subscribeToThreeDSChallengeResults` (Swift) before presenting the challenge.
- Do not cancel the subscription in `onDisappear` while the challenge is still active. `ASWebAuthenticationSession` is presented on top of your `DoChallengeIfNeeded` view, which can trigger `onDisappear` events on the underlying view. Canceling the subscription at that point will prevent you from receiving the final result.

**User taps "Cancel" in the auth session**

- This is treated as a failure. The SDK emits `ThreeDSChallengeResult` with `isFailure == true` and an error containing `"3DS challenge canceled by user"`.
- Ensure your `isFailure` handler accounts for this scenario (e.g. showing "Payment canceled" instead of a generic error).

**Backend /complete.json errors**

- Verify your backend calls the correct Spreedly `/complete.json` endpoint with the transaction token.
- Ensure the backend returns the full response; `finalizeTransaction` (or `GatewaySpecific3DSObjCBridge`) needs the raw response data.

**Multiple subscriptions**

- Only one active subscription per event type should exist. Cancel previous subscriptions when navigating away or when the flow completes.

**Multi-flow token filtering**

- In apps that may have multiple concurrent 3DS flows, filter `GatewaySpecific3DSTriggerCompletion` notifications by `transactionToken` to avoid handling triggers from unrelated flows. Compare `event.token` (Combine) or `note.userInfo[@"transactionToken"]` (NotificationCenter) against the token you are currently tracking.

---

## Related Documentation

- [3ds-global.md](3ds-global.md) - Global 3DS (Forter) flow and full comparison table
- [error-handling.md](error-handling.md) - Error types and handling patterns
- [3DS_GATEWAY_SPECIFIC_FLOW.md](../development/3DS_GATEWAY_SPECIFIC_FLOW.md) – Detailed flow diagrams for gateway-specific 3DS including device fingerprint, trigger/finalize, challenge lifecycle, and decision flows
