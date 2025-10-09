Pod::Spec.new do |s|
  s.name             = 'SpreedlyCore'
  s.version          = '0.0.29'
  s.summary          = 'SpreedlyCore is the core framework of the Spreedly SDK.'
  s.homepage         = 'https://github.com/Capillary/hydra-sdk-ios-packages'
  s.license          = { :type => 'Proprietary', :text => 'Licensed for internal use only.' }
  s.authors          = 'Capillary, Inc.'
  s.source           = { :git => 'https://github.com/spreedly/checkout-ios-package', :tag => s.version }
  s.ios.deployment_target = '13.0'
  s.swift_version    = '5.10'

  s.dependency 'DatadogSDK', '~> 3.1.0'

  s.vendored_frameworks = 'Frameworks/SpreedlyCore.xcframework'
end
