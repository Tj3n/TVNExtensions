//
//  TlvLength.swift
//  BlingTerminal
//
//  Created by Tien Nhat Vu on 12/28/17.
//  Copyright © 2017 Paymentwall. All rights reserved.
//

import Foundation

struct TlvLength {
    static func isValid(_ byte: Int) -> Bool {
        if byte != 0x80 && byte >= 0x00 && byte <= 0x84 {
            return true
        }
        return false
    }
    
    static func getLength(_ byte: Int) -> Int {
        return byte & 0x7f
    }
    
    static func isMultiByte(_ byte: Int) -> Bool {
        return 0x01 == (byte >> 7)
    }
}
