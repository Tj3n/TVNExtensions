Pod::Spec.new do |s|

  s.name         = "TlvParser"
  s.version      = "0.0.1"
  s.summary      = "Swift TlvParser"
  s.description  = "Swift EMV TLV Parser for iOS"

  s.homepage     = "https://github.com/Tj3n"
  s.license      = "MIT"
  s.author       = { "tien.vu" => "tien@paymentwall.com" }
  s.platform     = :ios, "8.0"
  #s.source       = { :git => ".", :tag => String(s.version) }
  s.source       = { :git => "https://github.com/Tj3n/TVNExtensions.git", :branch => "master" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source_files  = "TlvParser"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.requires_arc = true
  s.frameworks = "Foundation"
  
end
