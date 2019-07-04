#! /bin/bash
#XCode -> Preference -> Behaviors -> Add Custom behavior -> Run this file

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