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
    ///   - storyboardName: storyboard name, default to "Main"
    ///   - controllerId: controller identifier, default to the same Class name
    /// - Returns: view controller
    public class func instantiate(fromStoryboard storyboardName: String = "Main", controllerId: String = "") -> Self {
        return instantiateFromStoryboardHelper(storyboardName, storyboardId: controllerId.isEmpty ? String(describing: self) : controllerId)
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
    
    /// Add child VC with present animation, should use animation with full-screen child VC only
    ///
    /// - Parameters:
    ///   - controller: Child view controller
    ///   - toView: The view to contain the controller's view
    ///   - animated: Set to true to use custom present animation
    public func addChildViewController(_ childController: UIViewController, toView: UIView, animated: Bool) {
        self.addChildViewController(childController)
        let v = childController.view!
        v.alpha = 0
        v.addTo(toView)
        v.edgesToSuperView()
        
        guard animated else {
            v.alpha = 1
            childController.didMove(toParentViewController: self)
            return
        }
        
        var transform = CATransform3DMakeScale(0.3, 0.3, 1.0)
        transform = CATransform3DTranslate(transform, 0, UIScreen.main.bounds.maxY, 0)
        v.layer.transform = transform
        
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
            v.layer.transform = CATransform3DIdentity
            v.alpha = 1
        }, completion: { (_) in
            childController.didMove(toParentViewController: self)
        })
    }
    
    /// Switch child view controller with animation
    ///
    /// - Parameters:
    ///   - oldViewController: oldViewController
    ///   - newViewController: newViewController
    ///   - containerView: containerView to switch
    ///   - completion: completion handler
    func switchChildViewController(_ oldViewController: UIViewController, to newViewController: UIViewController, in containerView: UIView, completion: (()->())?) {
        oldViewController.willMove(toParentViewController: nil)
        self.addChildViewController(newViewController)
        
        newViewController.view.addTo(containerView)
        newViewController.view.edgesToSuperView()
        
        newViewController.view.alpha = 0
        newViewController.view.layoutIfNeeded()
        newViewController.view.layer.transform = CATransform3DMakeTranslation(0, UIScreen.main.bounds.maxY, 0)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.allowAnimatedContent, .curveEaseInOut], animations: {
            newViewController.view.alpha = 1
            newViewController.view.layer.transform = CATransform3DIdentity
            oldViewController.view.alpha = 0
            oldViewController.view.layer.transform = CATransform3DMakeScale(0.8, 0.8, 1.0)
        }) { (_) in
            oldViewController.view.removeFromSuperview()
            oldViewController.removeFromParentViewController()
            newViewController.didMove(toParentViewController: self)
            completion?()
        }
    }
}