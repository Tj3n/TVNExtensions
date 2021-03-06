
- **Automatically increase Build number run script:**
```bash
buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${INFOPLIST_FILE}")
buildNumber=$(($buildNumber + 1))
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "${INFOPLIST_FILE}"
```

- **Project path**: `$(SRCROOT)`
- **Project name**: `$(PROJECT_NAME)`
- **Swift module name**: `$(SWIFT_MODULE_NAME)`
- **[Path list](https://gist.github.com/gdavis/6670468)**
- **Check path**:
```
//Project
xcodebuild -project yourProject.xcodeproj -target yourTarget -showBuildSettings | grep PROJECT_DIR
//Workspace
xcodebuild -workspace yourWorkspace.xcworkspace -scheme yourScheme -showBuildSettings | grep PROJECT_DIR
```

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

- **Remove folder from git with .gitignore:**
    - Step 1. Add the folder path to your repo's root .gitignore file: `path_to_your_folder/`
    - Step 2. Remove the folder from your local git tracking, but keep it on your disk: `git rm -r --cached path_to_your_folder/`
    - Step 3. Push your changes to your git repo.

- **Travis CI with Pods:**
    - Make sure to use `xcode_workspace:`
    - Products > Scheme > Manage Schemes
    - Make sure project scheme is Shared
    - Edit project scheme
    - Press +, add all pods frameworks scheme inside
    - Move all pods scheme to top, Pods-Project schemes middle, Project schemes bottom

- **Log viewController name symbolic breakpoint:**
    - Symbol: `-[UIViewController dealloc]`
    - Action - Log message: `--- Dealloc @(id)[$arg1 description]@ @(id)[$arg1 title]@`

- **New Configuration:**
    - Select main PROJECT target > Info > Configuration > Add copy of Debug & Release > Change name if needed (Prod Debug,..)
    - Change bundle id (separated app when build): Select app target in TARGETS > Build Settings > Product Bundle Identifier > Change for the selected config
    - Change app name: Select app target in TARGETS > Build Settings > Product Name > Change for the selected config
    - Swift custom flags:  Select app target in TARGETS > Build Settings > Active Compilation Conditions > Add flag
    - Have to add similar configuration to sub-project too
    - Manage scheme > Add new scheme > Change name > Edit scheme > Change Build Configuration for all step
    - Rerun `pod install`
    
- **Simulation track:**
    - Create `.gpx` track via [http://www.bikehike.co.uk](http://www.bikehike.co.uk).
    - Replace regex: `\s+<trkpt\s(.+)\n.+\n\s+(.+)\n.+` to `\n<wpt $1$2</wpt>`
    - Change the rest to 
    ```
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx>
            <wpt>
            ...
        </gpx>
    ```
