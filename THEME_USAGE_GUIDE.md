# SpreedlyUI Theme Usage Guide

This guide covers all the ways to set themes in SpreedlyUI components across Swift and Objective-C implementations.

## Table of Contents

### Swift Implementation
1. [Theme Priority System](#theme-priority-system)
2. [Swift: Global Theme Setting](#swift-global-theme-setting)
3. [Swift: Component-Level Theme Setting](#swift-component-level-theme-setting)
4. [Swift: Complete Implementation Examples](#swift-complete-implementation-examples)

### Objective-C Implementation
5. [Objective-C: Global Theme Setting](#objective-c-global-theme-setting)
6. [Objective-C: Component-Level Theme Setting](#objective-c-component-level-theme-setting)
7. [Objective-C: Complete Implementation Examples](#objective-c-complete-implementation-examples)

### Common Reference
8. [Theme Configuration Classes](#theme-configuration-classes)
9. [Accessibility Support](#accessibility-support)
10. [Best Practices](#best-practices)
11. [Troubleshooting](#troubleshooting)

---

# Swift Implementation

## Theme Priority System

The SpreedlyUI theme system follows a clear priority hierarchy:

```
Custom Theme (passed to component) > Environment Theme > Global Theme > Default Theme
```

### Priority Explanation:

1. **Custom Theme**: Theme passed directly to a component (highest priority) - supports separate light/dark themes
2. **Environment Theme**: Theme set via SwiftUI environment (`.spreedlyTheme()`)
3. **Global Theme**: Theme set globally via `SpreedlyThemeManager` or `SpreedlyThemeManagerObjC` - supports separate light/dark themes
4. **Default Theme**: Built-in theme from `Theme.swift` (lowest priority) - automatically switches between light and dark

### Automatic Theme Switching

When you set separate light and dark themes (either globally or on components), the SDK automatically:
- **Detects the device's current color scheme** (light or dark mode)
- **Applies the appropriate theme** based on the color scheme
- **Updates the theme in real-time** when the color scheme changes (e.g., when user switches in Settings or Control Center)
- **Works with** iOS system dark mode settings

**Note**: Theme switching happens automatically - you don't need to manually detect color scheme changes or update themes. The components react to `@Environment(\.colorScheme)` changes automatically using SwiftUI's reactive system.

---

## Swift: Global Theme Setting

```swift
import SpreedlyUI

// Method 1: Set separate light and dark themes globally (Recommended)
let lightTheme = SpreedlyThemeManager.createCustomTheme(
    colors: SpreedlyColors(
        primary: Color.blue,
        secondary: Color.blue.opacity(0.7),
        background: Color.white,
        surface: Color.white,
        text: Color.black,
        textSecondary: Color.gray,
        border: Color.blue.opacity(0.3),
        borderFocused: Color.blue,
        error: Color.red
    )
)

let darkTheme = SpreedlyThemeManager.createCustomTheme(
    colors: SpreedlyColors(
        primary: Color.cyan,
        secondary: Color.cyan.opacity(0.7),
        background: Color.black,
        surface: Color(white: 0.1),
        text: Color.white,
        textSecondary: Color.gray,
        border: Color.cyan.opacity(0.3),
        borderFocused: Color.cyan,
        error: Color.red
    )
)

SpreedlyThemeManager.setGlobalTheme(lightTheme: lightTheme, darkTheme: darkTheme)

// Method 2: Set same theme for both modes (backward compatible)
let customTheme = SpreedlyThemeManager.createCustomTheme(
    colors: SpreedlyColors(
        primary: Color.blue,
        secondary: Color.blue.opacity(0.7),
        background: Color.white,
        text: Color.black,
        textSecondary: Color.gray,
        border: Color.blue.opacity(0.3),
        borderFocused: Color.blue,
        error: Color.red
    )
)
SpreedlyThemeManager.setGlobalTheme(customTheme)  // Used for both light and dark modes

// Method 3: Create and set theme from Android-style configuration
let androidTheme = SpreedlyThemeManager.createThemeFromAndroidConfig(
    primaryColor: "#0077C8",
    secondaryColor: "#AFB4B5",
    formBorderColor: "#D9D9D9",
    formBackgroundColor: "#FFFFFF",
    fieldBackgroundColor: "#F8F9FA",
    fieldLabelColor: "#6C757D",
    borderRadius: 8.0
)
SpreedlyThemeManager.setGlobalTheme(androidTheme)  // Used for both modes

// Method 4: Create and set custom theme with overrides directly
SpreedlyThemeManager.setCustomGlobalTheme(
    colors: SpreedlyColors(
        primary: Color.red,
        secondary: Color.red.opacity(0.7),
        background: Color.white
    ),
    spacing: SpreedlySpacing(md: 20, lg: 30)
)  // Used for both modes
```

---

## Swift: Component-Level Theme Setting

### CardFormDropIn (SwiftUI)

#### Swift Implementation

```swift
import SwiftUI
import SpreedlyUI

struct MyCheckoutView: View {
    // Method 1: Declare separate light and dark themes
    private let lightTheme = SpreedlyThemeManager.createCustomTheme(
        colors: SpreedlyColors(
            primary: Color.green,
            secondary: Color.green.opacity(0.7),
            background: Color.white,
            surface: Color.white,
            text: Color.black,
            textSecondary: Color.gray,
            border: Color.green.opacity(0.3),
            borderFocused: Color.green,
            error: Color.red
        )
    )
    
    private let darkTheme = SpreedlyThemeManager.createCustomTheme(
        colors: SpreedlyColors(
            primary: Color(red: 0.3, green: 0.8, blue: 0.5),
            secondary: Color(red: 0.3, green: 0.8, blue: 0.5).opacity(0.7),
            background: Color.black,
            surface: Color(white: 0.1),
            text: Color.white,
            textSecondary: Color.gray,
            border: Color(red: 0.3, green: 0.8, blue: 0.5).opacity(0.3),
            borderFocused: Color(red: 0.3, green: 0.8, blue: 0.5),
            error: Color.red
        )
    )
    
    var body: some View {
        VStack(spacing: 20) {
            // Method 1: Using separate light and dark themes (Recommended)
            CardFormDropIn(
                otherFields: [],
                yearFormat: .fourDigit,
                nameDisplayMode: .separateFields,
                theme: lightTheme,      // Light theme
                darkTheme: darkTheme,    // Dark theme
                onProcessingResult: { result in
                    // Handle result
                }
            )

            // Method 2: Using same theme for both modes (backward compatible)
            CardFormDropIn(
                otherFields: [],
                yearFormat: .fourDigit,
                nameDisplayMode: .separateFields,
                theme: lightTheme,  // Used for both light and dark modes
                onProcessingResult: { result in
                    // Handle result
                }
            )

            // Method 3: Using environment theme
            CardFormDropIn(
                otherFields: [],
                yearFormat: .fourDigit,
                nameDisplayMode: .separateFields,
                onProcessingResult: { result in
                    // Handle result
                }
            )
            .spreedlyTheme(lightTheme)  // Environment theme

            // Method 4: Using global theme (no theme parameter)
            CardFormDropIn(
                otherFields: [],
                yearFormat: .fourDigit,
                nameDisplayMode: .separateFields,
                onProcessingResult: { result in
                    // Handle result
                }
            )
        }
    }
}
```

### SPLTextField (SwiftUI)

#### Swift Implementation

```swift
import SwiftUI
import SpreedlyUI

struct MyTextFieldView: View {
    // Declare separate light and dark themes
    private let lightTheme = SpreedlyThemeManager.createCustomTheme(
        colors: SpreedlyColors(
            primary: Color.purple,
            secondary: Color.purple.opacity(0.7),
            background: Color.white,
            surface: Color.white,
            text: Color.black,
            textSecondary: Color.gray,
            border: Color.purple.opacity(0.3),
            borderFocused: Color.purple,
            error: Color.red
        )
    )
    
    private let darkTheme = SpreedlyThemeManager.createCustomTheme(
        colors: SpreedlyColors(
            primary: Color(red: 0.6, green: 0.4, blue: 1.0),
            secondary: Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.7),
            background: Color.black,
            surface: Color(white: 0.1),
            text: Color.white,
            textSecondary: Color.gray,
            border: Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.3),
            borderFocused: Color(red: 0.6, green: 0.4, blue: 1.0),
            error: Color.red
        )
    )
    
    var body: some View {
        VStack(spacing: 20) {
            // Method 1: Using separate light and dark themes (Recommended)
            SPLTextField(
                type: .fullName,
                title: "Full Name",
                isRequired: true,
                placeholder: "Enter your full name",
                theme: lightTheme,      // Light theme
                darkTheme: darkTheme,    // Dark theme
                onValidationChange: { isValid in
                    // Handle validation
                }
            )

            // Method 2: Using same theme for both modes (backward compatible)
            SPLTextField(
                type: .fullName,
                title: "Full Name",
                isRequired: true,
                placeholder: "Enter your full name",
                theme: lightTheme,  // Used for both light and dark modes
                onValidationChange: { isValid in
                    // Handle validation
                }
            )

            // Method 3: Using environment theme
            SPLTextField(
                type: .fullName,
                title: "Full Name",
                isRequired: true,
                placeholder: "Enter your full name",
                onValidationChange: { isValid in
                    // Handle validation
                }
            )
            .spreedlyTheme(lightTheme)  // Environment theme

            // Method 4: Using global theme (no theme parameter)
            SPLTextField(
                type: .fullName,
                title: "Full Name",
                isRequired: true,
                placeholder: "Enter your full name",
                onValidationChange: { isValid in
                    // Handle validation
                }
            )
        }
    }
}
```

---

## Swift: Complete Implementation Examples

### Complete SwiftUI Example

```swift
import SwiftUI
import SpreedlyUI

struct CompleteThemeExample: View {
    @State private var showForm = false
    @State private var useCustomTheme = false
    @State private var customTheme: SpreedlyTheme?

    var body: some View {
        VStack(spacing: 20) {
            // Global theme setup (typically in AppDelegate or App.swift)
            Button("Set Global Blue Theme") {
                let globalTheme = SpreedlyThemeManager.createCustomTheme(
                    colors: SpreedlyColors(
                        primary: Color.blue,
                        secondary: Color.blue.opacity(0.7),
                        background: Color.white,
                        text: Color.black,
                        textSecondary: Color.gray,
                        border: Color.blue.opacity(0.3),
                        borderFocused: Color.blue,
                        error: Color.red
                    )
                )
                SpreedlyThemeManager.setGlobalTheme(globalTheme)
            }

            // Custom theme toggle
            Toggle("Use Custom Theme", isOn: $useCustomTheme)

            if useCustomTheme {
                Button("Set Custom Green Theme") {
                    customTheme = SpreedlyThemeManager.createCustomTheme(
                        colors: SpreedlyColors(
                            primary: Color.green,
                            secondary: Color.green.opacity(0.7),
                            background: Color.white,
                            text: Color.black,
                            textSecondary: Color.gray,
                            border: Color.green.opacity(0.3),
                            borderFocused: Color.green,
                            error: Color.red
                        )
                    )
                }
            }

            Button("Show Checkout Form") {
                showForm = true
            }
        }
        .sheet(isPresented: $showForm) {
            CardFormDropIn(
                yearFormat: .fourDigit,
                nameDisplayMode: .separateFields,
                theme: useCustomTheme ? customTheme : nil,  // Custom theme if enabled
                onProcessingResult: { result in
                    // Handle result
                }
            )
        }
    }
}
```

---

# Objective-C Implementation

## Objective-C: Global Theme Setting

```objc
#import <SpreedlyUI/SpreedlyUI-Swift.h>

// Method 1: Set separate light and dark themes globally (Recommended)
SPLThemeConfig *lightThemeConfig = [[SPLThemeConfig alloc] initWithPrimaryColorHex:@"#0077C8"
    secondaryColorHex:@"#AFB4B5"
    formBorderColorHex:@"#D9D9D9"
    formBackgroundColorHex:@"#FFFFFF"
    fieldBackgroundColorHex:@"#F8F9FA"
    fieldLabelColorHex:@"#6C757D"
    borderRadius:8.0];

SPLThemeConfig *darkThemeConfig = [[SPLThemeConfig alloc] initWithPrimaryColorHex:@"#00A0FF"
    secondaryColorHex:@"#6C757D"
    formBorderColorHex:@"#4A4A4A"
    formBackgroundColorHex:@"#1C1C1E"
    fieldBackgroundColorHex:@"#2C2C2E"
    fieldLabelColorHex:@"#AEAEB2"
    borderRadius:8.0];

[SpreedlyThemeManagerObjC setGlobalThemeWithLightConfig:lightThemeConfig darkConfig:darkThemeConfig];

// Method 2: Set same theme for both modes (backward compatible)
SPLThemeConfig *globalTheme = [[SPLThemeConfig alloc] initWithPrimaryColorHex:@"#0077C8"
    secondaryColorHex:@"#AFB4B5"
    formBorderColorHex:@"#D9D9D9"
    formBackgroundColorHex:@"#FFFFFF"
    fieldBackgroundColorHex:@"#F8F9FA"
    fieldLabelColorHex:@"#6C757D"
    borderRadius:8.0];
[SpreedlyThemeManagerObjC setGlobalThemeWithConfig:globalTheme];  // Used for both modes

// Method 3: Set separate themes with hex colors
[SpreedlyThemeManagerObjC setGlobalThemeWithLightHexColors:
    lightPrimaryColorHex:@"#0077C8"
    lightSecondaryColorHex:@"#AFB4B5"
    lightFormBorderColorHex:@"#D9D9D9"
    lightFormBackgroundColorHex:@"#FFFFFF"
    lightFieldBackgroundColorHex:@"#F8F9FA"
    lightFieldLabelColorHex:@"#6C757D"
    darkPrimaryColorHex:@"#00A0FF"
    darkSecondaryColorHex:@"#6C757D"
    darkFormBorderColorHex:@"#4A4A4A"
    darkFormBackgroundColorHex:@"#1C1C1E"
    darkFieldBackgroundColorHex:@"#2C2C2E"
    darkFieldLabelColorHex:@"#AEAEB2"
    borderRadius:8.0];

// Method 4: Set same theme with hex colors (backward compatible)
[SpreedlyThemeManagerObjC setGlobalThemeWithHexColors:@"#0077C8"
    secondaryColorHex:@"#AFB4B5"
    formBorderColorHex:@"#D9D9D9"
    formBackgroundColorHex:@"#FFFFFF"
    fieldBackgroundColorHex:@"#F8F9FA"
    fieldLabelColorHex:@"#6C757D"
    borderRadius:8.0];  // Used for both modes

// Method 5: Set separate themes with UIColor properties
[SpreedlyThemeManagerObjC setGlobalThemeWithLightColors:
    lightPrimaryColor:[UIColor blueColor]
    lightSecondaryColor:[UIColor systemBlueColor]
    lightBackgroundColor:[UIColor systemBackgroundColor]
    lightBorderColor:[UIColor systemGray4Color]
    lightTextColor:[UIColor labelColor]
    darkPrimaryColor:[UIColor cyanColor]
    darkSecondaryColor:[UIColor systemCyanColor]
    darkBackgroundColor:[UIColor blackColor]
    darkBorderColor:[UIColor darkGrayColor]
    darkTextColor:[UIColor whiteColor]
    borderRadius:8.0];

// Method 6: Set same theme with UIColor properties (backward compatible)
[SpreedlyThemeManagerObjC setGlobalThemeWithColors:[UIColor blueColor]
    secondaryColor:[UIColor systemBlueColor]
    formBorderColor:[UIColor systemGray4Color]
    formBackgroundColor:[UIColor systemBackgroundColor]
    fieldBackgroundColor:[UIColor systemGray6Color]
    fieldLabelColor:[UIColor systemGrayColor]
    borderRadius:8.0];  // Used for both modes
```

## Objective-C: Component-Level Theme Setting

### CardFormDropInViewController

```objc
#import <SpreedlyUI/SpreedlyUI-Swift.h>

// Method 1: Using separate light and dark theme configs (Recommended)
SPLThemeConfig *lightThemeConfig = [[SPLThemeConfig alloc] initWithPrimaryColorHex:@"#0077C8"
    secondaryColorHex:@"#AFB4B5"
    formBorderColorHex:@"#D9D9D9"
    formBackgroundColorHex:@"#FFFFFF"
    fieldBackgroundColorHex:@"#F8F9FA"
    fieldLabelColorHex:@"#6C757D"
    borderRadius:8.0];

SPLThemeConfig *darkThemeConfig = [[SPLThemeConfig alloc] initWithPrimaryColorHex:@"#00A0FF"
    secondaryColorHex:@"#6C757D"
    formBorderColorHex:@"#4A4A4A"
    formBackgroundColorHex:@"#1C1C1E"
    fieldBackgroundColorHex:@"#2C2C2E"
    fieldLabelColorHex:@"#AEAEB2"
    borderRadius:8.0];

// Set validation parameters before creating CardFormDropInViewController (optional)
[[Spreedly shared] setParamWithParameter:ValidationParamAllowBlankName value:NO];
[[Spreedly shared] setParamWithParameter:ValidationParamAllowExpiredDate value:NO];

CardFormDropInViewController *dropInVC = [[CardFormDropInViewController alloc]
    initWithOtherFields:@[]
    yearFormat:YearFormatFourDigit
    nameDisplayMode:DropInNameDisplayModeSeparateFields
    lightThemeConfig:lightThemeConfig
    darkThemeConfig:darkThemeConfig
    onProcessingResult:^(PaymentProcessingResult *result) {
        // Handle result
    }];

// Method 2: Using same theme for both modes (backward compatible)
SPLThemeConfig *themeConfig = [[SPLThemeConfig alloc] initWithPrimaryColorHex:@"#0077C8"
    secondaryColorHex:@"#AFB4B5"
    formBorderColorHex:@"#D9D9D9"
    formBackgroundColorHex:@"#FFFFFF"
    fieldBackgroundColorHex:@"#F8F9FA"
    fieldLabelColorHex:@"#6C757D"
    borderRadius:8.0];

CardFormDropInViewController *dropInVC = [[CardFormDropInViewController alloc]
    initWithOtherFields:@[]
    yearFormat:YearFormatFourDigit
    nameDisplayMode:DropInNameDisplayModeSeparateFields
    themeConfig:themeConfig  // Used for both light and dark modes
    onProcessingResult:^(PaymentProcessingResult *result) {
        // Handle result
    }];

// Method 3: Using global theme (no themeConfig parameter)
CardFormDropInViewController *dropInVC = [[CardFormDropInViewController alloc]
    initWithOtherFields:@[]
    yearFormat:YearFormatFourDigit
    nameDisplayMode:DropInNameDisplayModeSeparateFields
    onProcessingResult:^(PaymentProcessingResult *result) {
        // Handle result
    }];
```

### SPLTextFieldViewController

```objc
#import <SpreedlyUI/SpreedlyUI-Swift.h>

// Method 1: Using separate light and dark theme configs (Recommended)
SPLThemeConfig *lightThemeConfig = [[SPLThemeConfig alloc] initWithPrimaryColorHex:@"#0077C8"
    secondaryColorHex:@"#AFB4B5"
    formBorderColorHex:@"#D9D9D9"
    formBackgroundColorHex:@"#FFFFFF"
    fieldBackgroundColorHex:@"#F8F9FA"
    fieldLabelColorHex:@"#6C757D"
    borderRadius:8.0];

SPLThemeConfig *darkThemeConfig = [[SPLThemeConfig alloc] initWithPrimaryColorHex:@"#00A0FF"
    secondaryColorHex:@"#6C757D"
    formBorderColorHex:@"#4A4A4A"
    formBackgroundColorHex:@"#1C1C1E"
    fieldBackgroundColorHex:@"#2C2C2E"
    fieldLabelColorHex:@"#AEAEB2"
    borderRadius:8.0];

SPLTextFieldViewController *textFieldVC = [[SPLTextFieldViewController alloc]
    initWithField:FormFieldTypeFullName
    title:@"Full Name"
    isRequired:YES
    placeholder:@"Enter your full name"
    keyboardType:UIKeyboardTypeDefault
    textContentType:UITextContentTypeName
    lightThemeConfig:lightThemeConfig
    darkThemeConfig:darkThemeConfig
    onValidationChange:^(BOOL isValid) {
        // Handle validation
    }
    onFocus:nil];

// Method 2: Using same theme for both modes (backward compatible)
SPLThemeConfig *themeConfig = [[SPLThemeConfig alloc] initWithPrimaryColorHex:@"#0077C8"
    secondaryColorHex:@"#AFB4B5"
    formBorderColorHex:@"#D9D9D9"
    formBackgroundColorHex:@"#FFFFFF"
    fieldBackgroundColorHex:@"#F8F9FA"
    fieldLabelColorHex:@"#6C757D"
    borderRadius:8.0];

SPLTextFieldViewController *textFieldVC = [[SPLTextFieldViewController alloc]
    initWithField:FormFieldTypeFullName
    title:@"Full Name"
    isRequired:YES
    placeholder:@"Enter your full name"
    keyboardType:UIKeyboardTypeDefault
    textContentType:UITextContentTypeName
    themeConfig:themeConfig  // Used for both light and dark modes
    onValidationChange:^(BOOL isValid) {
        // Handle validation
    }];

// Method 3: Using global theme (no themeConfig parameter)
SPLTextFieldViewController *textFieldVC = [[SPLTextFieldViewController alloc]
    initWithField:FormFieldTypeFullName
    title:@"Full Name"
    isRequired:YES
    placeholder:@"Enter your full name"
    keyboardType:UIKeyboardTypeDefault
    textContentType:UITextContentTypeName
    onValidationChange:^(BOOL isValid) {
        // Handle validation
    }];
```

## Objective-C: Complete Implementation Examples

### Complete Objective-C Example

```objc
// AppDelegate.m
#import <SpreedlyUI/SpreedlyUI-Swift.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Set global theme for all SpreedlyUI components
    SPLThemeConfig *globalTheme = [[SPLThemeConfig alloc] initWithPrimaryColorHex:@"#0077C8"
        secondaryColorHex:@"#AFB4B5"
        formBorderColorHex:@"#D9D9D9"
        formBackgroundColorHex:@"#FFFFFF"
        fieldBackgroundColorHex:@"#F8F9FA"
        fieldLabelColorHex:@"#6C757D"
        borderRadius:8.0];
    [SpreedlyThemeManagerObjC setGlobalThemeWithConfig:globalTheme];

    return YES;
}

// ViewController.m
#import <SpreedlyUI/SpreedlyUI-Swift.h>

@interface ViewController ()
@property (nonatomic, strong) CardFormDropInViewController *dropInVC;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Create CardFormDropIn with custom theme
    SPLThemeConfig *customTheme = [[SPLThemeConfig alloc] initWithPrimaryColorHex:@"#28A745"
        secondaryColorHex:@"#20C997"
        formBorderColorHex:@"#6C757D"
        formBackgroundColorHex:@"#FFFFFF"
        fieldBackgroundColorHex:@"#F8F9FA"
        fieldLabelColorHex:@"#495057"
        borderRadius:12.0];

    // Set validation parameters (optional)
    [[Spreedly shared] setParamWithParameter:ValidationParamAllowBlankName value:NO];
    [[Spreedly shared] setParamWithParameter:ValidationParamAllowExpiredDate value:NO];
    
    self.dropInVC = [[CardFormDropInViewController alloc]
        initWithOtherFields:@[]
        yearFormat:YearFormatFourDigit
        nameDisplayMode:DropInNameDisplayModeSeparateFields
        themeConfig:customTheme
        onProcessingResult:^(PaymentProcessingResult *result) {
            if (result.isSuccess) {
                NSLog(@"Payment successful!");
            } else if (result.isValidationFailed) {
                NSLog(@"Validation failed: %@", result.errorMessage);
            } else {
                NSLog(@"Payment failed: %@", result.errorMessage);
            }
        }];

    // Add to view hierarchy
    [self addChildViewController:self.dropInVC];
    [self.view addSubview:self.dropInVC.view];
    [self.dropInVC didMoveToParentViewController:self];

    // Set up constraints
    self.dropInVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.dropInVC.view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.dropInVC.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.dropInVC.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.dropInVC.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

@end
```

---

# Common Reference

## Android-Style Theme Configuration

SpreedlyUI provides Android-style configuration options that make it easy to migrate themes from Android applications or use familiar Android color naming conventions.

### Swift Android-Style Configuration

```swift
import SpreedlyUI

// Method 1: Using SpreedlyThemeManager.createThemeFromAndroidConfig
let androidTheme = SpreedlyThemeManager.createThemeFromAndroidConfig(
    primaryColor: "#0077C8",           // Primary brand color
    secondaryColor: "#AFB4B5",         // Secondary/accent color
    formBorderColor: "#D9D9D9",        // Form field borders
    formBackgroundColor: "#FFFFFF",    // Form container background
    fieldBackgroundColor: "#F8F9FA",   // Individual field background
    fieldLabelColor: "#6C757D",        // Field labels and placeholders
    borderRadius: 8.0                  // Corner radius for elements
)

// Set as global theme
SpreedlyThemeManager.setGlobalTheme(androidTheme)

// Use in components
CardFormDropIn(
    yearFormat: .fourDigit,
    nameDisplayMode: .separateFields,
    theme: androidTheme,  // Custom Android-style theme
    onProcessingResult: { result in
        // Handle result
    }
)
```

### Objective-C Android-Style Configuration

```objc
#import <SpreedlyUI/SpreedlyUI-Swift.h>

// Method 1: Using SPLThemeConfig with Android-style hex colors
SPLThemeConfig *androidTheme = [[SPLThemeConfig alloc] initWithPrimaryColorHex:@"#0077C8"
    secondaryColorHex:@"#AFB4B5"
    formBorderColorHex:@"#D9D9D9"
    formBackgroundColorHex:@"#FFFFFF"
    fieldBackgroundColorHex:@"#F8F9FA"
    fieldLabelColorHex:@"#6C757D"
    borderRadius:8.0];

// Set as global theme
[SpreedlyThemeManagerObjC setGlobalThemeWithConfig:androidTheme];

// Set validation parameters (optional)
[[Spreedly shared] setParamWithParameter:ValidationParamAllowBlankName value:NO];
[[Spreedly shared] setParamWithParameter:ValidationParamAllowExpiredDate value:NO];

// Use in components
CardFormDropInViewController *dropInVC = [[CardFormDropInViewController alloc]
    initWithOtherFields:@[]
    yearFormat:YearFormatFourDigit
    nameDisplayMode:DropInNameDisplayModeSeparateFields
    themeConfig:androidTheme
    onProcessingResult:^(PaymentProcessingResult *result) {
        if (result.isSuccess) {
            // Handle success
        } else if (result.isValidationFailed) {
            // Handle validation errors
        } else {
            // Handle payment errors
        }
    }];
```

### Android Color Mapping

The Android-style configuration maps Android color concepts to SpreedlyUI themes:

| Android Concept        | SpreedlyUI Property | Description                                         |
| ---------------------- | ------------------- | --------------------------------------------------- |
| `primaryColor`         | `primary`           | Main brand color for buttons, links, and highlights |
| `secondaryColor`       | `secondary`         | Secondary brand color for accents and borders       |
| `formBorderColor`      | `border`            | Color for form field borders                        |
| `formBackgroundColor`  | `background`        | Background color for form containers                |
| `fieldBackgroundColor` | `surface`           | Background color for individual input fields        |
| `fieldLabelColor`      | `textSecondary`     | Color for field labels and placeholder text         |
| `borderRadius`         | `borderRadius`      | Corner radius for form elements                     |

### Default Values

When using Android-style configuration, default values are automatically applied for missing colors:

```swift
// Default color mappings
let defaultColors = [
    "text": "#000000",           // Black text
    "error": "#DC3545",          // Red for errors
    "placeholder": "#AFB4B5",    // Gray for placeholders
    "disabled": "#ADB5BD"        // Light gray for disabled states
]
```

### Migration from Android

If you're migrating from an Android app, you can directly use your existing color values:

```objc
// Android colors (example)
// primaryColor: #0077C8
// secondaryColor: #AFB4B5
// formBorderColor: #D9D9D9
// formBackgroundColor: #FFFFFF
// fieldBackgroundColor: #F8F9FA
// fieldLabelColor: #6C757D

// Direct migration to iOS
SPLThemeConfig *migratedTheme = [[SPLThemeConfig alloc] initWithPrimaryColorHex:@"#0077C8"
    secondaryColorHex:@"#AFB4B5"
    formBorderColorHex:@"#D9D9D9"
    formBackgroundColorHex:@"#FFFFFF"
    fieldBackgroundColorHex:@"#F8F9FA"
    fieldLabelColorHex:@"#6C757D"
    borderRadius:8.0];
```

---

## Theme Configuration Classes

### SPLThemeConfig (Objective-C Compatible)

```objc
// Method 1: Initialize with hex colors (Android-style configuration)
SPLThemeConfig *themeConfig = [[SPLThemeConfig alloc] initWithPrimaryColorHex:@"#0077C8"
    secondaryColorHex:@"#AFB4B5"
    formBorderColorHex:@"#D9D9D9"
    formBackgroundColorHex:@"#FFFFFF"
    fieldBackgroundColorHex:@"#F8F9FA"
    fieldLabelColorHex:@"#6C757D"
    borderRadius:8.0];

// Method 2: Initialize with UIColor properties
SPLThemeConfig *themeConfig = [[SPLThemeConfig alloc] initWithPrimaryColor:[UIColor blueColor]
    secondaryColor:[UIColor systemBlueColor]
    backgroundColor:[UIColor systemBackgroundColor]
    borderColor:[UIColor systemGray4Color]
    borderFocusedColor:[UIColor blueColor]
    textColor:[UIColor labelColor]
    textSecondaryColor:[UIColor systemGrayColor]
    errorColor:[UIColor systemRedColor]
    placeholderColor:[UIColor systemGrayColor]
    borderRadius:8.0];

// Method 3: Minimal Android-style configuration (only primary color required)
SPLThemeConfig *themeConfig = [[SPLThemeConfig alloc] initWithPrimaryColorHex:@"#0077C8"
    secondaryColorHex:nil
    formBorderColorHex:nil
    formBackgroundColorHex:nil
    fieldBackgroundColorHex:nil
    fieldLabelColorHex:nil
    borderRadius:8.0];
```

### SpreedlyTheme (Swift Only)

```swift
// Method 1: Create custom theme with full customization
let customTheme = SpreedlyThemeManager.createCustomTheme(
    colors: SpreedlyColors(
        primary: Color.blue,
        secondary: Color.blue.opacity(0.7),
        background: Color.white,
        text: Color.black,
        textSecondary: Color.gray,
        border: Color.blue.opacity(0.3),
        borderFocused: Color.blue,
        error: Color.red
    ),
    typography: SpreedlyTypography(
        titleFont: SpreedlyFont.system(size: 32, weight: .bold, design: .rounded),
        subtitleFont: SpreedlyFont.system(size: 18, weight: .semibold, design: .rounded),
        bodyFont: SpreedlyFont.system(size: 16, weight: .regular, design: .rounded),
        captionFont: SpreedlyFont.system(size: 12, weight: .regular, design: .rounded)
    ),
    spacing: SpreedlySpacing(
        xs: 4,
        sm: 8,
        md: 16,
        lg: 24,
        xl: 32
    ),
    borderRadius: SpreedlyBorderRadius(
        sm: 4,
        md: 8,
        lg: 12
    ),
    shadows: SpreedlyShadows(
        small: Shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1),
        medium: Shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2),
        large: Shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    )
)

// Method 2: Create theme from Android-style configuration
let androidTheme = SpreedlyThemeManager.createThemeFromAndroidConfig(
    primaryColor: "#0077C8",
    secondaryColor: "#AFB4B5",
    formBorderColor: "#D9D9D9",
    formBackgroundColor: "#FFFFFF",
    fieldBackgroundColor: "#F8F9FA",
    fieldLabelColor: "#6C757D",
    borderRadius: 8.0
)

// Method 3: Create theme with Android-style configuration
let hexTheme = SpreedlyThemeManager.createThemeFromAndroidConfig(
    primaryColor: "#0077C8",
    secondaryColor: "#AFB4B5",
    formBorderColor: "#D9D9D9",
    formBackgroundColor: "#FFFFFF",
    fieldBackgroundColor: "#F8F9FA",
    fieldLabelColor: "#6C757D",
    borderRadius: 8.0
)
SpreedlyThemeManager.setGlobalTheme(hexTheme)
```

---

## Best Practices

### 1. Global Theme Setup

- Set global themes early in your app lifecycle (AppDelegate or App.swift)
- Use global themes for consistent branding across your app
- Consider your app's primary color scheme when setting global themes

### 2. Component-Level Themes

- Use custom themes for specific screens or components that need different styling
- Custom themes override global themes, providing flexibility
- Consider using environment themes for SwiftUI views that need consistent theming

### 3. Theme Priority

- Remember the priority: Custom > Environment > Global > Default
- Test your theme hierarchy to ensure expected behavior
- Document your theme usage for team members

### 4. Performance Considerations

- Create theme objects once and reuse them
- Avoid creating themes in view body or frequent update cycles
- Use global themes when possible to reduce theme object creation

### 5. Accessibility

- Ensure sufficient color contrast in your themes
- Test themes with accessibility features enabled
- Consider dark mode compatibility
- Use accessibility-aware fonts for automatic Dynamic Type scaling
- Test with different text sizes and accessibility settings

---

## Accessibility Support

The SpreedlyUI SDK includes accessibility support with automatic Dynamic Type scaling and runtime theme updates.

### Font System

The SDK uses `SpreedlyFont` for all typography, which automatically scales with iOS accessibility settings:

```swift
// SpreedlyFont automatically scales with accessibility settings
let typography = SpreedlyTypography(
    titleFont: SpreedlyFont.system(size: 32, weight: .bold, design: .rounded),
    subtitleFont: SpreedlyFont.system(size: 18, weight: .semibold, design: .rounded),
    bodyFont: SpreedlyFont.system(size: 16, weight: .regular, design: .rounded),
    captionFont: SpreedlyFont.system(size: 12, weight: .regular, design: .rounded),
    buttonFont: SpreedlyFont.system(size: 20, weight: .bold, design: .rounded),
    fieldFont: SpreedlyFont.system(size: 18, weight: .regular, design: .rounded)
)
```

### Font Mapping

Each font type is mapped to an appropriate iOS text style for optimal accessibility scaling:

- `titleFont` → `.largeTitle` (32pt base)
- `subtitleFont` → `.title2` (18pt base)
- `bodyFont` → `.body` (16pt base)
- `captionFont` → `.caption1` (12pt base)
- `buttonFont` → `.headline` (20pt base)
- `fieldFont` → `.body` (18pt base)

### Automatic Theme Refresh

The SDK automatically handles accessibility changes in the following scenarios:

#### 1. View First Appears
- Themes are refreshed when components first appear
- Ensures correct font sizes from the start

#### 2. Real-time Changes
- `UIContentSizeCategory.didChangeNotification` - when user changes font size while app is active
- `UIAccessibility.boldTextStatusDidChangeNotification` - when user toggles Bold Text setting while app is active
- `UIApplication.didBecomeActiveNotification` - when user changes settings while app is in background

#### 3. Supported Components
- `CardFormDropIn` - automatically refreshes custom themes
- `SPLTextField` - automatically refreshes custom themes
- `CustomThemeFormView` - automatically refreshes custom themes

### Custom Font Support

For custom fonts, the SDK calculates accessibility scaling factors:

```swift
// Custom fonts automatically scale with accessibility settings
let customTypography = SpreedlyTypography(
    titleFont: SpreedlyFont.custom(fontName: "MyFont-Bold", size: 32, weight: .bold),
    bodyFont: SpreedlyFont.custom(fontName: "MyFont-Regular", size: 16, weight: .regular)
)
```

### Testing Accessibility

#### Manual Testing
1. **Start your app** and note current font sizes and weights
2. **Put app in background**
3. **Change accessibility settings** (Settings > Display & Brightness > Text Size)
4. **Toggle Bold Text** (Settings > Accessibility > Display & Text Size > Bold Text)
5. **Return to app** and verify fonts have updated
6. **Test while app is active** - change settings and verify immediate updates

#### Automated Testing
```swift
func testAccessibilityFontScaling() {
    // Test with different accessibility settings
    let smallText = SpreedlyTypography()
    // Simulate accessibility change
    let largeText = SpreedlyTypography()
    
    // Verify fonts are different
    XCTAssertNotEqual(smallText.titleFont, largeText.titleFont)
}
```

### Accessibility Best Practices

1. **Use system fonts when possible** - They automatically scale with iOS settings
2. **Test with large text sizes** - Ensure your UI works with accessibility text sizes
3. **Test with Bold Text setting** - Verify fonts become bolder when Bold Text is enabled
4. **Consider layout constraints** - Large text may require more space
5. **Use appropriate text styles** - Match the semantic meaning of your text
6. **Test with accessibility features** - Verify Bold Text and other settings work
7. **Start with defaults** - Use default values and customize only what you need

### Troubleshooting Accessibility Issues

#### Fonts Not Scaling
- Ensure you're using `SpreedlyFont` instead of SwiftUI `Font`
- Check that you're not overriding fonts with fixed sizes elsewhere
- Verify the text styles are appropriate for your content

#### Layout Issues with Large Text
- Use flexible layouts (VStack, HStack with proper spacing)
- Consider using `ScrollView` for content that might overflow
- Test with the largest accessibility text sizes

#### Custom Themes Not Updating
- Ensure custom themes are passed to supported components
- Check that observers are properly set up (automatic in supported components)
- Verify accessibility settings are actually changing

#### Bold Text Not Working
- Ensure you're using `SpreedlyFont` instead of SwiftUI `Font`
- Check that `UIAccessibility.boldTextStatusDidChangeNotification` observer is set up
- Verify Bold Text setting is enabled in device settings
- Test with different font weights to see the bold effect

**Note**: Bold Text increases font weight by one step (e.g., Regular → Semibold), not to a fixed weight like 700. This matches iOS system behavior.

---

## Troubleshooting

### Common Issues

#### 1. Theme Not Applied

**Problem**: Custom theme not showing up
**Solution**: Check theme priority - custom themes override global themes

#### 2. Objective-C Compilation Errors

**Problem**: `SpreedlyTheme` not accessible in Objective-C
**Solution**: Use `SPLThemeConfig` for Objective-C compatibility

#### 3. Global Theme Not Working

**Problem**: Global theme not applied to components
**Solution**: Ensure global theme is set before component initialization

#### 4. Environment Theme Issues

**Problem**: Environment theme not working in SwiftUI
**Solution**: Apply `.spreedlyTheme()` modifier to parent view

### Debug Tips

```swift
// Check current global theme
let currentGlobalTheme = SpreedlyThemeManager.globalTheme
print("Current global theme: \(currentGlobalTheme)")

// Verify theme priority in component
// Custom theme takes precedence over environment and global themes
```

```objc
// Check if global theme is set
// Global theme is automatically applied when no custom theme is provided
```

---

## Migration Guide

### From String-Based Themes to Enum-Based Themes

If you're migrating from string-based theme names to enum-based themes:

```swift
// Old approach (string-based)
@State private var selectedThemeName: String = "Default"

// New approach (enum-based)
enum ThemeOption: String, CaseIterable {
    case `default` = "Default"
    case blue = "Blue Theme"
    case green = "Green Theme"
    case purple = "Purple Theme"
}

@State private var selectedTheme: ThemeOption = .default
```

### Benefits of Migration:

- Type safety
- Compile-time error checking
- Better IDE support
- Easier maintenance
- Consistent theme references

---

This guide covers all theme setting options in SpreedlyUI. For additional support or questions, refer to the SpreedlyUI documentation or contact the development team.
