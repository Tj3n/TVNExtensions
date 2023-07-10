//
//  CodeScannerView+Rx.swift
//  TVNExtensions
//
//  Created by TienVu on 2/14/19.
//

import Foundation
import RxSwift
import TVNExtensions

extension Reactive where Base: CodeScannerView {
    public var startReading: Observable<String> {
        return Observable.create({ (observer) -> Disposable in
            self.base.scanCompleteBlock = { message, error in
                if let message = message {
                    observer.onNext(message)
                    observer.onCompleted()
                } else if let error = error {
                    observer.onError(NSError(domain: TVNErrorDomain, code: 500, userInfo: [NSLocalizedDescriptionKey: error]))
                }
            }
            
            self.base.startReading(completion: { (error) in
                if let error = error {
                    observer.onError(error)
                }
            })
            
            return Disposables.create()
        })
    }
}
