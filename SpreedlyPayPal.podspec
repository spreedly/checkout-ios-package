Pod::Spec.new do |s|
  s.name             = 'SpreedlyPayPal'
  s.version          = '1.6.1'
  s.summary          = 'Native PPCP (PayPal / Pay Later / Credit / Venmo) module for the Spreedly iOS SDK.'
  s.homepage         = 'https://github.com/spreedly/checkout-ios-package'
  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.authors          = 'Capillary, Inc.'
  s.source           = { :git => 'https://github.com/spreedly/checkout-ios-package', :tag => s.version }
  s.ios.deployment_target = '16.0'
  s.swift_version    = '5.10'

  s.dependency 'SpreedlyCore'
  # SpreedlyPayPal links FraudProtection, which links the now-dynamic PPRiskMagnes from the
  # shared paypal-risk-ios package (paypal-ios 3.1.0). Without this the pod installs cleanly
  # and the host app fails at launch with:
  #   dyld: Library not loaded: @rpath/PPRiskMagnes.framework/PPRiskMagnes
  s.dependency 'PayPalRisk'

  s.vendored_frameworks = 'Frameworks/SpreedlyPayPal.xcframework'
end
