//
//  DictionaryExtension.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 11/17/17.
//

import Foundation

extension Dictionary where Key == String, Value == String {
    
    /// Sort keys then parse into string as `key=string` format, optionally add `&` between
    ///
    /// - Parameter withAndCharacter: optionally add `&` between pairs
    /// - Returns: POST request body ready string object or sign string
    public func sortToString(withAndCharacter: Bool) -> String {
        let arr = self.keys.sorted().map({ "\($0)=\(self[$0]!)" })
        return withAndCharacter ? arr.joined(separator: "&") : arr.joined()
    }
}
