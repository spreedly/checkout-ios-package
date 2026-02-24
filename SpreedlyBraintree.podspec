Pod::Spec.new do |s|
  s.name             = 'SpreedlyBraintree'
  s.version          = '1.0.23'
  s.summary          = 'Braintree (PayPal/Venmo) module for the Spreedly iOS SDK.'
  s.homepage         = 'https://github.com/spreedly/checkout-ios-package'
  s.license          = { :type => 'Proprietary', :text => 'Licensed for internal use only.' }
  s.authors          = 'Capillary, Inc.'
  s.source           = { :git => 'https://github.com/spreedly/checkout-ios-package', :tag => s.version }
  s.ios.deployment_target = '13.0'
  s.swift_version    = '5.10'

  s.dependency 'SpreedlyCore'
  s.dependency 'BraintreeCore', '~> 7.0'
  s.dependency 'BraintreePayPal', '~> 7.0'
  s.dependency 'BraintreeVenmo', '~> 7.0'
  s.dependency 'BraintreeDataCollector', '~> 7.0'

  s.vendored_frameworks = 'Frameworks/SpreedlyBraintree.xcframework'
end
