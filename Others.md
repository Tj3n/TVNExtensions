
- **Automatically increase Build number run script:**
```bash
buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${PROJECT_DIR}/${INFOPLIST_FILE}")
buildNumber=$(($buildNumber + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "${PROJECT_DIR}/${INFOPLIST_FILE}"
```
- **Project path**: `$(SRCROOT)`
- **Project name**: `$(PROJECT_NAME)`
- **Swift module name**: `$(SWIFT_MODULE_NAME)`