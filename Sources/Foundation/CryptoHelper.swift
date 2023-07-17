//
//  CryptoHelper.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 12/19/17.
//

import Foundation

public struct CryptoHelper {
    public static func SHA256ToHex(with dict: [String: String], salt: String?) -> String {
        let keys = dict.keys.sorted()
        var signStr = ""
        for i in 0..<keys.count {
            signStr.append("\(keys[i])=\(dict[keys[i]]!)")
        }
        if let salt = salt {
            signStr.append(salt)
        }
        return signStr.data(using: .utf8)!.SHA256().toHexString()
    }
    
    @available(iOS, deprecated: 13.0)
    public static func MD5ToHex(string: String) -> String {
        let data = string.data(using: .utf8)!
        return data.MD5().toHexString()
    }
}
