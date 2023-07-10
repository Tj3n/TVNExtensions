//
//  UIButtonExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 3/17/16.
//  Copyright © 2016 Tien Nhat Vu. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC

public extension UIButton {
    
    /// To add padding to UIButton
    ///
    /// Example
    /// ```
    /// button.setInsets(forContentPadding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16), imageTitlePadding: 8)
    /// ```
    /// - Parameters:
    ///   - contentPadding: Padding for content edge
    ///   - imageTitlePadding: Padding between image and title
    func setInsets(forContentPadding contentPadding: UIEdgeInsets, imageTitlePadding: CGFloat) {
        self.contentEdgeInsets = UIEdgeInsets(
            top: contentPadding.top,
            left: contentPadding.left,
            bottom: contentPadding.bottom,
            right: contentPadding.right + imageTitlePadding
        )
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: imageTitlePadding,
            bottom: 0,
            right: -imageTitlePadding
        )
    }
    
    var isEnabledWithBG: Bool {
        get {
            return self.isEnabled
        }
        set {
            if newValue == true {
                self.alpha = 1
            } else {
                self.alpha = 0.5
            }
            self.isEnabled = newValue
        }
    }
    
    @IBInspectable var autoShrinkFont: Bool {
        get {
            if let label = titleLabel {
                return label.adjustsFontSizeToFitWidth
            }
            return false
        }
        
        set {
            self.titleLabel?.frame.size.width = self.frame.size.width - (self.imageView?.frame.size.width ?? 0)
            self.titleLabel?.adjustsFontSizeToFitWidth = newValue
        }
    }
    
    @IBInspectable var minimumScaleFactor: CGFloat {
        get {
            if let label = titleLabel {
                return label.minimumScaleFactor
            }
            return 1.0
        }
        
        set {
            self.titleLabel?.minimumScaleFactor = newValue > 1.0 ? 1.0 : newValue
        }
    }
    
    @IBInspectable var flipContent: Bool {
        get {
            return !self.transform.isIdentity
        }
        
        set {
            if newValue {
                self.transform = CGAffineTransform.identity.scaledBy(x: -1.0, y: 1.0)
                self.titleLabel?.transform = CGAffineTransform.identity.scaledBy(x: -1.0, y: 1.0)
                self.imageView?.transform = CGAffineTransform.identity.scaledBy(x: -1.0, y: 1.0)
            } else {
                self.transform = CGAffineTransform.identity
            }
        }
    }
}

// MARK: - .touchUpInside with closure
extension UIButton {
    public typealias ButtonAction = (_ button: UIButton)->()
    
    private class ActionStore: NSObject {
        let action: ButtonAction
        init(_ action: @escaping ButtonAction) {
            self.action = action
        }
    }
    
    private struct AssociatedKeys {
        static var btnActionKey = "btnActionKey"
    }
    
    /// MUST USE [unowned self] to prevent retain cycle
    ///
    /// - Parameter action: closure for .touchUpInside action
    public func addTouchUpInsideAction(_ action: @escaping ButtonAction) {
        touchUpInsideAction = action
        self.addTarget(self, action: #selector(UIButton.doAction), for: .touchUpInside)
    }
    
    @objc func doAction() {
        touchUpInsideAction?(self)
    }
    
    private var touchUpInsideAction: ButtonAction? {
        get {
            guard let store = objc_getAssociatedObject(self, &AssociatedKeys.btnActionKey) as? ActionStore else { return nil }
            return store.action
        }
        
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.btnActionKey, ActionStore(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
