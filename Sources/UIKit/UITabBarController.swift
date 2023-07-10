//
//  UITabBarControllerDelegate+Animate.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 12/18/17.
//

import Foundation
import UIKit

extension UITabBarController {
    
    /// Use with UITabBarControllerDelegate's `tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool`
    /// Support pop to root for custom UITabBarController class
    ///
    /// - Parameters:
    ///   - viewController: The viewController will be selected
    public func checkAndPopToRoot(onSelectingViewController viewController: UIViewController) {
        guard let willSelectIndex = self.viewControllers?.firstIndex(of: viewController), self.selectedIndex == willSelectIndex else {
            return
        }
        
        if let viewController = viewController as? UINavigationController {
            viewController.popToRootViewController(animated: true)
        } else if let viewController = viewController as? UISplitViewController {
            viewController.viewControllers.forEach({ [weak self] in
                self?.checkAndPopToRoot(onSelectingViewController: $0)
            })
        }
    }
    
    /// Use with UITabBarControllerDelegate's `tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool`
    ///
    /// - Parameter viewController: viewController
    /// - Returns: Bool
    @discardableResult
    public func animateSlide(to viewController: UIViewController) -> Bool {
        guard let tabViewControllers = viewControllers,
            let toIndex = tabViewControllers.firstIndex(of: viewController),
            selectedIndex != toIndex,
            let fromView = selectedViewController?.view,
            let toView = viewController.view else {
                return false
        }
        
        fromView.superview!.addSubview(toView)
        
        let screenWidth = UIScreen.main.bounds.size.width;
        let scrollRight = toIndex > selectedIndex;
        let offset = (scrollRight ? screenWidth : -screenWidth)
        toView.center = CGPoint(x: fromView.center.x + offset, y: toView.center.y)
        
        view.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            fromView.center = CGPoint(x: fromView.center.x - offset, y: fromView.center.y);
            toView.center   = CGPoint(x: toView.center.x - offset, y: toView.center.y);
        }, completion: { finished in
            fromView.removeFromSuperview()
            self.selectedIndex = toIndex
            self.view.isUserInteractionEnabled = true
        })
        
        return true
    }
    
    /// Use with UITabBarControllerDelegate's `tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool`
    ///
    /// - Parameters:
    ///   - tabBarController: tabBarController
    ///   - viewController: viewController
    /// - Returns: Bool
    @discardableResult
    public func animateCrossDissolve(to viewController: UIViewController) -> Bool {
        let fromView: UIView = selectedViewController!.view
        let toView  : UIView = viewController.view
        if fromView == toView {
            return false
        }
        
        view.isUserInteractionEnabled = false
        UIView.transition(from: fromView, to: toView, duration: 0.3, options: UIView.AnimationOptions.transitionCrossDissolve) { (finished:Bool) in
            self.view.isUserInteractionEnabled = true
        }
        
        return true
    }
}
