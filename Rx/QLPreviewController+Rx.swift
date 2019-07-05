//
//  QLPreviewController+Rx.swift
//  TVNExtensions
//
//  Created by TienVu on 3/5/19.
//

import Foundation
import RxSwift
import RxCocoa
import QuickLook

public protocol RxQLPreviewControllerDataSourceType {
    associatedtype Element
    func previewController(_ controller: QLPreviewController, observedEvent: Event<Element>) -> Void
}

public class RxQLPreviewControllerDataSource<I: QLPreviewItem>: QLPreviewControllerDataSource, RxQLPreviewControllerDataSourceType {
    
    public typealias Element = [I]
    var items = [I]()
    
    public init() {
        
    }
    
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return items.count
    }
    
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return items[index]
    }
    
    public func previewController(_ controller: QLPreviewController, observedEvent: Event<[I]>) {
        Binder(self) { dataSource, items in
            dataSource.items = items
            controller.reloadData()
            }
            .on(observedEvent)
    }
}

extension Reactive where Base: QLPreviewController {
    public var delegate: DelegateProxy<QLPreviewController, QLPreviewControllerDelegate> {
        return RxQLPreviewControllerDelegateProxy.proxy(for: base)
    }
    
    public func items<
        DataSource: RxQLPreviewControllerDataSourceType & QLPreviewControllerDataSource,
        O: ObservableType>
        (dataSource: DataSource)
        -> (_ source: O)
        -> Disposable
        where DataSource.Element == O.Element {
            return { source in
                let unregisterDelegate = RxQLPreviewControllerDataSourceProxy
                    .installForwardDelegate(dataSource,
                                            retainDelegate: true,
                                            onProxyForObject: self.base)
                
                let subscription = source
                    .observeOn(MainScheduler())
                    .catchError { error in
                        return Observable.empty()
                    }
                    .concat(Observable.never())
                    .takeUntil(self.base.rx.deallocated)
                    .subscribe({ [weak controller = self.base](event) in
                        guard let controller = controller else { return }
                        dataSource.previewController(controller, observedEvent: event)
                    })
                
                return Disposables.create {
                    subscription.dispose()
                    unregisterDelegate.dispose()
                }
            }
    }
}
