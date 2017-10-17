//
//  UIButtonExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 3/17/16.
//  Copyright © 2016 Paymentwall. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    //Button Selector as Closure, call button.actionHandle = ...
    fileprivate func actionHandleBlock(_ action:(() -> Void)? = nil) {
        struct __ {
            static var action :(() -> Void)?
        }
        if action != nil {
            __.action = action
        } else {
            __.action?()
        }
    }
    
    @objc fileprivate func triggerActionHandleBlock() {
        self.actionHandleBlock()
    }
    
    func actionHandle(controlEvents control :UIControlEvents, ForAction action:@escaping () -> Void) {
        self.actionHandleBlock(action)
        self.addTarget(self, action: #selector(UIButton.triggerActionHandleBlock), for: control)
    }
    
    open var isEnabledWithBG: Bool {
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
}
