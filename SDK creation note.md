## Creating static lib:
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

## Creating dynamic framework:
1. Build settings -> Skip Install -> No
2. Edit scheme -> Archive -> Post-actions
3. Add Run script, archive to produce framework:
```bash
#Fat framework archiving
#https://gist.github.com/eladnava/0824d08da8f99419ef2c7b7fb6d4cc78
exec > /tmp/${PROJECT_NAME}_archive.log 2>&1

UNIVERSAL_OUTPUTFOLDER=${BUILD_DIR}/${CONFIGURATION}-universal

if [ "true" == ${ALREADYINVOKED:-false} ]
then
echo "RECURSION: Detected, stopping"
else
export ALREADYINVOKED="true"

# make sure the output directory exists
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"

echo "Building for iPhoneSimulator"
xcodebuild -workspace "${WORKSPACE_PATH}" -scheme "${TARGET_NAME}" -configuration ${CONFIGURATION} -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 6' ONLY_ACTIVE_ARCH=NO ARCHS='i386 x86_64' BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" ENABLE_BITCODE=YES OTHER_CFLAGS="-fembed-bitcode" BITCODE_GENERATION_MODE=bitcode clean build

# Step 1. Copy the framework structure (from iphoneos build) to the universal folder
echo "Copying to output folder"
cp -R "${ARCHIVE_PRODUCTS_PATH}/${INSTALL_PATH}/" "${UNIVERSAL_OUTPUTFOLDER}/"

# Step 2. Copy Swift modules from iphonesimulator build (if it exists) to the copied framework directory
SIMULATOR_SWIFT_MODULES_DIR="${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${TARGET_NAME}.framework/Modules/${TARGET_NAME}.swiftmodule/."
if [ -d "${SIMULATOR_SWIFT_MODULES_DIR}" ]; then
cp -R "${SIMULATOR_SWIFT_MODULES_DIR}" "${UNIVERSAL_OUTPUTFOLDER}/${TARGET_NAME}.framework/Modules/${TARGET_NAME}.swiftmodule"
fi

# Step 3. Create universal binary file using lipo and place the combined executable in the copied framework directory
echo "Combining executables"
lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/${EXECUTABLE_PATH}" "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${EXECUTABLE_PATH}" "${ARCHIVE_PRODUCTS_PATH}${INSTALL_PATH}/${EXECUTABLE_PATH}"

echo "Framework location: ${ARCHIVE_PRODUCTS_PATH}/${INSTALL_PATH}/"
# Step 4. Create universal binaries for embedded frameworks
#for SUB_FRAMEWORK in $( ls "${UNIVERSAL_OUTPUTFOLDER}/${TARGET_NAME}.framework/Frameworks" ); do
#BINARY_NAME="${SUB_FRAMEWORK%.*}"
#lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/${TARGET_NAME}.framework/Frameworks/${SUB_FRAMEWORK}/${BINARY_NAME}" "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${SUB_FRAMEWORK}/${BINARY_NAME}" "${ARCHIVE_PRODUCTS_PATH}${INSTALL_PATH}/${TARGET_NAME}.framework/Frameworks/${SUB_FRAMEWORK}/${BINARY_NAME}"
#done

# Step 5. Convenience step to copy the framework to the project's directory
echo "Copying to project dir"
mkdir -p "${PROJECT_DIR}/Output"
yes | cp -Rf "${UNIVERSAL_OUTPUTFOLDER}/${FULL_PRODUCT_NAME}" "${PROJECT_DIR}/Output"

open "${PROJECT_DIR}/Output"

fi
```

## Check arch:
```bash
xcrun -sdk iphoneos lipo -info $(FILENAME)
//or
lipo -info myFramework.framework/MyFramework
//or
file lib.a
```

## Support `armv7s`
- Add `armv7s` under `$(ARCHS_STANDARD)` in Build settings - Architectures 

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
