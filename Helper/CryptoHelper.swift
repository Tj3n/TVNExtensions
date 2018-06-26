//
//  CryptoHelper.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 12/19/17.
//

import Foundation
import CCommonCrypto

public struct CryptoHelper {
    public static func SHA256(data : Data) -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(data.count), &hash)
        }
        return Data(bytes: hash)
    }
    
    public static func SHA256(with dict: [String: String], salt: String?) -> String {
        var keys = dict.keys.sorted()
        var signStr = ""
        for i in 0..<keys.count {
            signStr.append("\(keys[i])=\(dict[keys[i]]!)")
        }
        if let salt = salt {
            signStr.append(salt)
        }
        return hexStringFromData(input: SHA256(data: signStr.data(using: .utf8)!))
    }
    
    public static func MD5(string: String) -> Data {
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        return digestData
    }
    
    public static func MD5ToHex(string: String) -> String {
        return hexStringFromData(input: MD5(string: string))
    }
    
    private static func hexStringFromData(input: Data) -> String {
        return input.map { String(format: "%02hhx", $0) }.joined()
    }
}
