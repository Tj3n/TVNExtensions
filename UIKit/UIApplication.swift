//
//  UIApplication.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 5/23/18.
//

import Foundation

extension UIApplication {
    public class func isAppUpdated() -> Bool {
        if let oldAppVersion = UserDefaults.standard.value(forKey: "AppVersion") as? String {
            let isUpdated = Double(oldAppVersion)! < Double(appVersion())! ? true : false
            if isUpdated { saveAppVersion() }
            return isUpdated
        } else {
            saveAppVersion()
            return true
        }
    }
    
    private class func saveAppVersion() {
        UserDefaults.standard.setValue(appVersion(), forKey:"AppVersion")
        UserDefaults.standard.synchronize()
    }
    
    public class func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    public class func appBuild() -> String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
    
    public class func buildNumber() -> Int {
        return Int(appBuild()) ?? 0
    }
    
    public class func versionBuild() -> String {
        let version = appVersion(), build = appBuild()
        
        return version == build ? "v\(version)" : "v\(version)(\(build))"
    }
}
