//
//  UIAlertController.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 6/12/18.
//

import Foundation

extension UIAlertController {
    public convenience init(title: String?, message: String?, preferredStyle: UIAlertControllerStyle, cancelTitle: String) {
        self.init(title: title, message: message, preferredStyle: preferredStyle)
        self.addCancelAction(title: cancelTitle)
    }
    
    public func addCancelAction(title: String) {
        self.addAction(UIAlertAction(title: title, style: .cancel, handler: nil))
    }
}
