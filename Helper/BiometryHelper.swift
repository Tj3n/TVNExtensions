//
//  LocalAuthHelper.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 11/13/17.
//

import Foundation
import LocalAuthentication

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
            return "Authentication was cancelled by the system"
        case .userCancel(let message):
            return message
        case .notAvailable(let message):
            return message
        case .modified:
            return "Biometric has been modified"
        case .other(let error):
            return error.localizedDescription
        }
    }
}

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

public struct BiometryHelper {
    public static var isBiometryAvailable: Bool {
        get {
            return biometryAvailableType() != .none
        }
    }
    
    public static func biometryAvailableType() -> BiometryType {
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
    
    public static func authenticateUser(with reasonStr: String?, completion:@escaping ((_ success: Bool, _ error: BiometryCommonError?)->())) {
        let reason = reasonStr ?? "Authentication is needed to access."
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success, bioError) in
                if success {
                    if self.checkForModified(context: context) {
                        DispatchQueue.main.async {
                            completion(false, .modified)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(success, nil)
                        }
                    }
                } else if let bioError = bioError {
                    var commonError: BiometryCommonError?
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
                        completion(success, commonError)
                    }
                }
            })
        } else if let error = error {
            if #available(iOS 11.0, *) {
                var commonError: BiometryCommonError?
                switch error.code {
                case LAError.biometryNotEnrolled.rawValue:
                    commonError = .notAvailable(message: LAError.biometryNotEnrolled.localizedDescription)
                case LAError.passcodeNotSet.rawValue:
                    commonError = .notAvailable(message: LAError.passcodeNotSet.localizedDescription)
                default:
                    commonError = .notAvailable(message: "Biometry is not available")
                }
                DispatchQueue.main.async {
                    completion(false, commonError)
                }
            } else {
                var commonError: BiometryCommonError?
                switch error.code {
                case LAError.touchIDNotEnrolled.rawValue:
                    commonError = .notAvailable(message: LAError.touchIDNotEnrolled.localizedDescription)
                case LAError.passcodeNotSet.rawValue:
                    commonError = .notAvailable(message: LAError.passcodeNotSet.localizedDescription)
                default:
                    commonError = .notAvailable(message: "TouchID is not available")
                }
                DispatchQueue.main.async {
                    completion(false, commonError)
                }
            }
        }
    }
    
    private static func checkForModified(context: LAContext) -> Bool {
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