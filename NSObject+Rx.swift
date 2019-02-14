//
//  NSObject+Rx.swift
//  TVNExtensions
//
//  Created by TienVu on 2/14/19.
//

import Foundation
import RxSwift

///Convenience bag for NSObject classes(eg. UIViewController), for all reference types use [pod 'NSObject+Rx']
extension NSObject {
    private struct AssociatedKeys {
        static var _disposeBagKey = "com.tvn.disposeBagKey"
    }
    
    public var bag: DisposeBag {
        get {
            if let bag = getAssociatedObject(key: &AssociatedKeys._disposeBagKey, type: DisposeBag.self) {
                return bag
            }
            let bag = DisposeBag()
            setAssociatedObject(key: &AssociatedKeys._disposeBagKey, value: bag)
            return bag
            
        }
        set(newValue) { setAssociatedObject(key: &AssociatedKeys._disposeBagKey, value: newValue) }
    }
}
