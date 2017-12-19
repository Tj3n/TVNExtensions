//
//  UITabBarControllerDelegate+Animate.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 12/18/17.
//

import Foundation
import UIKit

///Use with UITabBarControllerDelegate's `tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool`
extension UITabBarController {
    public func animateSlide(to viewController: UIViewController) -> Bool {
        guard let tabViewControllers = viewControllers else { return false }
        
        guard let toIndex = tabViewControllers.index(of: viewController) else { return false }
        
        guard let fromView = selectedViewController!.view else { return false }
        guard let toView = tabViewControllers[toIndex].view  else { return false }
        
        guard selectedIndex != toIndex else { return false }
        
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
    
    public func animateCrossDissolve(with tabBarController: UITabBarController, to viewController: UIViewController) -> Bool {
        let fromView: UIView = selectedViewController!.view
        let toView  : UIView = viewController.view
        if fromView == toView {
            return false
        }
        
        view.isUserInteractionEnabled = false
        UIView.transition(from: fromView, to: toView, duration: 0.3, options: UIViewAnimationOptions.transitionCrossDissolve) { (finished:Bool) in
            self.view.isUserInteractionEnabled = true
        }
        
        return true
    }
}
