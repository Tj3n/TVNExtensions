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
}
