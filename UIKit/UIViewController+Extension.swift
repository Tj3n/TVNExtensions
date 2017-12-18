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
    
    /**
     Create VC from storyboard name and Viewcontrolelr ID
     */
    public class func instantiate(from storyboardName: String, controllerId: String) -> Self
    {
        return instantiateFromStoryboardHelper(storyboardName, storyboardId: controllerId)
    }
    
    fileprivate class func instantiateFromStoryboardHelper<T>(_ storyboardName: String, storyboardId: String) -> T
    {
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(withIdentifier: storyboardId) as! T
        return controller
    }
    
    class func getCurrentViewController(_ vc: UIViewController) -> UIViewController? {
        if let pvc = vc.presentedViewController {
            return getCurrentViewController(pvc)
        } else if let svc = vc as? UISplitViewController, svc.viewControllers.count > 0 {
            return getCurrentViewController(svc.viewControllers.last!)
        } else if let nc = vc as? UINavigationController, nc.viewControllers.count > 0 {
            return getCurrentViewController(nc.topViewController!)
        } else if let tbc = vc as? UITabBarController {
            if let svc = tbc.selectedViewController {
                return getCurrentViewController(svc)
            }
        }
        return vc
    }
}
