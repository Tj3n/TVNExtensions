//
//  KeyboardHandling.swift
//  ActiveLabel
//
//  Created by Tien Nhat Vu on 10/16/17.
//

import Foundation
import UIKit

public typealias HandlingClosure = (_ up: Bool, _ height: CGFloat, _ duration: Double)->()

@available(iOS, deprecated: 9.0, message: "From iOS 9, use `self.observeKeyboardEvent(handler:)` instead")
public class KeyboardHandling {
    public static let shared: KeyboardHandling = {
        let controller = KeyboardHandling()
        controller.observeKeyboardHandling()
        return controller
    }()
    
    /// Set this to work in different window level
    public var windows: [UIWindow?] = [UIApplication.shared.keyWindow]
    
    /// Full size of keyboard height
    public private(set) var keyboardHeight: CGFloat = 0
    
    /// Check if keyboard is showing
    public private(set) var isKeyboardShow: Bool = false
    
    /// Changed keyboard height from the last handler call
    public private(set) var keyboardAddedHeight: CGFloat = 0
    
    private var handlingClosureDict = [String: HandlingClosure]()
    
    private init() {
        
    }
    
    /// MUST USE [unowned self] to prevent retain cycle
    ///
    /// - Parameters:
    ///   - vc: UIViewController
    ///   - closure: HandlingClosure, should handle both case of `up`
    public func addKeyboardHandlingClosure(for vc: UIViewController, closure: @escaping HandlingClosure) {
        let className = String(describing: type(of: vc))
        handlingClosureDict[className] = closure
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
        keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size.height
        let duration = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as! NSNumber).doubleValue
        
        if keyboardHeight == keyboardAddedHeight || keyboardHeight <= 0 {
            return
        }
        
        keyboardAddedHeight = keyboardHeight - keyboardAddedHeight
        
        windows.forEach({
            if let topMostVc = UIViewController.getTopViewController(from: $0) {
                executeClosure(true, keyboardAddedHeight, duration, for: topMostVc)
            }
        })
        
        keyboardAddedHeight = keyboardHeight
        isKeyboardShow = true
    }
    
    @objc private func keyboardOffScreen(_ notification: Notification) {
        let duration = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as! NSNumber).doubleValue
        
        guard isKeyboardShow else {
            return
        }
        
        windows.forEach({
            if let topMostVc = UIViewController.getTopViewController(from: $0) {
                executeClosure(false, keyboardHeight, duration, for: topMostVc)
            }
        })
        
        keyboardHeight = 0
        keyboardAddedHeight = 0
        isKeyboardShow = false
    }
    
    /// Recurring call to make sure all childVC also got called
    func executeClosure(_ up: Bool, _ height: CGFloat, _ duration: Double, for vc: UIViewController) {
        for child in vc.children {
            executeClosure(up, height, duration, for: child)
        }
        
        let vcClassName = String(describing: type(of: vc))
        if let closure = handlingClosureDict[vcClassName] {
            closure(up, height, duration)
        }
    }
}
