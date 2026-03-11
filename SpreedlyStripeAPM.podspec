Pod::Spec.new do |s|
  s.name             = 'SpreedlyStripeAPM'
  s.version          = '1.1.5'
  s.summary          = 'Stripe APM module for the Spreedly iOS SDK.'
  s.homepage         = 'https://github.com/spreedly/checkout-ios-package'
  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.authors          = 'Capillary, Inc.'
  s.source           = { :git => 'https://github.com/spreedly/checkout-ios-package', :tag => s.version }
  s.ios.deployment_target = '14.0'
  s.swift_version    = '5.10'

  s.dependency 'SpreedlyCore'
  s.dependency 'StripePaymentSheet', '~> 25.0'

  s.vendored_frameworks = 'Frameworks/SpreedlyStripeAPM.xcframework'
end
