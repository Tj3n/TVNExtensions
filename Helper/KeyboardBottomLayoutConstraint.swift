//
//  KeyboardBottomLayoutConstraint.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 3/26/18.
//

import UIKit

class KeyboardLayoutConstraint: NSLayoutConstraint {
    private var originConstant: CGFloat = 0.0
    private var keyboardHeight: CGFloat = 0.0
    private var isKeyboardShow: Bool = false
    private var defaultKeyboardActiveHeight: CGFloat = 10.0
    
    @IBInspectable var excludeOriginConstant: Bool = false
    @IBInspectable var isTopConstraint: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        observeKeyboardHandling()
        defaultKeyboardActiveHeight = 10.0
        originConstant = constant
    }
    
    private func observeKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardOnScreen(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardOnScreen(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardOffScreen(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        removeKeyboardHandlingObserver()
    }
    
    private func removeKeyboardHandlingObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardOnScreen(_ notification: Notification) {
        let deltaHeight = (notification.userInfo![UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size.height
        
        if deltaHeight == keyboardHeight || deltaHeight <= 0 {
            return
        }
        
        keyboardHeight = deltaHeight - keyboardHeight
        
        if isTopConstraint {
            constant -= keyboardHeight
        } else {
            if excludeOriginConstant {
                defaultKeyboardActiveHeight += keyboardHeight
                constant = defaultKeyboardActiveHeight
            } else {
                constant += keyboardHeight
            }
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            UIApplication.shared.keyWindow?.layoutIfNeeded()
        })
        
        keyboardHeight = deltaHeight
        isKeyboardShow = true
    }
    
    @objc private func keyboardOffScreen(_ notification: Notification) {
        guard isKeyboardShow else {
            return
        }
        
        if isTopConstraint {
            constant += keyboardHeight
        } else {
            if excludeOriginConstant {
                constant = originConstant
                defaultKeyboardActiveHeight = 10
            } else {
                constant -= keyboardHeight
            }
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            UIApplication.shared.keyWindow?.layoutIfNeeded()
        })
        
        keyboardHeight = 0
        isKeyboardShow = false
    }
    
}
