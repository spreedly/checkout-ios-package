Pod::Spec.new do |s|
  s.name             = 'SpreedlyApplePay'
  s.version          = '1.7.0-dev.20261030.2'
  s.summary          = 'SpreedlyApplePay module for the Spreedly iOS SDK.'
  s.homepage         = 'https://github.com/spreedly/checkout-ios-package'
  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.authors          = 'Capillary, Inc.'
  s.source           = { :git => 'https://github.com/spreedly/checkout-ios-package', :tag => s.version }
  s.ios.deployment_target = '16.0'
  s.swift_version    = '5.10'

  s.dependency 'SpreedlyCore'
  s.dependency 'SpreedlySecurity'
  s.dependency 'SpreedlyUI'

  s.vendored_frameworks = 'Frameworks/SpreedlyApplePay.xcframework'
end
