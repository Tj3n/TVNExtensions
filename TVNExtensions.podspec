Pod::Spec.new do |s|

  s.name         = "TVNExtensions"
  s.version      = "0.0.1"
  s.summary      = "Swift extensions"
  s.description  = "Swift extensions"

  s.homepage     = "http://EXAMPLE/TVNExtensions"
  s.license      = "MIT"
  s.author       = { "tien.vu" => "tien@paymentwall.com" }
  s.platform     = :ios, "8.0"
  #s.source       = { :git => ".", :tag => String(s.version) }
  s.source       = { :git => "https://github.com/Tj3n/TVNExtensions", :branch => "master" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  #s.source_files  = "Source"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.requires_arc = true

  s.frameworks = "UIKit", "Foundation"

  s.subspec 'Foundation' do |sp|
    sp.source_files = "Foundation"
  end

  s.subspec 'UIKit' do |sp|
    sp.source_files = "UIKit"
  end

  s.subspec 'Helper' do |sp|
    sp.source_files = "Helper"
  end
end
