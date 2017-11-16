//
//  UIWindowExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 4/1/16.
//  Copyright © 2016 Paymentwall. All rights reserved.
//

import Foundation
import UIKit

extension UIWindow {
    // Returns the most recently presented UIViewController (visible)
    public class func getCurrentViewController() -> UIViewController? {
        if let navigationController = getNavigationController() {
            return navigationController.visibleViewController
        }
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            return UIViewController.getCurrentViewController(rootController)
        }
        
        return nil
    }
    
    // Returns the navigation controller if it exists
    class func getNavigationController() -> UINavigationController? {
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController  {
            return navigationController as? UINavigationController
        }
        return nil
    }
    
    public class func changeRootViewController(with viewController: UIViewController) {
        let delegate = UIApplication.shared.delegate!
        
        let oldVC = delegate.window??.rootViewController
        let oldView = oldVC!.view!
        let newView = viewController.view!
        UIView.transition(from: oldView, to: newView, duration: 0.5, options: [.allowAnimatedContent, .transitionCrossDissolve]) { (completed) in
            delegate.window??.rootViewController = viewController;
        }
    }

    //From IQKeyboardManager
//    public func topMostController()->UIViewController? {
//
//        var controllersHierarchy = [UIViewController]()
//
//        if var topController = window?.rootViewController {
//            controllersHierarchy.append(topController)
//
//            while topController.presentedViewController != nil {
//
//                topController = topController.presentedViewController!
//
//                controllersHierarchy.append(topController)
//            }
//
//            var matchController :UIResponder? = viewController()
//
//            while matchController != nil && controllersHierarchy.contains(matchController as! UIViewController) == false {
//
//                repeat {
//                    matchController = matchController?.next
//
//                } while matchController != nil && matchController is UIViewController == false
//            }
//
//            return matchController as? UIViewController
//
//        } else {
//            return viewController()
//        }
//    }
}
