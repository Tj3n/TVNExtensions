//
//  DispatchQueue+.swift
//  TVNExtensions
//
//  Created by Vũ Tiến on 3/16/20.
//

import Foundation

public extension DispatchQueue {
    private static var _onceTracker = Set<String>()
    
    /// Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
    /// only execute the code once even in the presence of multithreaded calls. Automatically create token from code block.
    /// - Parameters:
    ///   - block: Block to execute once
    class func once(file: String = #file,
                    function: String = #function,
                    line: Int = #line,
                    block: () -> Void) {
        let token = "\(file):\(function):\(line)"
        once(token: token, block: block)
    }
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.<spaceName>.<name> or a GUID
     - parameter block: Block to execute once
     */
    class func once(token: String,
                    block: () -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        guard !_onceTracker.contains(token) else { return }
        
        _onceTracker.insert(token)
        block()
    }
}
