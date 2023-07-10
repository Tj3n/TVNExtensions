//
//  CollectionExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 1/6/17.
//  Copyright © 2017 Tien Nhat Vu. All rights reserved.
//

import Foundation

public extension Collection {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public extension Array {
    func write(to url: URL, atomically: Bool = true) -> Bool{
        let array = self as NSArray
        return array.write(to: url, atomically: atomically)
    }
    
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
