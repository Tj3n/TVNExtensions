//
//  ErrorExtension.swift
//  Alamofire
//
//  Created by Tien Nhat Vu on 11/24/17.
//

import Foundation

extension NSError {
    public func show() {
        ErrorAlertView.shared.showError(localizedDescription)
    }
}

extension Error {
    public func show() {
        ErrorAlertView.shared.showError(localizedDescription)
    }
}

private class ErrorAlertView: NSObject, UIAlertViewDelegate {
    static let shared = ErrorAlertView()
    var alert: UIAlertView!
    var isShowing: Bool = false
    
    func showError(_ error: String?) {
        DispatchQueue.main.async(execute: {
            guard error != "cancelled" && UIApplication.shared.applicationState == .active else {
                return
            }
            
            self.dismiss()
            self.alert = UIAlertView(title: "Error", message: error, delegate: self, cancelButtonTitle: "OK")
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
