# TVNExtensions

[![Build Status](https://travis-ci.org/Tj3n/TVNExtensions.svg?branch=master)](https://travis-ci.org/Tj3n/TVNExtensions) [![Build Status](https://app.bitrise.io/app/3a7d4c001cf45fbc/status.svg?token=OXAtX6hOmieUDVVK0qW8Sw&branch=master)](https://app.bitrise.io/app/3a7d4c001cf45fbc)

Install with SPM:
- File > Swift Packages > Add Package Dependency
- Add `https://github.com/Tj3n/TVNExtensions`
- Select branch `master`

Install with Cocoapods `gitpath`:

    pod 'TVNExtensions', :git => "https://github.com/Tj3n/TVNExtensions"
    
- `TLVDecoder` is Swift translated of [SGTLVDecode](https://github.com/saturngod/SGTLVDecode).
- `ParticleIOS` is simplified Swift version of [Particle.js](https://github.com/VincentGarreau/particles.js/).
- [Kingfisher](https://github.com/onevcat/Kingfisher) dependency can be installed by `pod 'TVNExtensions/Kingfisher'`
- `Rx` extentions and dependencies can be installed by `pod 'TVNExtensions/Rx'`

### ParticleView:
![Imgur](https://i.imgur.com/L9ITbQe.gif)

### Info.plist requirements:
- Hard requirement:
    - NSCameraUsageDescription
    - NSPhotoLibraryUsageDescription

- Require if use any:
    - NSFaceIDUsageDescription
