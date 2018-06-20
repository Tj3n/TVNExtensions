//
//  UIAlertController.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 6/12/18.
//

import Foundation

extension UIAlertController {
    public convenience init(title: String?,
                            attributedTitle: NSAttributedString? = nil,
                            message: String?,
                            attributedMessage: NSAttributedString? = nil,
                            preferredStyle: UIAlertControllerStyle,
                            cancelTitle: String,
                            cancelStyle: UIAlertActionStyle = .cancel,
                            cancelHandler: ((UIAlertAction)->())? = nil) {
        self.init(title: title, message: message, preferredStyle: preferredStyle)
        if let attrTitle = attributedTitle {
            self.setValue(attrTitle, forKey: "attributedTitle")
        }
        if let attrMessage = attributedMessage {
            self.setValue(attrMessage, forKey: "attributedMessage")
        }
        
        self.addCancelAction(title: cancelTitle, cancelStyle: cancelStyle, cancelHandler: cancelHandler)
    }
    
    public func addCancelAction(title: String, cancelStyle: UIAlertActionStyle = .cancel, cancelHandler: ((UIAlertAction)->())? = nil) {
        self.addAction(UIAlertAction(title: title, style: .cancel, handler: cancelHandler))
    }
}
