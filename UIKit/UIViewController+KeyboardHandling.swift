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
    /// - Parameter handler: Must use [unowned self]
    public func observeKeyboardEvent(handler: @escaping HandlingClosure) {
        _keyboardHeight = 0
        _isKeyboardShow = false
        _keyboardAddedHeight = 0
        _handleAction = handler
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardOnScreen(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardOnScreen(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardOffScreen(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    /// Before iOS 9 have to remove observer during dealloc/deinit
    public func removeKeyboardEventObserver() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc private func keyboardOnScreen(_ notification: Notification) {
        _keyboardHeight = (notification.userInfo![UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size.height
        let duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]! as! NSNumber).doubleValue
        
        if _keyboardHeight == _keyboardAddedHeight || _keyboardHeight <= 0 {
            return
        }
        
        _keyboardAddedHeight = _keyboardHeight - _keyboardAddedHeight
        
        _handleAction?(true, _keyboardAddedHeight, duration)
        
        _keyboardAddedHeight = _keyboardHeight
        _isKeyboardShow = true
    }
    
    @objc private func keyboardOffScreen(_ notification: Notification) {
        let duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]! as! NSNumber).doubleValue
        
        guard _isKeyboardShow else {
            return
        }
        
        _handleAction?(false, _keyboardHeight, duration)
        
        _keyboardHeight = 0
        _keyboardAddedHeight = 0
        _isKeyboardShow = false
    }
}
