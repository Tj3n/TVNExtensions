//
//  Enum.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 6/26/18.
//

import Foundation

@available(swift, deprecated: 4.2, message: "Please use CaseIterable instead")
public protocol EnumCollection: Hashable {
    static func cases() -> AnySequence<Self>
    static var allValues: [Self] { get }
}

@available(swift, deprecated: 4.2, message: "Please use CaseIterable instead")
public extension EnumCollection {
    
    public static func cases() -> AnySequence<Self> {
        return AnySequence { () -> AnyIterator<Self> in
            var raw = 0
            return AnyIterator {
                let current: Self = withUnsafePointer(to: &raw) { $0.withMemoryRebound(to: self, capacity: 1) { $0.pointee } }
                guard current.hashValue == raw else {
                    return nil
                }
                raw += 1
                return current
            }
        }
    }
    
    public static var allValues: [Self] {
        return Array(self.cases())
    }
}
