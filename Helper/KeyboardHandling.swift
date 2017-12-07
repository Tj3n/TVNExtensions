//
//  KeyboardHandling.swift
//  ActiveLabel
//
//  Created by Tien Nhat Vu on 10/16/17.
//

import Foundation
import UIKit

public typealias HandlingClosure = ((_ up: Bool, _ height: CGFloat)->())?

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
    
    //Should handle both case of `up`
    public func addKeyboardHandlingClosure(for vc: UIViewController, closure: HandlingClosure) {
        let className = String(describing: type(of: vc))
        handlingClosureDict[className] = closure
    }
    
    private func observeKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardOnScreen(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
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
        
        if isKeyboardShow || deltaHeight == keyboardHeight || deltaHeight < 0 {
            return
        }
        
        keyboardHeight = deltaHeight - keyboardHeight
        
        if let topMostVc = UIWindow.getCurrentViewController() {
            let topMostVcClassName = String(describing: type(of: topMostVc))
            if let closure = handlingClosureDict[topMostVcClassName] {
                closure?(true, keyboardHeight)
            }
        }
        
        keyboardHeight = deltaHeight
        isKeyboardShow = true
    }
    
    @objc private func keyboardOffScreen(_ notification: Notification) {
        guard isKeyboardShow else {
            return
        }
        
        keyboardHeight = 0
        isKeyboardShow = false
        
        if let topMostVc = UIWindow.getCurrentViewController() {
            let topMostVcClassName = String(describing: type(of: topMostVc))
            if let closure = handlingClosureDict[topMostVcClassName] {
                closure?(false, keyboardHeight)
            }
        }
    }
}
