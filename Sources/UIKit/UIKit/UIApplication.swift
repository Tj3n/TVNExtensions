//
//  UIApplication.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 5/23/18.
//

import Foundation
import UIKit

extension UIApplication {
    
    public class var keyWindow: UIWindow? {
        return UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .last { $0.isKeyWindow }
    }
    
    /// Check if the app is first run, only activate once calling
    ///
    /// - Returns: Bool
    public class func isNotFirstRun() -> Bool {
        let firstRunKey = (Bundle.main.bundleIdentifier ?? "com.TVNExtension") + ".FirstRun"
        if UserDefaults.standard.bool(forKey: firstRunKey) {
            return true
        }
        
        UserDefaults.standard.set(true, forKey: firstRunKey)
        return false
    }
    
    @available(iOS, deprecated: 10.0)
    public class func requestNotificationRegister(settingTypes: UIUserNotificationType = [.badge, .sound, .alert]) {
        let notificationSettings = UIUserNotificationSettings(types: settingTypes, categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
    }
    
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
    
    public class func appName() -> String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
    }
    
    /// Check if is app downloaded and run from AppStore
    /// - Returns: return `false` when run in debug mode, simulator or testflight
    public class func isProduction() -> Bool {
        #if DEBUG
        return false
        #else
        guard let path = Bundle.main.appStoreReceiptURL?.path else {
            return true
        }
        return !(path.contains("CoreSimulator") || path.contains("sandboxReceipt"))
        #endif
    }
}
