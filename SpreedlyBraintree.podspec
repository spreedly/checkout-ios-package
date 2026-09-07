Pod::Spec.new do |s|
  s.name             = 'SpreedlyBraintree'
  s.version          = '1.6.1'
  s.summary          = 'Braintree (PayPal/Venmo) module for the Spreedly iOS SDK.'
  s.homepage         = 'https://github.com/spreedly/checkout-ios-package'
  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.authors          = 'Capillary, Inc.'
  s.source           = { :git => 'https://github.com/spreedly/checkout-ios-package', :tag => s.version }
  s.ios.deployment_target = '16.0'
  s.swift_version    = '5.10'

  s.dependency 'SpreedlyCore'
  # PPRiskMagnes became a dynamic framework in braintree_ios 7.11.0 and moved to the shared
  # paypal-risk-ios package. Mirrors Braintree's own change, where the DataCollector subspec
  # now depends on the PayPalRisk pod instead of a locally vendored xcframework.
  s.dependency 'PayPalRisk'

  s.vendored_frameworks = 'Frameworks/SpreedlyBraintree.xcframework'
end
