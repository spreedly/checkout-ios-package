Pod::Spec.new do |s|
  s.name             = 'SpreedlyUI'
  s.version          = '1.6.0-rc.1'
  s.summary          = 'SpreedlyUI is the ui framework of the Spreedly SDK.'
  s.homepage         = 'https://github.com/spreedly/checkout-ios-package'
  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.authors          = 'Capillary, Inc.'
  s.source           = { :git => 'https://github.com/spreedly/checkout-ios-package', :tag => s.version }
  s.ios.deployment_target = '14.0'
  s.swift_version    = '5.10'

  s.vendored_frameworks = 'Frameworks/SpreedlyUI.xcframework'

  s.dependency 'SpreedlyCore'
  s.dependency 'SpreedlySecurity'
end
