//
//  LocalAuthHelper.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 11/13/17.
//

import Foundation
import LocalAuthentication

public enum LocalAuthError: Error {
    case cancel(message: String),
    notAvailable(message: String),
    modified,
    other(error: NSError)
}

public struct LocalAuth {
    public static func authenticateUser(with reasonStr: String?, completion:((_ error: LocalAuthError?)->())!) {
        let reason = reasonStr ?? "Authentication is needed to access."
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success, bioError) in
                if success {
                    if self.checkForModified(context: context) {
                        completion(.modified)
                    } else {
                        completion(nil)
                    }
                } else if let bioError = bioError {
                    let err = bioError as NSError
                    switch err.code {
                    case LAError.systemCancel.rawValue:
                        completion(.cancel(message: "Authentication was cancelled by the system"))
                    case LAError.userCancel.rawValue:
                        completion(.cancel(message: "Authentication was cancelled by the user"))
                    case LAError.userFallback.rawValue:
                        completion(.cancel(message: "User selected to enter custom password"))
                    default:
                        completion(.other(error: err))
                    }
                    print(err.localizedDescription)
                }
            })
        } else if let error = error {
            if #available(iOS 11.0, *) {
                switch error.code {
                case LAError.biometryNotEnrolled.rawValue:
                    completion(.notAvailable(message: "Biometry is not enrolled"))
                case LAError.passcodeNotSet.rawValue:
                    completion(.notAvailable(message: "A passcode has not been set"))
                default:
                    completion(.notAvailable(message: "Biometry not available"))
                }
            } else {
                switch error.code {
                case LAError.touchIDNotEnrolled.rawValue:
                    completion(.notAvailable(message: "TouchID is not enrolled"))
                case LAError.passcodeNotSet.rawValue:
                    completion(.notAvailable(message: "A passcode has not been set"))
                default:
                    completion(.notAvailable(message: "TouchID not available"))
                }
            }
            print(error.localizedDescription)
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
