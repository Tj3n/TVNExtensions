//
//  UIViewController+KeyboardHandling.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 7/23/18.
//

import Foundation
import UIKit

extension UIViewController {
    private struct AssociatedKeys {
        static var _keyboardHeightKey = "com.tvn.keyboardHeightKey"
        static var _isKeyboardShowKey = "com.tvn.isKeyboardShowKey"
        static var _keyboardAddedHeightKey = "com.tvn.keyboardAddedHeightKey"
        static var _keyboardHandleKey = "com.tvn.keyboardHandleKey"
        static var _keyboardDurationKey = "com.tvn.keyboardDurationKey"
        static var _keyboardKeyframeAnimationOptionKey = "com.tvn.keyboardKeyframeAnimationOptionKey"
    }
    
    /// Full size of keyboard height
    public private(set) var _keyboardHeight: CGFloat {
        get { return getAssociatedObject(key: &AssociatedKeys._keyboardHeightKey, type: CGFloat.self) ?? 0 }
        set(newValue) { setAssociatedObject(key: &AssociatedKeys._keyboardHeightKey, value: newValue) }
    }
    
    /// Check if keyboard is showing
    public private(set) var _isKeyboardShow: Bool {
        get { return getAssociatedObject(key: &AssociatedKeys._isKeyboardShowKey, type: Bool.self) ?? false }
        set(newValue) { setAssociatedObject(key: &AssociatedKeys._isKeyboardShowKey, value: newValue) }
    }
    
    /// Changed keyboard height from the last handler call
    public private(set) var _keyboardAddedHeight: CGFloat {
        get { return getAssociatedObject(key: &AssociatedKeys._keyboardAddedHeightKey, type: CGFloat.self) ?? 0 }
        set(newValue) { setAssociatedObject(key: &AssociatedKeys._keyboardAddedHeightKey, value: newValue) }
    }
    
    /// Duration of the animation
    public private(set) var _keyboardDuration: Double {
        get { return getAssociatedObject(key: &AssociatedKeys._keyboardDurationKey, type: Double.self) ?? 0 }
        set(newValue) { setAssociatedObject(key: &AssociatedKeys._keyboardDurationKey, value: newValue) }
    }
    
    /// Use with `UIView.animateKeyframes` for smoother animation
    public private(set) var _keyboardKeyframeAnimationOption: UIViewKeyframeAnimationOptions {
        get {
            guard let rawValue = getAssociatedObject(key: &AssociatedKeys._keyboardKeyframeAnimationOptionKey, type: UInt.self) else {
                return UIViewKeyframeAnimationOptions.calculationModeLinear
            }
            return UIViewKeyframeAnimationOptions(rawValue: rawValue)
        }
        set(newValue) { setAssociatedObject(key: &AssociatedKeys._keyboardKeyframeAnimationOptionKey, value: newValue.rawValue) }
    }
    
    private var _handleAction: HandlingClosure? {
        get {
            guard let store = getAssociatedObject(key: &AssociatedKeys._keyboardHandleKey, type: ActionStore.self) else { return nil }
            return store.action
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            setAssociatedObject(key: &AssociatedKeys._keyboardHandleKey, value: ActionStore(newValue))
        }
    }
    
    private class ActionStore: NSObject {
        let action: HandlingClosure
        init(_ action: @escaping HandlingClosure) {
            self.action = action
        }
    }
    
    /// Self handle keyboard event, from iOS 9 there's no need of remove observer manually in dealloc/deinit
    ///
    /// - Parameter handler: Must use [unowned self], Closure parametters:
    ///     ```
    ///     (_ up: Bool, _ height: CGFloat, _ duration: Double) -> ()
    ///     ```
    public func observeKeyboardEvent(handler: @escaping HandlingClosure) {
        _keyboardHeight = 0
        _isKeyboardShow = false
        _keyboardAddedHeight = 0
        _handleAction = handler
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardOnScreen(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardOnScreen(_:)), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardOffScreen(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    /// Before iOS 9 have to remove observer during dealloc/deinit
    public func removeKeyboardEventObserver() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc private func keyboardOnScreen(_ notification: Notification) {
        _keyboardHeight = (notification.userInfo![UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size.height
        _keyboardDuration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]! as! NSNumber).doubleValue
        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! UInt
        _keyboardKeyframeAnimationOption = UIViewKeyframeAnimationOptions(rawValue: curve)
        
        if _keyboardHeight == _keyboardAddedHeight || _keyboardHeight <= 0 {
            return
        }
        
        _keyboardAddedHeight = _keyboardHeight - _keyboardAddedHeight
        
        _handleAction?(true, _keyboardAddedHeight, _keyboardDuration)
        
        _keyboardAddedHeight = _keyboardHeight
        _isKeyboardShow = true
    }
    
    @objc private func keyboardOffScreen(_ notification: Notification) {
        _keyboardDuration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]! as! NSNumber).doubleValue
        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! UInt
        _keyboardKeyframeAnimationOption = UIViewKeyframeAnimationOptions(rawValue: curve)
        
        guard _isKeyboardShow else {
            return
        }
        
        _handleAction?(false, _keyboardHeight, _keyboardDuration)
        
        _keyboardHeight = 0
        _keyboardAddedHeight = 0
        _isKeyboardShow = false
    }
}
