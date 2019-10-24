//
//  Data.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 8/8/18.
//

import Foundation
import CommonCrypto

extension Data {
    public func SHA256() -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, UInt32(self.count), &hash)
        }
        return Data(hash)
    }
    
    public func MD5() -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_MD5_DIGEST_LENGTH))
        self.withUnsafeBytes {
            _ = CC_MD5($0.baseAddress, UInt32(self.count), &hash)
        }
        return Data(hash)
    }
    
    public func toHexString() -> String {
        return self.map { String(format: "%02hhx", $0) }.joined()
    }
}
