//
//  ErrorExtension.swift
//  Alamofire
//
//  Created by Tien Nhat Vu on 11/24/17.
//

import Foundation
import UIKit

public let TVNErrorDomain = "com.tvn.errorDomain"

public extension NSError {
    func show() {
        ErrorAlertView.shared.showError(self)
    }
    
    var jsonString: String? {
        get {
            let dict = ["code": String(self.code),
                        "description": self.localizedDescription]
            if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    return jsonString
                }
            }
            return nil
        }
    }
}

public extension Error {
    func show() {
        ErrorAlertView.shared.showError(self)
    }
    
    var jsonString: String? {
        get {
            let err = self as NSError
            var dict = ["code": String(err.code)]
            if let localizedDescription = err.userInfo[NSLocalizedDescriptionKey] as? String {
                dict["description"] = localizedDescription
            } else {
                dict["description"] = "Unknow error"
            }
            
            if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: []) {
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    return jsonString
                }
            }
            
            return nil
        }
    }
}

private class ErrorAlertView {
    static let shared = ErrorAlertView()
    var alert: UIAlertController?
    
    func showError(_ error: Error?) {
        DispatchQueue.main.async {
            guard (error as NSError?)?.code != NSURLErrorCancelled && UIApplication.shared.applicationState == .active else {
                return
            }
            
            if let alert = self.alert, let _ = alert.presentingViewController {
                alert.message = error?.localizedDescription
            } else {
                self.alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert, cancelTitle: "OK")
                self.alert?.show()
            }
        }
    }
}
