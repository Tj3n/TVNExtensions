//
//  UILabelExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 6/27/16.
//  Copyright © 2016 Tien Nhat Vu. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    private static let tooltipLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height-UIScreen.main.bounds.height/5)
        label.alpha = 0
        label.isUserInteractionEnabled = false
        label.backgroundColor = UIColor ( red: 0.2, green: 0.2, blue: 0.2, alpha: 0.6 )
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 7
        label.numberOfLines=0
        return label
    }()
    
    private static let tooltipTextAttributes: [NSAttributedString.Key: Any]? = {
        guard let style = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle else {
            return nil
        }
        style.alignment = .center
        style.firstLineHeadIndent = 10.0
        style.headIndent = 10.0
        style.tailIndent = -10.0
        return [NSAttributedString.Key.paragraphStyle: style]
    }()
    
    private static let tooltipShadowView: UIView = {
        let shadowView = UIView()
        shadowView.layer.shadowRadius = 2
        shadowView.layer.cornerRadius = 7
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        return shadowView
    }()
    
    public class func showErrorTooltip(_ message: String,
                                       font: UIFont = UIFont.systemFont(ofSize: 14),
                                       duration: Double = 3) {
        UILabel.showTooltip(message, font: font, duration: duration, textColor: UIColor(hexString: "F72B1C"))
    }
    
    public class func showTooltip(_ message: String,
                                  font: UIFont = UIFont.systemFont(ofSize: 14),
                                  duration: Double = 3,
                                  textColor: UIColor = .white,
                                  backgroundShadowColor: CGColor = UIColor.darkGray.cgColor) {
        
        DispatchQueue.global().async {
            var textAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: textColor]
            let fontAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
            let size = (" "+message+" " as NSString).size(withAttributes: fontAttributes)
            
            var width = size.width+25
            var height = size.height+15
            
            let screenW = UIScreen.main.bounds.width
            let screenH = UIScreen.main.bounds.height
            
            if width > screenW {
                width = screenW - 25
                let sizeOfText = (message as NSString).boundingRect(with: CGSize(width: width,
                                                                                 height: CGFloat.greatestFiniteMagnitude),
                                                                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                                    attributes: fontAttributes, context: nil)
                height = sizeOfText.height + 25
            }
            
            if let tooltipTextAttributes = tooltipTextAttributes {
                textAttributes.merge(tooltipTextAttributes, uniquingKeysWith: { (current, _) in current })
            }
            
            textAttributes.merge(fontAttributes, uniquingKeysWith: { (current, _) in current })
            
            let attributedMessage = NSAttributedString(string: message, attributes: textAttributes)
            
            DispatchQueue.main.async {
                let label = tooltipLabel
                let shadowView = tooltipShadowView
                
                label.frame = CGRect(x: 0,y: 0, width: width, height: height)
                label.center = CGPoint(x: screenW/2, y: screenH-screenH/5)
                label.attributedText = attributedMessage
                
                shadowView.frame = label.frame
                shadowView.center = label.center
                shadowView.layer.shadowColor = backgroundShadowColor
                let shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 7)
                shadowView.layer.shadowPath = shadowPath.cgPath
                shadowView.alpha = 0
                
                let topWindow = UIApplication.shared.keyWindow
                topWindow?.addSubview(shadowView)
                topWindow?.addSubview(label)
                topWindow?.bringSubviewToFront(label)
                
                UIView.animate(withDuration: 0.5, animations: {
                    shadowView.originY -= 10
                    label.originY -= 10
                    shadowView.alpha = 1
                    label.alpha = 1
                }, completion: { (complete) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        UIView.animate(withDuration: 0.5, animations: {
                            shadowView.originY += 10
                            label.originY += 10
                            label.alpha = 0
                            shadowView.alpha = 0
                        }, completion: { (completed) in
                            label.removeFromSuperview()
                            shadowView.removeFromSuperview()
                        })
                    }
                })
            }
        }
    }
    
    /// Change font for whole app, keep size, type, can be use with UILabel.appearance(), ignore attributedText
    @objc dynamic public var substituteFontName : String {
        get { return self.font.fontName }
        set {
            if let attrText = self.attributedText, attrText.string != self.text {
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
    
    private static let tvnSystemFontTextName = ".sfui"
    
    /// Replace ONLY system font with font name, keep size and type, can be use with UILabel.appearance(), ignore attributedText
    @objc dynamic public var substituteSystemFontName : String {
        get { return self.font.fontName }
        set {
            if let attrText = self.attributedText, attrText.string != self.text {
                return
            }
            
            let fontNameToTest = self.font.description.lowercased()+self.font.fontName.lowercased()
            guard fontNameToTest.contains(UILabel.tvnSystemFontTextName) else {
                return
            }
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
}
