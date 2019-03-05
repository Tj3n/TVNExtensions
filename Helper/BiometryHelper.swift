//
//  LocalAuthHelper.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 11/13/17.
//

import Foundation
import LocalAuthentication

/// BiometryType
///
/// - touchID: Touch ID is available, only from iOS 11
/// - faceID: Face ID is available, only from iOS 11
/// - undetermined: Undetermied available biometric, should be .touchID, happened because iOS lower than 11 or new feature
/// - none: Biometric has not been set, can have passcode set though
public enum BiometryType: String {
    case touchID = "Touch ID"
    case faceID = "Face ID"
    case undetermined = "Biometric"
    case none = " Biometric"
}

/// Notification for Biometric check, for Failed case, can get error from `userInfo` with key == "error"
public let BiometricEvaluateSuccessfulNotificationName = NSNotification.Name("BiometricEvaluateSuccessfulNotificationName")
public let BiometricEvaluateFailedNotificationName = NSNotification.Name("BiometricEvaluateFailedNotificationName")
public let BiometricEvaluateCompletedNotificationName = NSNotification.Name("BiometricEvaluateCompletedNotificationName")

/**
 Note:
 To use in AppDelegate:
 Create `var applicationWillEnterForeground = false`
 In `func applicationWillEnterForeground(_ :)` change `applicationWillEnterForeground = true`
 In `func applicationDidBecomeActive(_ :)` check for biometric if `applicationWillEnterForeground = true` and set it to false
 **/
public class BiometryHelper {
    public static var isRequestingBiometric: Bool = false
    public static var isBiometryAvailable: Bool {
        get { return biometryAvailableType() != .none }
    }
    public static var timeIntervalSinceLastAuth: TimeInterval {
        return Date().timeIntervalSince(lastAuthDate)
    }
    public static var timeIntervalSinceLastSuccessfulAuth: TimeInterval  {
        return Date().timeIntervalSince(lastSuccessfulAuthDate)
    }
    
    static let lastAuthDateKey = "lastAuthDateKey"
    static var lastAuthDate: Date {
        get {
            let lastAuthTimeInterval = UserDefaults.standard.double(forKey: lastAuthDateKey)
            return lastAuthTimeInterval == 0 ? Date() : Date(timeIntervalSince1970: lastAuthTimeInterval)
        }
        set {
            UserDefaults.standard.set(newValue.timeIntervalSince1970, forKey: lastAuthDateKey)
        }
    }
    
    static let lastSuccessfulAuthDateKey = "lastSuccessfulAuthDateKey"
    static var lastSuccessfulAuthDate: Date {
        get {
            let lastAuthTimeInterval = UserDefaults.standard.double(forKey: lastSuccessfulAuthDateKey)
            return lastAuthTimeInterval == 0 ? Date() : Date(timeIntervalSince1970: lastAuthTimeInterval)
        }
        set {
            UserDefaults.standard.set(newValue.timeIntervalSince1970, forKey: lastSuccessfulAuthDateKey)
        }
    }
    
    public class func biometryAvailableType() -> BiometryType {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            if #available(iOS 11.2, *) {
                if context.biometryType == .faceID {
                    return .faceID
                } else if context.biometryType == .touchID {
                    return .touchID
                } else if context.biometryType != .none {
                    return .undetermined
                } else {
                    return .none
                }
            } else if #available(iOS 11.0, *) {
                if context.biometryType == .faceID {
                    return .faceID
                } else if context.biometryType == .touchID {
                    return .touchID
                } else if context.biometryType != LABiometryType.LABiometryNone {
                    return .undetermined
                } else {
                    return .none
                }
            } else {
                return .undetermined
            }
        }
        
        return .none
    }
    
    public class func authenticateUser(with reasonStr: String?, completion:@escaping ((_ success: Bool, _ error: BiometryCommonError?)->())) {
        let reason = reasonStr ?? "Authentication is needed to access."
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            isRequestingBiometric = true
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success, bioError) in
                isRequestingBiometric = false
                lastAuthDate = Date()
                NotificationCenter.default.post(name: BiometricEvaluateCompletedNotificationName, object: nil)
                if success {
                    if self.checkForModified(context: context) {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: BiometricEvaluateFailedNotificationName, object: nil, userInfo: ["error": BiometryCommonError.modified])
                            completion(false, .modified)
                        }
                    } else {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: BiometricEvaluateSuccessfulNotificationName, object: nil)
                            lastSuccessfulAuthDate = Date()
                            completion(success, nil)
                        }
                    }
                } else if let bioError = bioError {
                    var commonError: BiometryCommonError
                    switch bioError {
                    case LAError.systemCancel:
                        commonError = .systemCancel
                    case LAError.userCancel:
                        commonError = .userCancel(message: LAError.userCancel.localizedDescription)
                    case LAError.userFallback:
                        commonError = .userCancel(message: LAError.userFallback.localizedDescription)
                    default:
                        commonError = .other(error: bioError)
                    }
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: BiometricEvaluateFailedNotificationName, object: nil, userInfo: ["error": commonError])
                        completion(success, commonError)
                    }
                }
            })
        } else if let error = error {
            isRequestingBiometric = false
            lastAuthDate = Date()
            NotificationCenter.default.post(name: BiometricEvaluateCompletedNotificationName, object: nil)
            if #available(iOS 11.0, *) {
                var commonError: BiometryCommonError
                switch error.code {
                case LAError.biometryNotEnrolled.rawValue:
                    commonError = .notAvailable(message: LAError.biometryNotEnrolled.localizedDescription)
                case LAError.passcodeNotSet.rawValue:
                    commonError = .notAvailable(message: LAError.passcodeNotSet.localizedDescription)
                default:
                    commonError = .notAvailable(message: "Biometry is not available")
                }
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: BiometricEvaluateFailedNotificationName, object: nil, userInfo: ["error": commonError])
                    completion(false, commonError)
                }
            } else {
                var commonError: BiometryCommonError
                switch error.code {
                case LAError.touchIDNotEnrolled.rawValue:
                    commonError = .notAvailable(message: LAError.touchIDNotEnrolled.localizedDescription)
                case LAError.passcodeNotSet.rawValue:
                    commonError = .notAvailable(message: LAError.passcodeNotSet.localizedDescription)
                default:
                    commonError = .notAvailable(message: "TouchID is not available")
                }
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: BiometricEvaluateFailedNotificationName, object: nil, userInfo: ["error": commonError])
                    completion(false, commonError)
                }
            }
        }
    }
    
    private class func checkForModified(context: LAContext) -> Bool {
        let k = "TVN_DS_CHECK"
        guard let oldDomainState = KeychainWrapper.standard.data(forKey: k) else { return false }
        if #available(iOS 9.0, *) {
            if let domainState = context.evaluatedPolicyDomainState {
                if domainState == oldDomainState {
                    return false
                } else {
                    KeychainWrapper.standard.set(domainState, forKey: k)
                    return true
                }
            } else {
                return true
            }
        }
        
        return false
    }
}

extension LAError.Code: Error, LocalizedError {
    public var errorDescription: String? {
        if #available(iOS 11.0, *) {
            switch self {
            case .biometryNotAvailable:
                return "Biometry not available"
            case .biometryNotEnrolled:
                return "Biometry is not enrolled"
            default:
                break
            }
        } else {
            switch self {
            case .touchIDNotAvailable:
                return "TouchID not available"
            case .touchIDNotEnrolled:
                return "TouchID is not enrolled"
            default:
                break
            }
        }
        
        switch self {
        case .systemCancel:
            return "Authentication was cancelled by the system"
        case .userCancel:
            return "Authentication was cancelled by the user"
        case .userFallback:
            return "User selected to enter custom password"
        case .passcodeNotSet:
            return "A passcode has not been set"
        default:
            return "Authentication failed"
        }
    }
}

public enum BiometryCommonError: Error, LocalizedError {
    case systemCancel,
    userCancel(message: String),
    notAvailable(message: String),
    modified,
    other(error: Error)
    
    public var errorDescription: String? {
        switch self {
        case .systemCancel:
            return "Authentication was cancelled by the system."
        case .userCancel(let message):
            return message
        case .notAvailable(let message):
            return message
        case .modified:
            return "Biometric has been modified."
        case .other(let error):
            return error.localizedDescription
        }
    }
}
