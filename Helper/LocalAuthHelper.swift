//
//  LocalAuthHelper.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 11/13/17.
//

import Foundation
import LocalAuthentication

public protocol LocalAuth {
    func authenticateUser(with reasonStr: String?, completion: ((_ error: String?) -> ())!)
}

public extension LocalAuth {
    public func authenticateUser(with reasonStr: String?, completion:((_ error: String?)->())!) {
        let reason = reasonStr == nil ? "Authentication is needed to access." : reasonStr!
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { (success, bioError) in
                if success {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                } else if let bioError = bioError {
                    let err = bioError as NSError
                    switch err.code {
                    case LAError.systemCancel.rawValue:
                        completion("Authentication was cancelled by the system")
                    case LAError.userCancel.rawValue:
                        completion("Authentication was cancelled by the user")
                    case LAError.userFallback.rawValue:
                        completion("User selected to enter custom password")
                    default:
                        completion(err.localizedDescription)
                    }
                    print(err.localizedDescription)
                }
            })
        } else if let error = error {
            if #available(iOS 11.0, *) {
                switch error.code {
                case LAError.biometryNotEnrolled.rawValue:
                    completion("Biometry is not enrolled")
                case LAError.passcodeNotSet.rawValue:
                    completion("A passcode has not been set")
                default:
                    completion("Biometry not available")
                }
            } else {
                switch error.code {
                case LAError.touchIDNotEnrolled.rawValue:
                    completion("TouchID is not enrolled")
                case LAError.passcodeNotSet.rawValue:
                    completion("A passcode has not been set")
                default:
                    completion("TouchID not available")
                }
            }
            print(error.localizedDescription)
        }
    }
}
