//
//  KeyboardHandling.swift
//  ActiveLabel
//
//  Created by Tien Nhat Vu on 10/16/17.
//

import Foundation
import UIKit

public typealias HandlingClosure = (_ up: Bool, _ height: CGFloat, _ duration: Double)->()

public class KeyboardHandling {
    public static let shared: KeyboardHandling = {
        let controller = KeyboardHandling()
        controller.observeKeyboardHandling()
        return controller
    }()
    
    public private(set) var keyboardHeight: CGFloat = 0
    public private(set) var isKeyboardShow: Bool = false
    public private(set) var duration: Double = 0.3
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
        keyboardHeight = (notification.userInfo![UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size.height
        duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]! as! NSNumber).doubleValue
        
        if keyboardHeight == keyboardAddedHeight || keyboardHeight <= 0 {
            return
        }
        
        keyboardAddedHeight = keyboardHeight - keyboardAddedHeight
        
        if let topMostVc = UIViewController.getTopViewController() {
            executeClosure(true, keyboardAddedHeight, duration, for: topMostVc)
        }
        
        keyboardAddedHeight = keyboardHeight
        isKeyboardShow = true
    }
    
    @objc private func keyboardOffScreen(_ notification: Notification) {
        duration = (notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]! as! NSNumber).doubleValue
        
        guard isKeyboardShow else {
            return
        }
        
        if let topMostVc = UIViewController.getTopViewController() {
            executeClosure(false, keyboardHeight, duration, for: topMostVc)
        }
        
        keyboardHeight = 0
        keyboardAddedHeight = 0
        isKeyboardShow = false
    }
    
    /// Recurring call to make sure all childVC also got called
    func executeClosure(_ up: Bool, _ height: CGFloat, _ duration: Double, for vc: UIViewController) {
        for child in vc.childViewControllers {
            executeClosure(up, height, duration, for: child)
        }
        
        let vcClassName = String(describing: type(of: vc))
        if let closure = handlingClosureDict[vcClassName] {
            closure(up, height, duration)
        }
    }
}
