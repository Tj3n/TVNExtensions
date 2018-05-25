//
//  DelegateHelper.swift
//  Mockingjay
//
//  Created by Tien Nhat Vu on 5/17/18.
//

import Foundation

/***
 Use this object to remove the needs of [unowned self] or [weak self] in closure delegate callback
 How to use:
 
 class TransactionViewModel {
 
    var dataFetchedHandler = DelegateHelper<Data, Void>()
 
    func doSomething() {
        // Get some stuff and execute delegate callback
        dataFetchedHandler.call(data)
    }
 }
 
 class ViewController: UIViewController {
 
    var viewModel = ViewModel()
 
    override func viewDidLoad() {
        super.viewDidLoad()
 
        //Register for delegate
        viewModel.dataFetchedHandler.delegate(to: self) { (self, data) in
            self.tableView.reloadData()
    }
 }
***/
public struct DelegateHelper<I, O> {
    
    private(set) var handler: ((I) -> O?)?
    
    public init() {
        
    }
    
    /// Execute delegate callback
    ///
    /// - Parameter input: input
    /// - Returns: output
    public func call(_ input: I) -> O? {
        return handler?(input)
    }
    
    /// Remove delegate
    public mutating func removeDelegate() {
        handler = nil
    }
    
    /// Register T to be a weak delegate
    ///
    /// - Parameters:
    ///   - target: delegate
    ///   - handler: the callback
    mutating public func delegate<T: AnyObject>(to target: T, handler: @escaping ((T, I) -> O)) {
        self.handler = { [weak target] input in
            guard let target = target else {
                return nil
            }
            return handler(target, input)
        }
    }

    /// Register T to be strong delegate
    ///
    /// - Parameters:
    ///   - target: delegate
    ///   - handler: the callback
    mutating public func strongDelegate<T: AnyObject>(to target: T, handler: @escaping ((T, I) -> O)) {
        self.handler = { input in
            return handler(target, input)
        }
    }
}

extension DelegateHelper where I == Void {
    mutating public func delegate<T: AnyObject>(to target: T, handler: @escaping ((T) -> O)) {
        self.handler = { [weak target] input in
            guard let target = target else {
                return nil
            }
            return handler(target)
        }
    }
    
    mutating public func strongDelegate<T: AnyObject>(to target: T, handler: @escaping ((T) -> O)) {
        self.handler = { input in
            return handler(target)
        }
    }
    
    public func call() -> O? {
        return self.call(())
    }
}

extension DelegateHelper where O == Void {
    public func call(_ input: I) {
        handler?(input)
    }
}

extension DelegateHelper where I == Void, O == Void {
    public func call() {
        self.call(())
    }
}
