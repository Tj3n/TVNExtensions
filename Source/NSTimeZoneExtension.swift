//
//  NSTimeZoneExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 7/29/16.
//  Copyright © 2016 Paymentwall. All rights reserved.
//

import Foundation

extension TimeZone {
    
    public static func currentTimeZone() -> Double {
        return Double(NSTimeZone.system.secondsFromGMT()) / 3600.0
        
    }
}
