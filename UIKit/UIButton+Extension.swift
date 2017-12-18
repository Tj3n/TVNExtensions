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
}
