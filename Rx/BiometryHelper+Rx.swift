//
//  BiometryHelper+Rx.swift
//  
//
//  Created by TienVu on 11/28/18.
//

import Foundation
import RxSwift
import TVNExtensions

extension BiometryHelper: ReactiveCompatible {
    
}

extension Reactive where Base: BiometryHelper {
    public static func authenticateUser(with reasonStr: String?) -> Completable {
        return Completable.create(subscribe: { (observer) -> Disposable in

            BiometryHelper.authenticateUser(with: reasonStr, completion: { (success, error) in
                guard success else {
                    observer(.error(error ?? RxError.unknown))
                    return
                }
                observer(.completed)
            })
            
            return Disposables.create()
        })
    }
}
