//
//  LocationHelper+Rx.swift
//  TVNExtensions
//
//  Created by TienVu on 2/14/19.
//

import Foundation
import RxSwift
import CoreLocation

extension Reactive where Base: LocationHelper {
    public var updateLocation: Single<CLLocation> {
        return Single.create(subscribe: { (observer) -> Disposable in
            self.base.update(completion: { (result) in
                switch result {
                case .success(loc: let loc):
                    observer(.success(loc))
                case .failed(error: let err, authStatus: _):
                    observer(.error(err))
                }
            })
        
            return Disposables.create()
        })
    }
    
    public var startMonitoring: Observable<CLLocation> {
        return Observable.create({ (observer) -> Disposable in
            self.base.startMonitoring(completion: { (result) in
                switch result {
                case .success(loc: let loc):
                    observer.onNext(loc)
                case .failed(error: let err, authStatus: _):
                    observer.onError(err)
                }
            })
            
            return Disposables.create()
        })
    }
}
