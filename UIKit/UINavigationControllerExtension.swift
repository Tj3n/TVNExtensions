//
//  UINavigationControllerExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 6/29/16.
//  Copyright © 2016 Paymentwall. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    func hideNavigationBar() {
        self.topViewController?.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func showNavigationBar() {
        self.topViewController?.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func setDarkStatusBar() {
        self.navigationBar.barStyle = .black
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func setDefaultStatusBar() {
        self.navigationBar.barStyle = .default
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    func setInvisibleNavBar() {
        self.navigationBar.isTranslucent = true
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.backgroundColor = UIColor.clear
    }
    
    func setDefaultNavBar() {
        self.navigationBar.isTranslucent     = false
        self.navigationBar.shadowImage     = nil
        self.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationBar.backgroundColor = nil
    }
    
    func addCustomNavBarView(_ view: UIView) {
        self.setInvisibleNavBar()
        self.view.insertSubview(view, belowSubview: self.navigationBar)
    }
}
