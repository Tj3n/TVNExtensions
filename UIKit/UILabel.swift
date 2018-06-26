//
//  UILabelExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 6/27/16.
//  Copyright © 2016 Paymentwall. All rights reserved.
//

import Foundation
import UIKit

fileprivate let tvnSystemFontTextName = ".SFUIText"
fileprivate let tvnSystemFontDisplayName = ".SFUIDisplay"

extension UILabel {
    public class func showTooltip(_ message: String, fontName: String) {
        
        var font: UIFont
        if let customFont = UIFont(name: fontName, size: 14) {
            font = customFont
        } else {
            font = UIFont.systemFont(ofSize: 14)
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
    
    /// Change font for whole app, keep size, type, can be use with UILabel.appearance(), ignore attributedText
    @objc dynamic public var substituteFontName : String {
        get { return self.font.fontName }
        set {
            if let _ = self.attributedText {
                return
            }
            
            let fontNameToTest = self.font.fontName.lowercased();
            var subFontName = newValue
            
            if fontNameToTest.contains("italic") {
                subFontName += "-Italic";
            } else if fontNameToTest.contains("ultralight") {
                subFontName += "-UltraLight";
            }  else if fontNameToTest.contains("thin") {
                subFontName += "-Thin";
            } else if fontNameToTest.contains("light") {
                subFontName += "-Light";
            } else if fontNameToTest.contains("semibold") {
                subFontName += "-SemiBold";
            } else if fontNameToTest.contains("medium") {
                subFontName += "-Medium";
            } else if fontNameToTest.contains("bold") {
                subFontName += "-Bold";
            }  else if fontNameToTest.contains("heavy") {
                subFontName += "-Heavy";
            }  else if fontNameToTest.contains("black") {
                subFontName += "-Black";
            } else {
                subFontName += "-Regular"
            }
            self.font = UIFont(name: subFontName, size: self.font.pointSize)
        }
    }
    
    /// Replace ONLY system font with font name, keep size and type, can be use with UILabel.appearance(), ignore attributedText
    ///
    /// - Parameter fontName: Font to replace
    @objc dynamic public func replaceSystemFont(with fontName: String) {
        if let _ = self.attributedText {
            return
        }
        
        let fontNameToTest = self.font.fontName.lowercased()
        guard fontNameToTest.contains(tvnSystemFontTextName) || fontNameToTest.contains(tvnSystemFontDisplayName) else {
            return
        }

        var subFontName = fontName
        
        if fontNameToTest.contains("italic") {
            subFontName += "-Italic";
        } else if fontNameToTest.contains("ultralight") {
            subFontName += "-UltraLight";
        }  else if fontNameToTest.contains("thin") {
            subFontName += "-Thin";
        } else if fontNameToTest.contains("light") {
            subFontName += "-Light";
        } else if fontNameToTest.contains("semibold") {
            subFontName += "-SemiBold";
        } else if fontNameToTest.contains("medium") {
            subFontName += "-Medium";
        } else if fontNameToTest.contains("bold") {
            subFontName += "-Bold";
        }  else if fontNameToTest.contains("heavy") {
            subFontName += "-Heavy";
        }  else if fontNameToTest.contains("black") {
            subFontName += "-Black";
        } else {
            subFontName += "-Regular"
        }
        
        self.font = UIFont(name: subFontName, size: self.font.pointSize)
    }
}
