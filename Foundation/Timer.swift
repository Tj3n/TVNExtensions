//
//  Timer.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 4/10/18.
//

import Foundation

extension Timer {
    @discardableResult
    static public func scheduledTimer(timeInterval: TimeInterval, repeats: Bool, operationBlock: (Timer)->()) -> Timer {
        return Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(executeBlock(timer:)), userInfo: operationBlock, repeats: repeats)
    }
    
    @objc static func executeBlock(timer: Timer) {
        if let closure = timer.userInfo as? (Timer) -> () {
            closure(timer)
        }
    }
}
