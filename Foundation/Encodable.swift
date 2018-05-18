//
//  Encodable.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 5/8/18.
//

import Foundation

extension Encodable {
    public subscript(key: String) -> Any? {
        return getDictionary()[key]
    }
    
    public func getData(encoder: JSONEncoder = JSONEncoder()) -> Data?  {
        return try? encoder.encode(self)
    }
    
    public func getDictionary(encoder: JSONEncoder = JSONEncoder(), withStringValueType: Bool = false) -> [String: Any] {
        guard let data = getData(encoder: encoder) else { return [:] }
        let dict = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
        
        guard withStringValueType else { return dict }
        
        return dict.map({ ($0.0, convertToString(from: $0.1)) }).reduce(into: [:], { $0[$1.0] = $1.1 })
    }
    
    func convertToString(from value: Any) -> String {
        if let value = value as? String {
            return value
        } else if let value = value as? LosslessStringConvertible {
            return value.description
        } else if let value = value as? CustomStringConvertible {
            return value.description
        }
        return ""
    }
}
