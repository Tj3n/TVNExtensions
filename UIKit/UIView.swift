//
//  UIViewExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 3/16/16.
//  Copyright © 2016 Paymentwall. All rights reserved.
//

import Foundation
import UIKit

//private var startGradientColorKey: UInt8 = 0 // We still need this boilerplate
//private var endGradientColorKey: UInt8 = 1 // We still need this boilerplate

// MARK: Some frame value and class func
extension UIView {
    public var width: CGFloat {
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
        get {
            return self.frame.size.width
        }
    }
    
    public var height: CGFloat {
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
        get {
            return self.frame.size.height
        }
    }
    
    public var originX: CGFloat {
        set {
            self.frame.origin.x = newValue
        }
        get {
            return self.frame.origin.x
        }
    }
    
    public var originY: CGFloat {
        set {
            self.frame.origin.y = newValue
        }
        get {
            return self.frame.origin.y
        }
    }
    
    /// Create view from same name's nib
    ///
    /// - Returns: view
    public class func viewWithNib() -> Self? {
        return viewWithNibHelper()
    }
    
    fileprivate class func viewWithNibHelper<T>() -> T? {
        let viewsArray = Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)
        guard let viewArray = viewsArray else { return nil }
        if viewArray.count > 0 {
            return viewArray.first as? T
        }
        
        return nil
    }

    /**
     Take snapshot of view as uiimage
     
     - returns: uiview contains snapshot image with shadow
     */
    public func snapshot() -> UIView? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        let cellSnapshot : UIView = UIImageView(image: image)
        let snapshotView = UIView(frame: cellSnapshot.frame)
        
        cellSnapshot.layer.masksToBounds = true
        cellSnapshot.layer.cornerRadius = 5
        
        //        cellSnapshot.layer.cornerRadius = 0.0
        snapshotView.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        snapshotView.layer.shadowRadius = 5.0
        snapshotView.layer.shadowOpacity = 0.4
        
        snapshotView.addSubview(cellSnapshot)
        
        return snapshotView
    }
    
    /**
     Set gradient color
     
     - parameter startCol:   start color
     - parameter endCol:     end color
     - parameter startPoint: min 0 max 1
     - parameter endPoint:   min 0 max 1
     */
    public func setGradientBackground(color startCol: UIColor, endCol: UIColor, startPoint: CGPoint, endPoint: CGPoint) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [startCol.cgColor, endCol.cgColor]
        self.layer.insertSublayer(gradient, at: 0)
        gradient.startPoint = startPoint;
        gradient.endPoint = endPoint;
    }
    
    /// Add simple fadeTransition for the duration
    ///
    /// - Parameter duration: duration
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation:CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            kCAMediaTimingFunctionEaseInEaseOut)
        animation.type = kCATransitionFade
        animation.duration = duration
        self.layer.add(animation, forKey: kCATransitionFade)
    }
    
    /// Custom corner radius
    ///
    /// - Parameters:
    ///   - corner: the corner to be rounded
    ///   - radius: radius
    public func customCornerRadius(_ corner: UIRectCorner, radius: CGSize) {
        let path = UIBezierPath(roundedRect:self.bounds, byRoundingCorners: corner, cornerRadii: radius)
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
    
    /// Set drop shadow for the view, if have corner radius then have to set it first
    /// Should call this during `viewDidLayoutSubview`
    ///
    /// - Parameters:
    ///   - shadowRadius: Shadow radius
    ///   - offset: Shadow offset
    public func setDropShadow(radius: CGFloat, offset: CGSize = .zero, color: UIColor? = nil) {
        layer.shadowRadius = radius;
        layer.masksToBounds = false;
        layer.shadowColor = (color ?? backgroundColor ?? tintColor).cgColor
        layer.shadowOffset = offset
        layer.shadowOpacity = 1
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius)
        layer.shadowPath = path.cgPath
    }
    
    public func getTopMostSuperView() -> UIView {
        if let v = self.superview {
            return v.getTopMostSuperView()
        }
        return self
    }
}

// MARK: - Some IBInspectable
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0 ? true : false
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var bgStartColor: UIColor? {
        get {
            return nil;
        }
        set {
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = self.bounds
            gradient.colors = [newValue!.cgColor, backgroundColor!.cgColor]
            self.layer.insertSublayer(gradient, at: 0)
            gradient.startPoint = CGPoint(x: 0.5, y: 0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1)
        }
    }
    
    //    @IBInspectable var bgStartColor: UIColor? {
    //        get {
    //            return objc_getAssociatedObject(self, &startGradientColorKey) as? UIColor
    //        }
    //        set(newValue) {
    //            objc_setAssociatedObject(self, &startGradientColorKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    //        }
    //    }
    //
    //    @IBInspectable var bgEndColor: UIColor? {
    //        get {
    //            return objc_getAssociatedObject(self, &endGradientColorKey) as? UIColor
    //        }
    //        set(newValue) {
    //            objc_setAssociatedObject(self, &endGradientColorKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    //        }
    //    }
}
