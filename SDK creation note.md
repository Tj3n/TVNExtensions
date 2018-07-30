##Creating static lib:
1. Create aggregate target
2. Add run script: 
```bash
# workaround for bitcode generation problem with Xcode 7.3
unset TOOLCHAINS

# configure directories for intermediate and final builds
UNIVERSAL_OUTPUTFOLDER=${SRCROOT}/${PROJECT_NAME}-lib

# build device and simulator versions
xcodebuild -target ${PROJECT_NAME} ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk iphoneos  BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}"
xcodebuild -target ${PROJECT_NAME} ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk iphonesimulator BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}"

# make sure the output directory exists
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"

# create universal binary file using lipo
lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/lib${PROJECT_NAME}.a" "${BUILD_DIR}/${CONFIGURATION}-iphoneos/lib${PROJECT_NAME}.a" "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/lib${PROJECT_NAME}.a"

# copy the header files to the final output folder
cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/include" "${UNIVERSAL_OUTPUTFOLDER}/"

# remove the build folder
rm -rf ${SRCROOT}/build
```

3. For bitcode, add `-fembed-bitcode` in custom compiler flags

## Create new Bundle:
1. Build settings: Change `Base SDK` to `Latest iOS`
2. Change `COMBINE_HIDPI_IMAGES` to `NO`
3. Delete `CFBundleExecutable` in `info.plist`
4. Xib n Storyboard localization doesn't work in SDK, use Accessibility Identifier or tag to find the view and replace the text via `Localizable`, have to clean the demo afterward.

## Check arch:
```bash
xcrun -sdk iphoneos lipo -info $(FILENAME)
lipo -info myFramework.framework/MyFramework
file lib.a
```

## Plugin:
- Change `Header Search Paths` to the Main SDK folder

## Demo app:
1. Add SDK project to `Linked Frameworks and Libraries`
2. Add `-ObjC` to `Other linker flags`
3. Build phase: Add all the SDK target to `Target Dependencies`
4. Drag the SDK bundle from the SDK Products folder to `Copy Bundle Resources`

## Cocoapods:
1. `pod spec create ProjectName`
2. Edit the .podspec:
```bash
    s.name         = "ThreeRingControl"
 	s.version      = "1.0.0"
	s.summary      = "A three-ring control like the Activity status bars"
	s.description  = “asdf.”
	s.homepage     = "http://raywenderlich.com" 	s.license      = "MIT"
	s.platform     = :ios, "10.0"
	s.source_files = "ThreeRingControl", "ThreeRingControl/**/*.{h,m,swift}"
	s.resources    = "ThreeRingControl/*.mp3”, “sth.bundle”
```
3. if swift : `s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4' }`
4. Publish:
 - Add
 - Commit
 - Push
 - Tag: git tag tagname
 - Push Tag: git push --tags
 - pod lib lint PWCoreSDK.podspec
 - pod spec lint PWCoreSDK.podspec
 - pod trunk push PWCoreSDK.podspec
5. Delete:
 - git tag --delete tagname
 - git push --delete origin tagname