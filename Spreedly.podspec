Pod::Spec.new do |spec|
  spec.name         = "Spreedly"
  spec.version      = "0.0.1"
  spec.summary      = "Spreedly iOS SDK - Complete payment processing solution"
  spec.description  = <<-DESC
    Spreedly iOS SDK provides a comprehensive payment processing solution with modular architecture.
    Includes Core functionality, Analytics, Network layer, Security features, and UI components.
    This package contains pre-built binary frameworks for easy integration.
  DESC
  
  spec.homepage     = "https://github.com/spreedly/checkout-ios-package"
  # TO-DO: Get the license information and update
  # spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Spreedly" => "support@spreedly.com" }
  spec.platform     = :ios, "13.0"
  spec.source       = { :git => "https://github.com/spreedly/checkout-ios-package.git", :tag => "#{spec.version}" }
  
  spec.swift_version = "6.1"
  
  # Main spec - includes all subspecs
  spec.default_subspec = "Core"
  
  # Core subspec
  spec.subspec "Core" do |core|
    core.vendored_frameworks = "Frameworks/SpreedlyCore.framework"
    core.frameworks = "Foundation"
  end
  

  
  # Security subspec
  spec.subspec "Security" do |security|
    security.vendored_frameworks = "Frameworks/SpreedlySecurity.framework"
    security.frameworks = "Foundation", "Security"
    security.dependency "Spreedly/Core"
  end
  
  # UI subspec
  spec.subspec "UI" do |ui|
    ui.vendored_frameworks = "Frameworks/SpreedlyUI.framework"
    ui.frameworks = "Foundation", "UIKit"
    ui.dependency "Spreedly/Core"
  end
  
  # All-inclusive subspec
  spec.subspec "Full" do |full|
    full.dependency "Spreedly/Core"
    full.dependency "Spreedly/Security"
    full.dependency "Spreedly/UI"
  end
end 