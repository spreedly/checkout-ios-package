Pod::Spec.new do |s|
  s.name             = 'SpreedlyStripeAPM'
  s.version          = '1.4.0-dev.20260609.1'
  s.summary          = 'Stripe APM module for the Spreedly iOS SDK.'
  s.homepage         = 'https://github.com/spreedly/checkout-ios-package'
  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.authors          = 'Capillary, Inc.'
  s.source           = { :git => 'https://github.com/spreedly/checkout-ios-package', :tag => s.version }
  s.ios.deployment_target = '14.0'
  s.swift_version    = '5.10'

  s.dependency 'SpreedlyCore'

  s.vendored_frameworks = 'Frameworks/SpreedlyStripeAPM.xcframework'
  s.preserve_paths = 'scripts/cocoapods_stripe_bundle_patcher.rb'
end
