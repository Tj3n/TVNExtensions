//
//  KeyboardBottomLayoutConstraint.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 3/26/18.
//

import UIKit

public class KeyboardLayoutConstraint: NSLayoutConstraint {
    
    ///Set to true to handle constraint's constant by `keyboardActiveAmount`
    @IBInspectable public var excludeOriginConstant: Bool = false
    ///Set to true to flip the added height
    @IBInspectable public var isTopConstraint: Bool = false
    ///Constraint constant to use if `excludeOriginConstant` = true
    @IBInspectable public var keyboardActiveAmount: CGFloat = 0
    
    private var originConstant: CGFloat = 0.0
    private var defaultKeyboardActiveHeight: CGFloat = 0.0
    private var keyboardHeight: CGFloat = 0.0
    private var isKeyboardShow: Bool = false
    
    /// Create constraint with automatically keyboard handling
    ///
    /// - Parameters:
    ///   - view: First item, usually the sub view
    ///   - secondView: Second item, usually the super view
    ///   - constant: Default constant
    ///   - relatedBy: Default = .equal
    ///   - isToTop: Is contrained to top or bottom. Default = false
    ///   - excludeOriginConstant: Set to true to handle constraint's constant by `keyboardActiveAmount`, ignored if `isTopConstraint` = true. Default = false
    ///   - keyboardActiveAmount: Constraint constant to use if `excludeOriginConstant` = true, ignored if `isTopConstraint` = true. Default = 0
    public convenience init(from view: UIView, to secondView: UIView, constant: CGFloat, isToTop: Bool, relatedBy: NSLayoutConstraint.Relation = .equal, excludeOriginConstant: Bool = false, keyboardActiveAmount: CGFloat = 0) {
        if isToTop {
            self.init(item: view, attribute: .topMargin, relatedBy: relatedBy, toItem: secondView, attribute: .topMargin, multiplier: 1, constant: constant)
        } else {
            self.init(item: secondView, attribute: .bottomMargin, relatedBy: relatedBy, toItem: view, attribute: .bottomMargin, multiplier: 1, constant: constant)
        }
        self.isTopConstraint = isToTop
        self.excludeOriginConstant = excludeOriginConstant
        self.keyboardActiveAmount = keyboardActiveAmount
        self.startHandling()
    }
    
    /// Create constraint with automatically keyboard handling
    ///
    /// - Parameters:
    ///   - view: First item, usually the sub view
    ///   - secondView: Second item, usually the super view
    ///   - constant: Default constant
    ///   - relatedBy: Default = .equal
    ///   - isToTop: Is contrained to top or bottom. Default = false
    ///   - excludeOriginConstant: Set to true to handle constraint's constant by `keyboardActiveAmount`. Default = false
    ///   - keyboardActiveAmount: Constraint constant to use if `excludeOriginConstant` = true. Default = 0
    /// - Returns: KeyboardLayoutConstraint
    @available(iOS, deprecated, message: "Use init function instead.")
    public class func constraint(from view: UIView, to secondView: UIView, constant: CGFloat, relatedBy: NSLayoutConstraint.Relation = .equal, isToTop: Bool = false, excludeOriginConstant: Bool = false, keyboardActiveAmount: CGFloat = 0) -> KeyboardLayoutConstraint {
        var constraint: KeyboardLayoutConstraint
        if isToTop {
            constraint = KeyboardLayoutConstraint(item: view, attribute: .topMargin, relatedBy: relatedBy, toItem: secondView, attribute: .topMargin, multiplier: 1, constant: constant)
        } else {
            constraint = KeyboardLayoutConstraint(item: secondView, attribute: .bottomMargin, relatedBy: relatedBy, toItem: view, attribute: .bottomMargin, multiplier: 1, constant: constant)
        }
        constraint.isTopConstraint = isToTop
        constraint.excludeOriginConstant = excludeOriginConstant
        constraint.keyboardActiveAmount = keyboardActiveAmount
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
        defaultKeyboardActiveHeight = keyboardActiveAmount
        originConstant = constant
    }
    
    private func observeKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardOnScreen(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardOnScreen(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardOffScreen(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        removeKeyboardHandlingObserver()
    }
    
    private func removeKeyboardHandlingObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardOnScreen(_ notification: Notification) {
        let deltaHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size.height
        let duration = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as! NSNumber).doubleValue
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        
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
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
            UIApplication.shared.keyWindow?.layoutIfNeeded()
        }, completion: nil)
        
        keyboardHeight = deltaHeight
        isKeyboardShow = true
    }
    
    @objc private func keyboardOffScreen(_ notification: Notification) {
        guard isKeyboardShow else {
            return
        }
        
        let duration = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as! NSNumber).doubleValue
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        
        if isTopConstraint {
            constant += keyboardHeight
        } else {
            if excludeOriginConstant {
                constant = originConstant
                defaultKeyboardActiveHeight = keyboardActiveAmount
            } else {
                constant -= keyboardHeight
            }
        }
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
            UIApplication.shared.keyWindow?.layoutIfNeeded()
        }, completion: nil)
        
        keyboardHeight = 0
        isKeyboardShow = false
    }
}
