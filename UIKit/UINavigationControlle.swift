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
    public func hideNavigationBar() {
        self.topViewController?.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    public func showNavigationBar() {
        self.topViewController?.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    public func setDarkStatusBar() {
        self.navigationBar.barStyle = .black
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    public func setDefaultStatusBar() {
        self.navigationBar.barStyle = .default
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    public func setInvisibleNavBar() {
        self.navigationBar.isTranslucent = true
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.backgroundColor = UIColor.clear
    }
    
    public func setDefaultNavBar() {
        self.navigationBar.isTranslucent = false
        self.navigationBar.shadowImage = nil
        self.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationBar.backgroundColor = nil
    }
    
    public func addCustomNavBarView(_ view: UIView) {
        self.setInvisibleNavBar()
        self.view.insertSubview(view, belowSubview: self.navigationBar)
    }
    
    /*Handle Back button touched:
     Add to view controller's `viewWillDisappear`:
     if (self.isMovingFromParentViewController || self.isBeingDismissed) {
     // Do your stuff here
     }
    */
}
