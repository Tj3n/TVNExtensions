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
    
    public class func changeRootViewController(with viewController: UIViewController) {
        UIWindow.changeRootViewController(with: viewController, animated: true, completion: nil)
    }
    
    public class func changeRootViewController(with viewController: UIViewController, animated: Bool, completion: (() -> ())?) {
        guard let oldVC = UIViewController.getTopViewController() else {
            UIApplication.shared.keyWindow?.rootViewController = viewController
            return
        }
        
        let screenBounds = UIScreen.main.bounds
        let oldView = oldVC.view!
        let newView = viewController.view!
        
        newView.frame = CGRect(x: 0, y: screenBounds.maxY, width: screenBounds.width, height: screenBounds.height)
        oldView.superview?.addSubview(newView)
        
        switch animated {
        case true:
            UIView.animate(withDuration: 0.3, delay: 0, options: [.allowAnimatedContent, .curveEaseInOut], animations: {
                oldView.transform.scaledBy(x: 0.8, y: 0.8)
                newView.transform.translatedBy(x: 0, y: -screenBounds.maxY)
            }) { (completed) in
                oldView.removeFromSuperview()
                UIApplication.shared.keyWindow?.rootViewController = viewController;
                completion?()
            }
        case false:
            oldView.removeFromSuperview()
            UIApplication.shared.keyWindow?.rootViewController = viewController;
            completion?()
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
