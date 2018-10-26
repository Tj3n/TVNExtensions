
- **Automatically increase Build number run script:**
```bash
buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${PROJECT_DIR}/${INFOPLIST_FILE}")
buildNumber=$(($buildNumber + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "${PROJECT_DIR}/${INFOPLIST_FILE}"
```

- **Project path**: `$(SRCROOT)`
- **Project name**: `$(PROJECT_NAME)`
- **Swift module name**: `$(SWIFT_MODULE_NAME)`
- **Open new terminal/terminal tab of active XCode project:**
```
#Add to XCode behaviors
osascript <<EOD
tell application "Xcode"
	set currentWorkspacePath to path of active workspace document
end tell

if application "Terminal" is running then 
    tell application "Terminal"
    	activate
		delay 0.5
        tell application "System Events" to keystroke "t" using {command down}    
        do script "cd " & currentWorkspacePath & "/.." in front window                           
    end tell                              
else                                      
    tell application "Terminal"
    	do script "cd " & currentWorkspacePath & "/.." in front window
        activate
    end tell
end if
EOD
```
