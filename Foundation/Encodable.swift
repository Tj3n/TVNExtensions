//
//  Encodable.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 5/8/18.
//

import Foundation

public extension Encodable {
    public subscript(key: String) -> Any? {
        return getDictionary()[key]
    }
    
    public func getData(encoder: JSONEncoder = JSONEncoder()) -> Data?  {
        return try? encoder.encode(self)
    }
    
    public func getDictionary(encoder: JSONEncoder = JSONEncoder()) -> [String: Any] {
        guard let data = getData(encoder: encoder) else { return [:] }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
    }
}
