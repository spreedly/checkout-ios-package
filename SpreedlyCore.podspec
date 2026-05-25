Pod::Spec.new do |s|
  s.name             = 'SpreedlyCore'
  s.version          = '1.4.0-rc.5'
  s.summary          = 'SpreedlyCore is the core framework of the Spreedly SDK.'
  s.homepage         = 'https://github.com/spreedly/checkout-ios-package'
  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.authors          = 'Capillary, Inc.'
  s.source           = { :git => 'https://github.com/spreedly/checkout-ios-package', :tag => s.version }
  s.ios.deployment_target = '14.0'
  s.swift_version    = '5.10'

  s.vendored_frameworks = 'Frameworks/SpreedlyCore.xcframework'
end
