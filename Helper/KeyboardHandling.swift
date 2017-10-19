//
//  KeyboardHandling.swift
//  ActiveLabel
//
//  Created by Tien Nhat Vu on 10/16/17.
//

import Foundation
import UIKit

public typealias HandlingClosure = ((_ up: Bool)->())?

public class KeyboardHandling {
    public static let shared: KeyboardHandling = {
        let controller = KeyboardHandling()
        controller.observeKeyboardHandling()
        return controller
    }()
    
    public var keyboardHeight: CGFloat = 0
    public var isKeyboardShow: Bool = false
    private var handlingClosureDict = [String: HandlingClosure]()
    
    private func observeKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardOnScreen(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardOffScreen(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func removeKeyboardHandlingObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func addKeyboardHandlingClosure(for vc: UIViewController, closure: HandlingClosure) {
        let className = String(describing: type(of: vc))
        handlingClosureDict[className] = closure
    }
    
    @objc func keyboardOnScreen(_ notification: Notification) {
        let deltaHeight = (notification.userInfo![UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size.height
        
        if isKeyboardShow || deltaHeight == keyboardHeight || deltaHeight < 0 {
            return
        }
        
        keyboardHeight = deltaHeight - keyboardHeight
        
        if let topMostVc = UIWindow.getCurrentViewController() {
            let topMostVcClassName = String(describing: type(of: topMostVc))
            if let closure = handlingClosureDict[topMostVcClassName] {
                closure?(true)
            }
        }
        
        
        keyboardHeight = deltaHeight
        isKeyboardShow = true
    }
    
    @objc func keyboardOffScreen(_ notification: Notification) {
        guard isKeyboardShow else {
            return
        }
        
        keyboardHeight = 0
        isKeyboardShow = false
        
        if let topMostVc = UIWindow.getCurrentViewController() {
            let topMostVcClassName = String(describing: type(of: topMostVc))
            if let closure = handlingClosureDict[topMostVcClassName] {
                closure?(false)
            }
        }
    }
}
