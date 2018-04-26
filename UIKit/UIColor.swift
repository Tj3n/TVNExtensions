//
//  UIColorExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 3/28/16.
//  Copyright © 2016 Paymentwall. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    /**
     UIColor from hex and alpha
     */
    public convenience init(hexString: String, alpha: CGFloat = 1) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let  r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            ( r, g, b) = ( (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b) = ( int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            ( r, g, b) = ( int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            ( r, g, b) = ( 1, 1, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(alpha))
    }
    
    /**
     UIColor from rgb and alpha
     */
    public convenience init(r: UInt32, g: UInt32, b: UInt32, alpha: CGFloat = 1) {
        var a: CGFloat = alpha
        if a > 1 {
            a = 1
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a))
    }
}
