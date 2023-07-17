//
//  UIAlertController.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 6/12/18.
//

import Foundation
import UIKit

extension UIAlertController {
    
    public var attributedTitle: NSAttributedString? {
        get { return self.value(forKey: "attributedTitle") as? NSAttributedString }
        set { self.setValue(newValue, forKey: "attributedTitle") }
    }
    
    public var attributedMessage: NSAttributedString? {
        get { return self.value(forKey: "attributedMessage") as? NSAttributedString }
        set { self.setValue(newValue, forKey: "attributedMessage") }
    }
    
    public convenience init(title: String?,
                            message: String?,
                            preferredStyle: UIAlertController.Style,
                            cancelTitle: String,
                            cancelStyle: UIAlertAction.Style = .cancel,
                            cancelHandler: ((UIAlertAction)->())? = nil) {
        self.init(title: title, message: message, preferredStyle: preferredStyle)
        self.addCancelAction(title: cancelTitle, cancelStyle: cancelStyle, cancelHandler: cancelHandler)
    }
    
    public func addCancelAction(title: String, cancelStyle: UIAlertAction.Style = .cancel, cancelHandler: ((UIAlertAction)->())? = nil) {
        self.addAction(UIAlertAction(title: title, style: .cancel, handler: cancelHandler))
    }
    
    public func show() {
        if let topVC = UIViewController.getTopViewController() {
            topVC.present(self, animated: true, completion: nil)
        } else {
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.windowLevel = UIWindow.Level.statusBar
            window.rootViewController = UIViewController()
            window.makeKeyAndVisible()
            window.rootViewController?.present(self, animated: true, completion: nil)
        }
    }
}
