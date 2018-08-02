//
//  UIDeviceExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 7/11/16.
//  Copyright © 2016 Paymentwall. All rights reserved.
//

import Foundation

extension UIDevice {
    public var modelIdentifier: String {
//        var systemInfo = utsname()
//        uname(&systemInfo)
//        let machineMirror = Mirror(reflecting: systemInfo.machine)
//        let identifier = machineMirror.children.reduce("") { identifier, element in
//            guard let value = element.value as? Int8 , value != 0 else { return identifier }
//            return identifier + String(UnicodeScalar(UInt8(value)))
//        }
//        return identifier
        
        var sysinfo = utsname()
        uname(&sysinfo)
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }
    
    public var modelName: String {
        let identifier = self.modelIdentifier
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
    public var isSimulator: Bool {
        #if arch(i386) || arch(x86_64)
            return true
        #else
            return false
        #endif
    }
    
    public var isIPhone: Bool {
        return self.userInterfaceIdiom == .phone
    }
    
    public var deviceVersion: Double? {
        return Double(systemVersion)
    }
    
    /// Check if device is newer than iPhone 7/7+ or not
    public var hasHapticFeedback: Bool {
        guard isIPhone else { return false }
        let i = modelIdentifier.removeCharacters(from: CharacterSet.letters.union(.punctuationCharacters))
        let compareResult = i.compare("90", options: .numeric)
        return compareResult != .orderedDescending
    }
    
    public enum ScreenType: String {
        case iPhone4
        case iPhone5
        case iPhone6
        case iPhone6Plus
        case iPhoneX
        case Unknown
    }
    
    public var screenType: ScreenType? {
        guard isIPhone else { return nil }
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhone4
        case 1136:
            return .iPhone5
        case 1334:
            return .iPhone6
        case 2208:
            return .iPhone6Plus
        case 2436:
            return .iPhoneX
        default:
            return nil
        }
    }
    
    //Check device version
    public class func compareSystemVersion(to version: String) -> SystemVersionComparisonResult {
        let compareResult = self.current.systemVersion.compare(version, options: .numeric)
        
        if compareResult == .orderedSame {
            return .equal
        } else if compareResult == .orderedDescending {
            return .greater
        } else if compareResult == .orderedAscending {
            return .less
        }
        
        return .none
    }
}

public enum SystemVersionComparisonResult {
    case equal
    case greater
    case less
    case none
}
