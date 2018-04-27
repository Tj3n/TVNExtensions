//
//  UIViewControllerExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 3/17/16.
//  Copyright © 2016 Paymentwall. All rights reserved.
//

import Foundation
import UIKit

public extension UIViewController {
    
    /// Create VC from storyboard name and Viewcontroller ID
    ///
    /// - Parameters:
    ///   - storyboardName: storyboard name
    ///   - controllerId: controller identifier
    /// - Returns: view controller
    public class func instantiate(fromStoryboard storyboardName: String, controllerId: String) -> Self {
        return instantiateFromStoryboardHelper(storyboardName, storyboardId: controllerId)
    }
    
    fileprivate class func instantiateFromStoryboardHelper<T>(_ storyboardName: String, storyboardId: String) -> T {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(withIdentifier: storyboardId) as! T
        return controller
    }
    
    
    /// Get top view controller from window
    ///
    /// - Parameter window: default UIApplication.shared.keyWindow
    /// - Returns: top view controller
    public class func getTopViewController(from window: UIWindow? = UIApplication.shared.keyWindow) -> UIViewController? {
        return getTopViewController(from: window?.rootViewController)
    }
    
    class func getTopViewController(from rootVC: UIViewController?) -> UIViewController? {
        if let nav = rootVC as? UINavigationController, let navFirst = nav.visibleViewController {
            return getTopViewController(from: navFirst)
        } else if let tab = rootVC as? UITabBarController, let selectedTab = tab.selectedViewController {
            return getTopViewController(from: selectedTab)
        } else if let split = rootVC as? UISplitViewController, let splitLast = split.viewControllers.last {
            return getTopViewController(from: splitLast)
        } else if let presented = rootVC?.presentedViewController {
            return getTopViewController(from: presented)
        }
        
        return rootVC
    }
}
