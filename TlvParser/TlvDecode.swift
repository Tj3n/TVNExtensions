//
//  TlvDecode.swift
//  BlingTerminal
//
//  Created by Tien Nhat Vu on 12/28/17.
//  Copyright © 2017 Paymentwall. All rights reserved.
//

import Foundation

public enum TlvDecodeError: Error {
    case invalid
}

public struct TlvDecode {
    public static func decode(with tlv: String) throws -> [Tlv]  {
        if tlv.count % 2 != 0 {
            throw TlvDecodeError.invalid
        }
        var bytes = [Int]()
        
        for loc in stride(from: 0, to: tlv.count, by: 2) {
            let lower = tlv.index(tlv.startIndex, offsetBy: loc)
            let upper = tlv.index(lower, offsetBy: 2, limitedBy: tlv.endIndex) ?? tlv.endIndex
            let byte = String(tlv[lower..<upper])
            bytes.append(TlvDecode.hexToInt(byte))
        }
        return TlvDecode.decodeTlv(bytes)
    }
    
    static func decodeTlv(_ bytes: [Int]) -> [Tlv] {
        var tag = [Int]()
        var cursor: Int = 0
        let extent: Int = bytes.count
        var tagIsConstructed = true
        var actualLength: Int = 0
        var actualTag = ""
        var actualVal = ""
        
        var tlvs = [Tlv]()
        
        while cursor < extent {
            if bytes.count <= cursor {
                break
            }
            tag.append(bytes[cursor])
            let firstTag = tag[0]
            if !TlvTag.isValid(firstTag) {
                cursor += 1
                continue
            }
            tagIsConstructed = TlvTag.isConstructed(firstTag)
            if TlvTag.isMultiByte(firstTag) {
                cursor += 1
                if bytes.count <= cursor {
                    break
                }
                tag.append(bytes[cursor])
                let currentByte = Int(bytes[cursor])
                if !TlvTag.isLast(currentByte) {
                    cursor += 1
                    if bytes.count <= cursor {
                        break
                    }
                    tag.append(bytes[cursor])
                }
            }
            var fullTag = ""
            for num in tag {
                let hexStr = intToHex(num)
                fullTag = fullTag + (hexStr)
            }
            actualTag = fullTag
            tag.removeAll()
            cursor += 1
            
            ////// length
            if bytes.count <= cursor {
                break
            }
            let length = bytes[cursor]
            let intLength = Int(length)
            if !TlvLength.isValid(intLength) {
                break
            }
            let mylength: Int = TlvLength.getLength(intLength)
            actualLength = intLength
            if TlvLength.isMultiByte(intLength) {
                var length_cursor: Int = 0
                let length_extent: Int = mylength
                var tagLength = [Int]()
                while length_cursor < length_extent {
                    cursor += 1
                    if bytes.count <= cursor {
                        break
                    }
                    let tmp = Int(bytes[cursor]) << ((length_extent - length_cursor - 1) * 8)
                    tagLength.append(tmp)
                    length_cursor += 1
                }
                if bytes.count <= cursor {
                    break
                }
                var length_output: Int = 0
                for length_part in tagLength {
                    length_output = length_output | length_part
                }
                actualLength = length_output
            }
            cursor += 1
            
            /////value
            if bytes.count <= cursor {
                break
            }
            
            let value = Array(bytes[cursor..<cursor+actualLength])
            
            var newVal: [Tlv]?
            if tagIsConstructed {
                newVal = TlvDecode.decodeTlv(value)
            }
            
            var fullVal = ""
            for num in value {
                let hexStr = intToHex(num)
                fullVal = fullVal + (hexStr)
            }
            actualVal = fullVal
            
            cursor += actualLength
            
            let tlv = Tlv(tag: actualTag, name: TlvTag.getName(tag: actualTag), value: actualVal, length: actualLength, subTags: newVal)
            tlvs.append(tlv)
        }
        return tlvs
    }
    
    public static func hexToString(_ hex: String) -> String {
        let regex = try! NSRegularExpression(pattern: "(0x)?([0-9A-Fa-f]{2})", options: .caseInsensitive)
        let textNS = hex as NSString
        let matchesArray = regex.matches(in: textNS as String, options: [], range: NSMakeRange(0, textNS.length))
        let characters = matchesArray.map {
            Character(UnicodeScalar(UInt32(textNS.substring(with: $0.range(at:2)), radix: 16)!)!)
        }
        
        return String(characters)
    }
    
    public static func hexToInt(_ hex: String) -> Int {
        return Int(Int32(hex, radix: 16)!)
    }
    
    public static func intToHex(_ num: Int) -> String {
        return String(format: "%02lX", UInt(num))
    }
}
