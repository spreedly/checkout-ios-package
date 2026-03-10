# CVV Recaching - Spreedly iOS SDK

Update the CVV for saved payment methods without re-entering full card details.

**Estimated integration time:** ~15 minutes

## Table of Contents

1. [Why Use Recaching?](#why-use-recaching)
2. [Prerequisites](#prerequisites)
3. [Quick Start](#quick-start)
4. [API Reference](#api-reference)
5. [Step-by-Step Integration](#step-by-step-integration)
6. [Presentation Modes](#presentation-modes)
7. [Theme Customization](#theme-customization)
8. [Error Handling](#error-handling)
9. [Security](#security)
10. [Troubleshooting](#troubleshooting)
11. [Related Documentation](#related-documentation)

---

## Why Use Recaching?

**Problem:** CVV values cannot be stored long-term due to PCI compliance requirements, but many payment processors require a fresh CVV for repeat transactions.

**Solution:** The SDK provides `SpreedlyCVVRecachingView` for secure CVV re-entry. Customers can update the CVV for saved cards without re-entering full card details.

### When to Use

- Returning customer making a purchase with a saved card
- Card is already tokenized and retained in Spreedly
- Payment processor requires CVV for repeat transactions
- You want SDK-managed secure CVV input

### Benefits

CVV never passes through your application code. The SDK handles all sensitive data collection and transmission. Customers re-enter only CVV, not full card details. Theming supports brand customization.

---

## Prerequisites

Before integrating CVV recaching:

- Complete the setup steps in [getting-started.md](getting-started.md)
- Ensure `Spreedly.initializeSDK()` is called at app launch (e.g., in your `App.init()` or `AppDelegate`)
- Call `Spreedly.setup(config:)` with `environmentKey`, `forterSiteId`, and signature parameters before presenting the recaching UI
- Fetch signature parameters from your backend before each payment session

---

## Quick Start

Minimal SwiftUI example:

```swift
import SwiftUI
import SpreedlyUI
import SpreedlyCore
import Combine

struct CheckoutView: View {
    @State private var showCVVRecaching = false
    @State private var cancellable: AnyCancellable?

    var body: some View {
        Button("Pay with Saved Card") {
            Task {
                let result = await SpreedlyConfigManager.shared.generateSignature()
                switch result {
                case .success:
                    showCVVRecaching = true
                case .failure(let error):
                    // Handle error
                }
            }
        }
        .sheet(isPresented: $showCVVRecaching) {
            SpreedlyCVVRecachingView(
                config: RecacheConfig(
                    cardInfo: SavedCardInfo(lastFourDigits: "4242", cardType: "Visa"),
                    presentationMode: .bottomSheet
                ),
                paymentMethodToken: "saved_token_here",
                onProcessingResult: { result in
                    if result.isProcessing { /* Show loading */ }
                    else if result.isValidationFailed { /* Handle validation */ }
                },
                onDismiss: { showCVVRecaching = false }
            )
            .screenPrevention()
        }
        .onAppear {
            cancellable = Spreedly.shared().subscribeToPaymentResults { result in
                if result.isSuccess {
                    showCVVRecaching = false
                    // Use result.token for payment processing
                } else if result.isFailure {
                    showCVVRecaching = false
                    // Handle failure
                }
            }
        }
        .onDisappear {
            cancellable?.cancel()
            cancellable = nil
            ValidationParamReset.reset()
        }
    }
}
```

---

## API Reference

### RecacheConfig

Configuration for the CVV input UI.

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `cardInfo` | `SavedCardInfo` | - | **Required.** Saved card information to display |
| `presentationMode` (init) / `recachePresentationMode` (property) | `ScreenPresentationMode` | `.bottomSheet` | Display mode (bottom sheet or dialog) |
| `labelText` | `String` | `"CVV"` | Label for CVV input field (localizable) |
| `placeholderText` | `String` | `"123"` | Placeholder text (localizable) |
| `buttonText` | `String` | `"Confirm"` | Submit button text (localizable) |
| `cancelButtonText` | `String` | `"Cancel"` | Cancel button text (localizable) |

> **Localization:** Default values for `labelText`, `placeholderText`, `buttonText`, and `cancelButtonText` are resolved through the SDK's `LocalizationHelper`. To provide translations, add entries for the corresponding localization keys in your app's `.strings` files. If no translation is found, the defaults shown above are used.

### SpreedlyCVVRecachingView

SwiftUI view for CVV recaching. Init parameters:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `config` | `RecacheConfig` | - | **Required.** Configuration for the recaching UI |
| `paymentMethodToken` | `String` | - | **Required.** Payment method token to recache |
| `theme` | `SpreedlyTheme?` | `nil` | Optional light theme |
| `darkTheme` | `SpreedlyTheme?` | `nil` | Optional dark theme |
| `allowBlankName` | `Bool` | `false` | Allow recaching without name fields |
| `allowExpiredDate` | `Bool` | `false` | Allow recaching with expired dates |
| `allowBlankDate` | `Bool` | `false` | Allow recaching without expiration date |
| `onProcessingResult` | `((PaymentProcessingResult) -> Void)?` | `nil` | Callback for validation/processing status |
| `onDismiss` | `(() -> Void)?` | `nil` | Callback when view should be dismissed |

### SavedCardInfo

Information about the saved card to display.

| Property | Type | Description |
|----------|------|-------------|
| `lastFourDigits` | `String` | Last 4 digits (e.g., "4242") |
| `cardType` | `String` | Card type (e.g., "Visa", "Mastercard") |
| `cardBrand` | `String?` | Optional. Card brand identifier |

### Validation Parameters

When using `SpreedlyCVVRecachingView`, you can specify validation parameters. All default to `false` and are always sent to the API.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `allowBlankName` | Allow recaching without requiring name fields | `false` |
| `allowExpiredDate` | Allow recaching with expired card dates | `false` |
| `allowBlankDate` | Allow recaching without requiring expiration date fields | `false` |

---

## Obtaining Saved Cards

Before presenting the CVV recaching UI, you need a list of saved payment methods. The SDK does **not** provide a built-in API for fetching saved cards -- merchants must maintain their own saved card list from their backend.

- The example app uses `FetchPaymentMethodsAPIClient` to retrieve saved payment methods from a sample backend.
- `SavedCardInfo` requires `lastFourDigits` and `cardType` (e.g., `"Visa"`, `"Mastercard"`). `cardBrand` is optional.
- Map your backend response to `SavedCardInfo` instances before passing them to `RecacheConfig`.

```swift
let cardInfo = SavedCardInfo(
    lastFourDigits: "4242",
    cardType: "Visa"
)
let config = RecacheConfig(cardInfo: cardInfo)
```

---

## Step-by-Step Integration

### SwiftUI

1. **Present as sheet:** Use `.sheet(isPresented:)` to present the recaching view when the user selects a saved card.

2. **Subscribe to payment results before presenting:** Call `Spreedly.shared().subscribeToPaymentResults` in `onAppear` (or before the sheet is shown). Results are delivered asynchronously via this subscription.

```swift
.onAppear {
    cancellable = Spreedly.shared().subscribeToPaymentResults { result in
        if result.isSuccess {
            showCVVRecaching = false
            // Use result.token for your payment processing
        } else if result.isFailure {
            if let failureDetails = result.failureDetails {
                print("Recaching failed: \(sanitizeForDisplay(failureDetails.getDescription()))")
            }
            showCVVRecaching = false
        }
    }
}
```

3. **Handle success and failure:** Check `result.isSuccess` and `result.isFailure` from `PaymentResult`. On success, use `result.token` for payment processing.

4. **Cancel subscription on disappear:** Prevent memory leaks by cancelling the subscription when the view disappears.

```swift
.onDisappear {
    cancellable?.cancel()
    cancellable = nil
}
```

**Complete SwiftUI Example:**

```swift
import SwiftUI
import SpreedlyUI
import SpreedlyCore
import Combine

struct SavedCardsView: View {
    @State private var showCVVRecaching = false
    @State private var selectedCard: SavedCard?
    @State private var paymentResult: PaymentResult?
    @State private var cancellable: AnyCancellable?

    struct SavedCard: Identifiable {
        let id: String
        let paymentMethodToken: String
        let lastFourDigits: String
        let cardType: String
        let cardBrand: String?
    }

    let savedCards: [SavedCard] = [
        SavedCard(
            id: "1",
            paymentMethodToken: "token_123",
            lastFourDigits: "4242",
            cardType: "Visa",
            cardBrand: "visa"
        )
    ]

    var body: some View {
        VStack {
            List(savedCards) { card in
                Button(action: {
                    selectedCard = card
                    Task {
                        let result = await SpreedlyConfigManager.shared.generateSignature()
                        switch result {
                        case .success:
                            showCVVRecaching = true
                        case .failure(let error):
                            // Handle error
                        }
                    }
                }) {
                    HStack {
                        Text(card.cardType)
                        Text("•••• \(card.lastFourDigits)")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .sheet(isPresented: $showCVVRecaching) {
            if let card = selectedCard {
                SpreedlyCVVRecachingView(
                    config: RecacheConfig(
                        cardInfo: SavedCardInfo(
                            lastFourDigits: card.lastFourDigits,
                            cardType: card.cardType,
                            cardBrand: card.cardBrand
                        ),
                        presentationMode: .bottomSheet
                    ),
                    paymentMethodToken: card.paymentMethodToken,
                    allowBlankName: false,
                    allowExpiredDate: false,
                    allowBlankDate: false,
                    onProcessingResult: { result in
                        if result.isProcessing {
                            // Show loading indicator
                        } else if result.isValidationFailed {
                            // Handle validation errors
                        }
                    },
                    onDismiss: {
                        showCVVRecaching = false
                    }
                )
                .screenPrevention()
            }
        }
        .onAppear {
            cancellable = Spreedly.shared().subscribeToPaymentResults { result in
                paymentResult = result
                if result.isSuccess {
                    showCVVRecaching = false
                    print("CVV recached successfully")
                } else if result.isFailure {
                    if let failureDetails = result.failureDetails {
                        print("Recaching failed: \(sanitizeForDisplay(failureDetails.getDescription()))")
                    }
                    showCVVRecaching = false
                }
            }
        }
        .onDisappear {
            cancellable?.cancel()
            cancellable = nil
            ValidationParamReset.reset()
        }
    }
}
```

### UIKit

Use `CVVRecachingViewController` with the required parameters:

```swift
import UIKit
import SpreedlyUI
import SpreedlyCore

class SavedCardsViewController: UIViewController {
    var selectedCard: SavedCard?

    @IBAction func updateCVVTapped(_ sender: UIButton) {
        guard let card = selectedCard else { return }

        Task {
            let signatureGenerated = await SpreedlyConfigManager.shared.generateSignature()
            await MainActor.run {
                switch signatureGenerated {
                case .success:
                    let recachingVC = CVVRecachingViewController(
                        lastFourDigits: card.lastFourDigits,
                        cardType: card.cardType,
                        cardBrand: card.cardBrand,
                        paymentMethodToken: card.paymentMethodToken,
                        presentationMode: 0,  // 0 = sheet, 1 = alert
                        labelText: "CVV",
                        placeholderText: "123",
                        buttonText: "Confirm",
                        cancelButtonText: "Cancel",
                        onProcessingResult: { result in
                            if result.isProcessing {
                                // Show loading indicator
                            } else if result.isValidationFailed {
                                // Handle validation errors
                            }
                        }
                    )
                    recachingVC.modalPresentationStyle = .formSheet
                    self.present(recachingVC, animated: true)
                case .failure(let error):
                    let alert = UIAlertController(
                        title: "Error",
                        message: "Failed to generate signature: \(error.localizedDescription)",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
```

Set `SpreedlyPaymentDelegate` to receive results, or use `Spreedly.shared().subscribeToPaymentResults` if available in your architecture.

### Objective-C

Use `CVVRecachingViewController` with alloc/init and the same parameters. Implement `SpreedlyPaymentDelegate` for results.

> **Note:** The example app uses `CVVRecachingDemoViewController` for this flow. The simplified `SavedCardsViewController` shown below demonstrates the same integration pattern.

```objc
#import "SavedCardsViewController.h"
#import <SpreedlyUI/SpreedlyUI-Swift.h>
#import <SpreedlyCore/SpreedlyCore-Swift.h>

@interface SavedCardsViewController () <SpreedlyPaymentDelegate>
@property (nonatomic, strong) SavedCard *selectedCard;
@end

@implementation SavedCardsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[Spreedly shared] setPaymentDelegate:self];
}

- (void)updateCVVTapped {
    if (!self.selectedCard) return;

    [[SpreedlyConfigManager shared] generateSignatureWithCompletion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                CVVRecachingViewController *recachingVC = [[CVVRecachingViewController alloc]
                    initWithLastFourDigits:self.selectedCard.lastFourDigits
                    cardType:self.selectedCard.cardType
                    cardBrand:self.selectedCard.cardBrand
                    paymentMethodToken:self.selectedCard.paymentMethodToken
                    presentationMode:0
                    labelText:@"CVV"
                    placeholderText:@"123"
                    buttonText:@"Confirm"
                    cancelButtonText:@"Cancel"
                    onProcessingResult:^(PaymentProcessingResult *result) {
                        if (result.isValidationFailed) {
                            NSLog(@"CVV validation failed");
                        } else if (result.isProcessing) {
                            NSLog(@"Recaching in progress...");
                        }
                    }];
                // Set validation parameters on the instance after initialization
                recachingVC.allowBlankName = YES;
                recachingVC.allowExpiredDate = YES;
                recachingVC.allowBlankDate = YES;
                recachingVC.modalPresentationStyle = UIModalPresentationFormSheet;
                [self presentViewController:recachingVC animated:YES completion:nil];
            } else {
                NSString *errorMessage = error ? error.localizedDescription : @"Failed to generate signature";
                UIAlertController *alert = [UIAlertController
                    alertControllerWithTitle:@"Error"
                    message:errorMessage
                    preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
            }
        });
    }];
}

#pragma mark - SpreedlyPaymentDelegate

- (void)paymentDidComplete:(PaymentResult *)result {
    if (result.isSuccess) {
        NSLog(@"CVV Recaching successful!");
        if (self.presentedViewController) {
            [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }
    } else if (result.isFailure) {
        if (result.failureDetails) {
            NSLog(@"Recaching failed: %@", sanitizeForDisplay([result.failureDetails getDescription]));
        }
        if (self.presentedViewController) {
            [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

@end
```

---

## Presentation Modes

The SDK supports two presentation modes via `ScreenPresentationMode`:

| Mode | Description |
|------|-------------|
| `.bottomSheet` | Slides up from bottom (recommended for mobile) |
| `.dialog` | Centered dialog overlay |

For dialog mode, use the SDK's `.crossDissolveFullScreenCover()` View extension instead of `.sheet()` (which gives you the dimmed background for centered dialog presentation):

```swift
.crossDissolveFullScreenCover(isPresented: $showCVVRecaching) {
    SpreedlyCVVRecachingView(
        config: RecacheConfig(
            cardInfo: SavedCardInfo(lastFourDigits: "4242", cardType: "Visa"),
            presentationMode: .dialog
        ),
        paymentMethodToken: paymentMethodToken,
        onDismiss: { showCVVRecaching = false }
    )
    .screenPrevention()
}
```

---

## Theme Customization

Apply custom themes via `theme` and `darkTheme` parameters on `SpreedlyCVVRecachingView`:

```swift
let lightTheme = SpreedlyThemeManager.createCustomTheme(
    colors: SpreedlyColors(
        primary: Color.blue,
        background: Color.white,
        text: Color.black
    )
)

let darkTheme = SpreedlyThemeManager.createCustomTheme(
    colors: SpreedlyColors(
        primary: Color.cyan,
        background: Color.black,
        text: Color.white
    )
)

SpreedlyCVVRecachingView(
    config: recacheConfig,
    paymentMethodToken: paymentMethodToken,
    theme: lightTheme,
    darkTheme: darkTheme,
    onProcessingResult: { _ in },
    onDismiss: { showCVVRecaching = false }
)
```

For UIKit, use `SPLThemeConfig` with `lightThemeConfig` and `darkThemeConfig`:

```swift
let lightThemeConfig = SPLThemeConfig(
    primaryColor: .systemBlue,
    secondaryColor: .systemGray,
    backgroundColor: .white,
    borderColor: .systemGray4,
    borderFocusedColor: .systemBlue,
    textColor: .black,
    textSecondaryColor: .systemGray,
    errorColor: .systemRed,
    placeholderColor: nil,
    borderRadius: 8.0
)

let recachingVC = CVVRecachingViewController(
    lastFourDigits: card.lastFourDigits,
    cardType: card.cardType,
    cardBrand: card.cardBrand,
    paymentMethodToken: card.paymentMethodToken,
    presentationMode: 0,
    labelText: "CVV",
    placeholderText: "123",
    buttonText: "Confirm",
    cancelButtonText: "Cancel",
    lightThemeConfig: lightThemeConfig,
    darkThemeConfig: darkThemeConfig,
    onProcessingResult: { _ in }
)
```

**Theme priority:** Explicit theme passed to the view > global theme > default theme.

---

## Error Handling

### Validation Errors

Handle validation failures in `onProcessingResult`:

```swift
onProcessingResult: { result in
    if result.isValidationFailed {
        if result.invalidFields.contains(.cvc) {
            showError("Please enter a valid CVV (3-4 digits)")
        }
    }
}
```

### Network Errors

Handle network and API errors in the payment result subscription:

```swift
Spreedly.shared().subscribeToPaymentResults { result in
    if result.isFailure, let failureDetails = result.failureDetails {
        switch failureDetails.errorType {
        case .networkError:
            showError("Network connection failed. Please check your internet connection.")
        case .apiError:
            showError("Recaching failed. Please try again.")
        default:
            showError(failureDetails.getDescription())
        }
    }
}
```

### Payment Method Not Found (404)

```swift
Spreedly.shared().subscribeToPaymentResults { result in
    if result.isFailure, let failureDetails = result.failureDetails {
        if failureDetails.statusCode?.intValue == 404 {
            showError("Payment method not found. Please add a new payment method.")
            removePaymentMethod(token: paymentMethodToken)
        }
    }
}
```

For error handling patterns, see [error-handling.md](error-handling.md).

---

## Security

### Screenshot Prevention

Always apply `.screenPrevention()` to protect sensitive CVV input:

```swift
SpreedlyCVVRecachingView(
    config: recacheConfig,
    paymentMethodToken: paymentMethodToken,
    onDismiss: { showCVVRecaching = false }
)
.screenPrevention()
```

### SecureValueContainer

The SDK uses `SecureValueContainer` to securely collect and transmit CVV values. CVV is never stored locally and is only transmitted over secure connections. When using SDK UI components, `SecureValueContainer` is managed automatically.

### Memory Management

Cancel payment result subscriptions to prevent memory leaks:

```swift
.onDisappear {
    cancellable?.cancel()
    cancellable = nil
    ValidationParamReset.reset()
}
```

Call `ValidationParamReset.reset()` in `onDisappear` to reset validation parameters to their defaults when the recaching view is dismissed.

---

## Troubleshooting

**View doesn't appear**

- Ensure `paymentMethodToken` is valid and not empty
- Check that `RecacheConfig` is properly initialized with required `cardInfo`
- Verify the sheet/full-screen cover binding is set to `true`
- For dialog mode, ensure you use `.crossDissolveFullScreenCover()` instead of `.sheet()`
- Check that the view is not hidden or covered by other views

**Payment result not received**

- Subscribe to `Spreedly.shared().subscribeToPaymentResults` before presenting the recaching UI
- Ensure the subscription is not cancelled prematurely
- For Objective-C, verify the delegate is set
- Avoid creating multiple subscriptions; only one should be active
- Verify SDK is initialized with `Spreedly.setup(config:)` before any payment operation

**Validation errors**

- Ensure CVV format is correct (3-4 digits)
- Check that `SecureValueContainer` is properly initialized
- Verify SDK configuration is correct
- Ensure `SecureValueContainer.shared.startCollection()` was called if using programmatic recaching

**"CVV is not available" error**

- For UI components: Ensure the user entered CVV in the input field
- For programmatic: Ensure `SecureValueContainer.shared.registerValue()` was called before recaching
- Check that `SecureValueContainer.shared.startCollection()` was called
- Verify CVV was not cleared before the recache call

**Payment method token not found (404)**

- Token may have been deleted
- Token may belong to a different environment
- Token may be invalid or expired
- Remove the token from saved payment methods and ask the user to add a new payment method

**Dialog mode not showing dimmed background**

- Ensure you use `.crossDissolveFullScreenCover()` modifier
- Check that `presentationMode` is set to `.dialog` in `RecacheConfig`

**Screen prevention not working**

- Ensure `.screenPrevention()` is applied to the recaching view
- Verify the SpreedlyUI module is properly imported

**Memory leaks or retain cycles**

- Cancel subscriptions in `onDisappear` or `dealloc`
- Verify `SecureValueContainer` is cleaned up after use

---

## Related Documentation

| Guide | Description |
|-------|-------------|
| [getting-started.md](getting-started.md) | SDK installation and basic setup |
| [error-handling.md](error-handling.md) | Error types, handling patterns, troubleshooting |
| [theme-and-styling.md](theme-and-styling.md) | Theming and customization |
| [security.md](security.md) | Security best practices |
| [RECACHING_FLOW.md](../development/RECACHING_FLOW.md) | Detailed flow diagrams for CVV recaching |
