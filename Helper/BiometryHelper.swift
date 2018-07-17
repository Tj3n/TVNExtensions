//
//  LocalAuthHelper.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 11/13/17.
//

import Foundation
import LocalAuthentication

public enum BiometryCommonError: Error, LocalizedError {
    case cancel(message: String),
    notAvailable(message: String),
    modified,
    other(error: NSError)
    
    public var errorDescription: String? {
        switch self {
        case .cancel(let message):
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
public enum BiometryType {
    case touchID
    case faceID
    case undetermined
    case none
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
        
        if #available(iOS 11.2, *) {
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                if context.biometryType == .faceID {
                    return .faceID
                } else if context.biometryType == .touchID {
                    return .touchID
                } else if context.biometryType != .none {
                    return .undetermined
                } else {
                    return .none
                }
            }
        } else if #available(iOS 11.0, *) {
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                if context.biometryType == .faceID {
                    return .faceID
                } else if context.biometryType == .touchID {
                    return .touchID
                } else {
                    return .undetermined
                }
            }
        } else {
            return .undetermined
        }
        
        return .none
    }
    
    public static func authenticateUser(with reasonStr: String?, completion:@escaping ((_ error: BiometryCommonError?)->())) {
        let reason = reasonStr ?? "Authentication is needed to access."
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success, bioError) in
                if success {
                    if self.checkForModified(context: context) {
                        DispatchQueue.main.async {
                            completion(.modified)
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                } else if let bioError = bioError {
                    let err = bioError as NSError
                    var commonError: BiometryCommonError?
                    switch err.code {
                    case LAError.systemCancel.rawValue:
                        commonError = .cancel(message: "Authentication was cancelled by the system")
                    case LAError.userCancel.rawValue:
                        commonError = .cancel(message: "Authentication was cancelled by the user")
                    case LAError.userFallback.rawValue:
                        commonError = .cancel(message: "User selected to enter custom password")
                    default:
                        commonError = .other(error: err)
                    }
                    DispatchQueue.main.async {
                        completion(commonError)
                    }
                }
            })
        } else if let error = error {
            if #available(iOS 11.0, *) {
                var commonError: BiometryCommonError?
                switch error.code {
                case LAError.biometryNotEnrolled.rawValue:
                    commonError = .notAvailable(message: "Biometry is not enrolled")
                case LAError.passcodeNotSet.rawValue:
                    commonError = .notAvailable(message: "A passcode has not been set")
                default:
                    commonError = .notAvailable(message: "Biometry not available")
                }
                DispatchQueue.main.async {
                    completion(commonError)
                }
            } else {
                var commonError: BiometryCommonError?
                switch error.code {
                case LAError.touchIDNotEnrolled.rawValue:
                    commonError = .notAvailable(message: "TouchID is not enrolled")
                case LAError.passcodeNotSet.rawValue:
                    commonError = .notAvailable(message: "A passcode has not been set")
                default:
                    commonError = .notAvailable(message: "TouchID not available")
                }
                DispatchQueue.main.async {
                    completion(commonError)
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
