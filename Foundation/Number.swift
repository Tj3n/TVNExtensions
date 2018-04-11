//
//  FloatExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 7/20/16.
//  Copyright © 2016 Paymentwall. All rights reserved.
//

import Foundation

extension Float {
    public static func random(between small: Float, and big: Float) -> Float {
        let diff = big - small
        return ((Float(arc4random() % (UInt32(RAND_MAX) + 1))) / (Float(RAND_MAX)) * diff) + small
    }
}

extension Int {
    public static func random(between small: Int, and big: Int) -> Int {
        return Int(Float.random(between: Float(small), and: Float(big)))
    }
}

extension Double {
    public func toUSD() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: NSNumber(floatLiteral: self))
    }
    
    public func toRad() -> CGFloat {
        return CGFloat(self*Double.pi/180)
    }
}

extension CGFloat {
    public func toRad() -> CGFloat {
        return self*CGFloat.pi/180
    }
}

extension Decimal {
    public func round(to scale: Int) -> Decimal {
        var a: Decimal = 0
        var b = self
        NSDecimalRound(&a, &b, scale, .plain)
        return a
    }
}
