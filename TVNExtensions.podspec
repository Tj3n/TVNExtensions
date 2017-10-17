Pod::Spec.new do |s|

  s.name         = "TVNExtensions"
  s.version      = "0.0.1"
  s.summary      = "Swift extensions"
  s.description  = "Swift extensions"

  s.homepage     = "http://EXAMPLE/TVNExtensions"
  s.license      = "MIT"
  s.author       = { "tien.vu" => "tien@paymentwall.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "/Users/nhat.tien/Documents/Code/TVNExtensions", :tag => String(s.version) }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source_files  = "Source"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.requires_arc = true

  s.frameworks = "UIKit", "Foundation"
end
