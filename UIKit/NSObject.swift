//
//  NSObject.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 7/23/18.
//

import Foundation

extension NSObject {
    
    /// Allow stored object in extension, get
    ///
    /// - Parameter key: key
    /// - Returns: value
    public func getAssociatedObject<T>(key: inout String, type: T.Type) -> T? {
        guard let value = objc_getAssociatedObject(self, &key) as? T else { return nil }
        return value
    }
    
    /// Allow stored object in extension, set
    ///
    /// - Parameters:
    ///   - key: key
    ///   - value: value
    public func setAssociatedObject(key: inout String, value: Any?) {
        objc_setAssociatedObject(self, &key, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
