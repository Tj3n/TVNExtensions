Pod::Spec.new do |s|

  s.name         = "ParticleIOS"
  s.version      = "0.0.1"
  s.summary      = "Particle view for iOS"
  s.description  = "Particle view for iOS, based on Particles.js"

  s.homepage     = "https://github.com/Tj3n"
  s.license      = "MIT"
  s.author       = { "tien.vu" => "tienvn3845@gmail.com" }
  s.platform     = :ios, "9.0"
  #s.source       = { :git => ".", :tag => String(s.version) }
  s.source       = { :git => "https://github.com/Tj3n/TVNExtensions.git", :branch => "master" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source_files  = "ParticleIOS"

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.requires_arc = true
  s.frameworks = "Foundation", "UIKit", "SpriteKit"
  s.dependency 'TVNExtensions'
  
end
