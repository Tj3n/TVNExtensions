//
//  Tlv.swift
//  BlingTerminal
//
//  Created by Tien Nhat Vu on 12/28/17.
//  Copyright © 2017 Paymentwall. All rights reserved.
//

import Foundation

public struct Tlv {
    public let tag: String
    public let name: String
    public let value: String
    public let length: Int
    public let subTags: [Tlv]?
    
    public var rawValue: String {
        get {
            return "\(tag)\(TlvDecode.intToHex(length))\(value)"
        }
    }
}
