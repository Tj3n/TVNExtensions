//
//  KeyboardHandling.swift
//  ActiveLabel
//
//  Created by Tien Nhat Vu on 10/16/17.
//

import Foundation
import UIKit

public typealias HandlingClosure = (_ up: Bool, _ height: CGFloat)->()

public class KeyboardHandling {
    public static let shared: KeyboardHandling = {
        let controller = KeyboardHandling()
        controller.observeKeyboardHandling()
        return controller
    }()
    
    public private(set) var keyboardHeight: CGFloat = 0
    public private(set) var isKeyboardShow: Bool = false
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
        let deltaHeight = (notification.userInfo![UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size.height
        
        if deltaHeight == keyboardHeight || deltaHeight <= 0 {
            return
        }
        
        keyboardHeight = deltaHeight - keyboardHeight
        
        if let topMostVc = UIViewController.getTopViewController() {
            executeClosure(true, keyboardHeight, for: topMostVc)
        }
        
        keyboardHeight = deltaHeight
        isKeyboardShow = true
    }
    
    @objc private func keyboardOffScreen(_ notification: Notification) {
        guard isKeyboardShow else {
            return
        }
        
        if let topMostVc = UIViewController.getTopViewController() {
            executeClosure(false, keyboardHeight, for: topMostVc)
        }
        
        keyboardHeight = 0
        isKeyboardShow = false
    }
    
    /// Recurring call to make sure all childVC also got called
    func executeClosure(_ up: Bool, _ height: CGFloat, for vc: UIViewController) {
        for child in vc.childViewControllers {
            executeClosure(up, height, for: child)
        }
        
        let vcClassName = String(describing: type(of: vc))
        if let closure = handlingClosureDict[vcClassName] {
            closure(up, height)
        }
    }
}
