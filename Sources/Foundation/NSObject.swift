//
//  NSObject.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 7/23/18.
//

import Foundation

public extension NSObject {
    
    /// Allow stored object in extension, get
    ///
    /// - Parameter key: key
    /// - Returns: value
    func getAssociatedObject<T>(key: inout String, type: T.Type) -> T? {
        guard let value = objc_getAssociatedObject(self, &key) as? T else { return nil }
        return value
    }
    
    /// Allow stored object in extension, set, Swift types (closure, struct, tuples,..) have to be wrapped inside a NSObject class
    ///
    /// - Parameters:
    ///   - key: key
    ///   - value: value
    func setAssociatedObject(key: inout String, value: Any?) {
        objc_setAssociatedObject(self, &key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
