//
//  RiskSupport.swift
//  SpreedlyRiskSupport
//
//  Dependency-carrying shim. Intentionally has no API.
//
//  SpreedlyPayPal.xcframework and SpreedlyBraintree.xcframework both link
//  `@rpath/PPRiskMagnes.framework` dynamically (PPRiskMagnes became a dynamic framework in
//  braintree_ios 7.11.0 / paypal-ios 3.1.0, both sourcing it from paypal-risk-ios 5.6.0).
//
//  SwiftPM does not allow a `.binaryTarget` to declare dependencies, so that requirement cannot be
//  expressed on the xcframework targets themselves. This target exists solely to depend on
//  `PayPalRisk`; the SpreedlyPayPal and SpreedlyBraintree products vend it alongside their binary
//  targets so the dynamic PPRiskMagnes.framework is resolved and embedded in the consuming app.
//
//  Without it the app builds cleanly and then fails at launch:
//    dyld: Library not loaded: @rpath/PPRiskMagnes.framework/PPRiskMagnes
//

import Foundation

/// Namespace placeholder. Do not add API here — this target is a dependency carrier only.
enum SpreedlyRiskSupport {}
