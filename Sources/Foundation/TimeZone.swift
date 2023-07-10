//
//  NSTimeZoneExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 7/29/16.
//  Copyright © 2016 Tien Nhat Vu. All rights reserved.
//

import Foundation

extension TimeZone {
    public static let gmt: TimeZone = {
        return TimeZone(abbreviation: "GMT")!
    }()
    
    public static func currentTimeZone() -> Double {
        return Double(NSTimeZone.system.secondsFromGMT()) / 3600.0
    }
}
