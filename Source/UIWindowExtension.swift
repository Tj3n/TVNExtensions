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
        
        // If the root view is a navigation controller, we can just return the visible ViewController
        if let navigationController = getNavigationController() {
            
            return navigationController.visibleViewController
        }
        
        // Otherwise, we must get the root UIViewController and iterate through presented views
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            
            var currentController: UIViewController! = rootController
            
            // Each ViewController keeps track of the view it has presented, so we
            // can move from the head to the tail, which will always be the current view
            while( currentController.presentedViewController != nil ) {
                
                currentController = currentController.presentedViewController
            }
            return currentController
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
