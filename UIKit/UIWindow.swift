//
//  UIWindowExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 4/1/16.
//  Copyright © 2016 Tien Nhat Vu. All rights reserved.
//

import Foundation
import UIKit

extension UIWindow {
    
    /// Switch window's rootViewController with animation
    ///
    /// - Parameters:
    ///   - viewController: viewController to replace current rootViewController
    ///   - animated: replace with animation
    ///   - completion: completion handler
    public func changeRootViewController(with viewController: UIViewController, animated: Bool, completion: (() -> ())?) {
        guard let oldVC = rootViewController else {
            self.rootViewController = viewController
            completion?()
            return
        }
        
        let oldView = oldVC.view!

        switch animated {
        case true:
            let toView = viewController.view!
            toView.layoutIfNeeded()
            
            let newView = viewController.view!.resizableSnapshotView(from: bounds, afterScreenUpdates: true, withCapInsets: .zero)!
            newView.alpha = 0
            self.addSubview(newView)
            newView.layer.transform = CATransform3DMakeTranslation(0, UIScreen.main.bounds.maxY, 0)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: [.allowAnimatedContent, .curveEaseInOut], animations: {
                newView.alpha = 1
                newView.layer.transform = CATransform3DIdentity
                oldView.alpha = 0
                oldView.layer.transform = CATransform3DMakeScale(0.8, 0.8, 1.0)
            }) { (_) in
                oldView.removeFromSuperview()
                newView.removeFromSuperview()
                self.rootViewController = viewController
                completion?()
            }
        case false:
            oldView.removeFromSuperview()
            self.rootViewController = viewController;
            completion?()
        }
    }
    
    public class func changeRootViewController(with viewController: UIViewController) {
        UIWindow.changeRootViewController(with: viewController, animated: true, completion: nil)
    }
    
    public class func changeRootViewController(with viewController: UIViewController, animated: Bool, completion: (() -> ())?) {
        UIApplication.shared.keyWindow?.changeRootViewController(with: viewController, animated: animated, completion: completion)
    }
}
