//
//  UILabelExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 6/27/16.
//  Copyright © 2016 Paymentwall. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    class func showTooltip(_ message: String, fontName: String) {
        
        guard let font = UIFont(name: fontName, size: 14) else {
            return
        }
        
        var isLong = false
        
        let fontAttributes = [NSAttributedStringKey.font: font]
        let size = (" "+message+" " as NSString).size(withAttributes: fontAttributes)
        
        DispatchQueue.main.async(execute: {
            
            var width = size.width+25
            var height = size.height+15
            
            if width > (UIApplication.shared.keyWindow?.frame.size.width)! {
                width = (UIApplication.shared.keyWindow?.frame.size.width)! - 25
                let sizeOfText = (message as NSString).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading], attributes: fontAttributes, context: nil)
                height = sizeOfText.height + 25
                
                isLong = true
            }
            
            let label = UILabel(frame: CGRect(x: 0,y: 0, width: width, height: height))
            label.textAlignment = .center
            label.font = font
            label.textColor = UIColor.white
            label.text = message
            label.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height-UIScreen.main.bounds.height/5)
            label.alpha = 0
            label.isUserInteractionEnabled = false
            label.backgroundColor = UIColor ( red: 0.2, green: 0.2, blue: 0.2, alpha: 0.6 )
            label.layer.masksToBounds = true
            label.layer.cornerRadius = 7
            label.numberOfLines=0
            
            let shadowView = UIView()
            shadowView.layer.shadowRadius = 2
            shadowView.layer.cornerRadius = 7
            shadowView.layer.shadowColor = UIColor.darkGray.cgColor
            shadowView.layer.shadowOpacity = 0.5
            shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
            shadowView.frame = label.frame
            shadowView.center = label.center
            let shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 7)
            shadowView.layer.shadowPath = shadowPath.cgPath
            shadowView.alpha = 0
            
            let topWindow = UIApplication.shared.keyWindow
            topWindow!.addSubview(shadowView)
            topWindow!.addSubview(label)
            topWindow?.bringSubview(toFront: label)
            
            UIView.animate(withDuration: 0.5, animations: {
                shadowView.originY -= 10
                label.originY -= 10
                shadowView.alpha = 1
                label.alpha = 1
            }, completion: { (complete) in
                let time: Double = isLong ? 3 : 2
                let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                    UIView.animate(withDuration: 0.5, animations: {
                        shadowView.originY += 10
                        label.originY += 10
                        label.alpha = 0
                        shadowView.alpha = 0
                        }, completion: { (completed) in
                            label.removeFromSuperview()
                            shadowView.removeFromSuperview()
                    })
                })
            }) 
            
        });
    }
    
    @objc public var substituteFontName : String {
        get { return self.font.fontName }
        set {
            let fontNameToTest = self.font.fontName.lowercased();
            var fontName = newValue;
            if fontNameToTest.contains("bold") {
                fontName += "-Bold";
            } else if fontNameToTest.contains("medium") {
                fontName += "-Medium";
            } else if fontNameToTest.contains("light") {
                fontName += "-Light";
            } else if fontNameToTest.contains("ultralight") {
                fontName += "-UltraLight";
            } else if fontNameToTest.contains("semibold") {
                fontName += "-SemiBold";
            } else {
                fontName += "-Regular"
            }
            self.font = UIFont(name: fontName, size: self.font.pointSize)
        }
    }
}
