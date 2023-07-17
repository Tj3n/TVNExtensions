//
//  File.swift
//  
//
//  Created by Vũ Tiến on 17/07/2023.
//

import Foundation
import UIKit

public extension NSError {
    func show() {
        ErrorAlertView.shared.showError(self)
    }
}

public extension Error {
    func show() {
        ErrorAlertView.shared.showError(self)
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
