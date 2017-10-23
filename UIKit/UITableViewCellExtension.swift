//
//  UITableViewCellExtension.swift
//  Alamofire
//
//  Created by Tien Nhat Vu on 10/23/17.
//

import Foundation
import UIKit

extension UITableViewCell {
    public func animateSwipe() {
//        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
//        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
//        animation.duration = 0.6
//        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
//        self.layer.add(animation, forKey: "shake")
        
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseInOut, animations: {
            self.frame = CGRect.init(x: self.frame.origin.x - 100, y: self.frame.origin.y, width: self.bounds.size.width + 100, height: self.bounds.size.height)
        }) { (finish) in
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseInOut, animations: {
                self.frame = CGRect.init(x: self.frame.origin.x + 100, y: self.frame.origin.y, width: self.bounds.size.width - 100, height: self.bounds.size.height)
            }, completion: nil)
        }
    }
}
