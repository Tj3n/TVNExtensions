//
//  FloatExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 7/20/16.
//  Copyright © 2016 Tien Nhat Vu. All rights reserved.
//

import Foundation

extension FloatingPoint {
    public static func random(in range: ClosedRange<Self>) -> Self {
        return random(between: range.lowerBound, and: range.upperBound)
    }
    
    public static func random(between small: Self, and big: Self) -> Self {
        let diff = big - small
        return ((Self(arc4random() % (UInt32(RAND_MAX) + 1))) / (Self(RAND_MAX)) * diff) + small
    }
    
    public func fastFloor() -> Self { return floor(self) }
    
    public func toRad() -> Self {
        return self*Self.pi/180
    }
    
    public func toDegree() -> Self {
        return self*180/Self.pi
    }
}

extension Int {
    public static func random(in range: ClosedRange<Int>) -> Int {
        return random(between: range.lowerBound, and: range.upperBound)
    }
    
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
    
    func toKm() -> Self {
        return self/1000.0
    }
    
    func toMiles() -> Self {
        return self/1609.344
    }
    
    func toFeet() -> Self {
        return self*3.281
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
