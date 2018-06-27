//
//  KeyboardBottomLayoutConstraint.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 3/26/18.
//

import UIKit

public class KeyboardLayoutConstraint: NSLayoutConstraint {
    
    ///Set to true to handle constraint's constant by `originAmount`
    @IBInspectable public var excludeOriginConstant: Bool = false
    ///Set to true to flip the added height
    @IBInspectable public var isTopConstraint: Bool = false
    ///Origin amount to add to if `excludeOriginConstant` = true
    @IBInspectable public var originAmount: CGFloat = 0
    
    private var originConstant: CGFloat = 0.0
    private var defaultKeyboardActiveHeight: CGFloat = 0.0
    private var keyboardHeight: CGFloat = 0.0
    private var isKeyboardShow: Bool = false
    
    /// Create constraint with automatically keyboard handling
    ///
    /// - Parameters:
    ///   - view: First item, usually the current view
    ///   - secondView: Second item, usually the super view
    ///   - isToTop: Is contrained to top or bottom
    ///   - constant: Default constant
    /// - Returns: KeyboardLayoutConstraint
    public class func create(with view: UIView, to secondView: UIView, isToTop: Bool = false, constant: CGFloat) -> KeyboardLayoutConstraint {
        var constraint: KeyboardLayoutConstraint
        if isToTop {
            constraint = KeyboardLayoutConstraint(item: view, attribute: .topMargin, relatedBy: .equal, toItem: secondView, attribute: .topMargin, multiplier: 1, constant: constant)
        } else {
            constraint = KeyboardLayoutConstraint(item: secondView, attribute: .bottomMargin, relatedBy: .equal, toItem: view, attribute: .bottomMargin, multiplier: 1, constant: constant)
        }
        constraint.isTopConstraint = isToTop
        constraint.startHandling()
        return constraint
    }
    
    /// To use with storyboard
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.startHandling()
    }
    
    private func startHandling() {
        observeKeyboardHandling()
        defaultKeyboardActiveHeight = originAmount
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
                defaultKeyboardActiveHeight = originAmount
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
