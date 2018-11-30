//
//  UIActivityIndicatorViewExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 6/10/16.
//  Copyright © 2016 Tien Nhat Vu. All rights reserved.
//

import Foundation
import UIKit

extension UIActivityIndicatorView {
    private static let tvnIndicatorTag = 38383
    
    /// Show custom loader in view, keep the instance to stop the loading view
    ///
    /// - Parameter view: view to show loader above
    /// - Returns: A custom UIActivityIndicatorView
    public class func showInView(_ view: UIView) -> UIActivityIndicatorView {
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.backgroundColor = UIColor(white: 0.0, alpha: 0.4)
        activityIndicator.layer.cornerRadius = 30.0
        activityIndicator.startAnimating()
        activityIndicator.center = CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height / 2)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.alpha = 0.0
        activityIndicator.tag = tvnIndicatorTag
        
        view.addSubview(activityIndicator)
        view.bringSubviewToFront(activityIndicator)
        view.isUserInteractionEnabled = false
        view.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100.0))
        view.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100.0))
        view.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        view.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        activityIndicator.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        UIView.animate(withDuration: 0.2, animations: {() -> Void in
            activityIndicator.alpha = 1.0
            activityIndicator.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }, completion: {(finished: Bool) -> Void in
                UIView.animate(withDuration: 0.1, animations: {() -> Void in
                    activityIndicator.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                })
        })
        
        return activityIndicator
    }
    
    public func end(completion: (() -> ())? = nil) {
        guard self.tag == UIActivityIndicatorView.tvnIndicatorTag else { return }
        self.superview?.isUserInteractionEnabled = true
        let center: CGPoint = self.center
        UIView.animate(withDuration: 0.2, animations: {() -> Void in
            self.alpha = 0.0
            self.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.center = center
            }, completion: {(finished: Bool) -> Void in
                self.removeFromSuperview()
                completion?()
        })
    }
}

