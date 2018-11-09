Pod::Spec.new do |s|

  s.name         = "TVNExtensions"
  s.version      = "0.0.1"
  s.summary      = "Swift extensions"
  s.description  = "Swift extensions for iOS"

  s.homepage     = "https://github.com/Tj3n"
  s.license      = "MIT"
  s.author       = { "tien.vu" => "tien@paymentwall.com" }
  s.platform     = :ios, "8.0"
  #s.source       = { :git => ".", :tag => String(s.version) }
  s.source       = { :git => "https://github.com/Tj3n/TVNExtensions.git", :branch => "master" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  #s.source_files  = "Source"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.requires_arc = true

  s.frameworks = "UIKit", "Foundation", "CoreTelephony", "CoreLocation", "AVFoundation" , "LocalAuthentication"
  s.default_subspec = 'Lite'

  s.subspec 'Foundation' do |sp|
    sp.source_files = "Foundation"
  end

  s.subspec 'UIKit' do |sp|
    sp.source_files = "UIKit"
  end

  s.subspec 'Helper' do |sp|
    sp.source_files = "Helper"
    sp.dependency 'TVNExtensions/UIKit'
  end

  s.subspec 'Lite' do |lite|
    # Default subspec don't include Kingfisher
    lite.dependency 'TVNExtensions/Helper'
    lite.dependency 'TVNExtensions/UIKit'
    lite.dependency 'TVNExtensions/Foundation'
  end

  s.subspec 'Kingfisher' do |kingfisher|
    kingfisher.dependency 'Kingfisher'
  end

  s.xcconfig = {
    'SWIFT_INCLUDE_PATHS[sdk=macosx*]'           => '$(PODS_TARGET_SRCROOT)/CCommonCrypto/macosx $(PODS_ROOT)/TVNExtensions/CCommonCrypto/macosx',
    'SWIFT_INCLUDE_PATHS[sdk=iphoneos*]'         => '$(PODS_TARGET_SRCROOT)/CCommonCrypto/iphoneos $(PODS_ROOT)/TVNExtensions/CCommonCrypto/iphoneos',
    'SWIFT_INCLUDE_PATHS[sdk=iphonesimulator*]'  => '$(PODS_TARGET_SRCROOT)/CCommonCrypto/iphonesimulator $(PODS_ROOT)/TVNExtensions/CCommonCrypto/iphonesimulator',
    'SWIFT_INCLUDE_PATHS[sdk=appletvos*]'        => '$(PODS_TARGET_SRCROOT)/CCommonCrypto/appletvos $(PODS_ROOT)/TVNExtensions/CCommonCrypto/appletvos',
    'SWIFT_INCLUDE_PATHS[sdk=appletvsimulator*]' => '$(PODS_TARGET_SRCROOT)/CCommonCrypto/appletvsimulator $(PODS_ROOT)/TVNExtensions/CCommonCrypto/appletvsimulator',
    'SWIFT_INCLUDE_PATHS[sdk=watchos*]'          => '$(PODS_TARGET_SRCROOT)/CCommonCrypto/watchos $(PODS_ROOT)/TVNExtensions/CCommonCrypto/watchos',
    'SWIFT_INCLUDE_PATHS[sdk=watchsimulator*]'   => '$(PODS_TARGET_SRCROOT)/CCommonCrypto/watchsimulator $(PODS_ROOT)/TVNExtensions/CCommonCrypto/watchsimulator',
  }
  s.preserve_paths = 'CCommonCrypto/**/*'
end
