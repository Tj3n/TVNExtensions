//
//  ErrorExtension.swift
//  Alamofire
//
//  Created by Tien Nhat Vu on 11/24/17.
//

import Foundation

public let TVNErrorDomain = "com.tvn.errorDomain"

public extension NSError {
    public func show() {
        ErrorAlertView.shared.showError(self)
    }
    
    public var jsonString: String? {
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
    public func show() {
        ErrorAlertView.shared.showError(self)
    }
    
    public var jsonString: String? {
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

private class ErrorAlertView: NSObject, UIAlertViewDelegate {
    static let shared = ErrorAlertView()
    var alert: UIAlertView!
    var isShowing: Bool = false
    
    func showError(_ error: Error?) {
        DispatchQueue.main.async(execute: {
            guard (error as NSError?)?.code != NSURLErrorCancelled && UIApplication.shared.applicationState == .active else {
                return
            }
            
            self.dismiss()
            self.alert = UIAlertView(title: "Error", message: error?.localizedDescription, delegate: self, cancelButtonTitle: "OK")
            self.alert.show()
            self.isShowing = true
        })
    }
    
    func alertViewCancel(_ alertView: UIAlertView) {
        isShowing = false
    }
    
    func dismiss() {
        if self.isShowing == true {
            self.alert.dismiss(withClickedButtonIndex: self.alert.cancelButtonIndex, animated: true)
        }
    }
}
