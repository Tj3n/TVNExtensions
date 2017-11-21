//
//  NSDecimalNumberExtension.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 11/16/17.
//

import Foundation

extension Decimal {
    public func round(to scale: Int) -> Decimal {
        var a: Decimal = 0
        var b = self
        NSDecimalRound(&a, &b, scale, .plain)
        return a
        
//        let handler = NSDecimalNumberHandler(roundingMode: .plain, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
//        return ((self as NSDecimalNumber).rounding(accordingToBehavior: handler)) as Decimal
    }
}
