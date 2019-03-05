//
//  RxQLPreviewControllerDataSourceProxy.swift
//  TVNExtensions
//
//  Created by TienVu on 3/5/19.
//

import Foundation
import RxSwift
import RxCocoa
import QuickLook

extension QLPreviewController: HasDataSource {
    
}

open class RxQLPreviewControllerDataSourceProxy
    : DelegateProxy<QLPreviewController, QLPreviewControllerDataSource>
    , DelegateProxyType
    , QLPreviewControllerDataSource {
    
    public weak private(set) var previewController: QLPreviewController?
    
    public init(previewController: QLPreviewController) {
        self.previewController = previewController
        super.init(parentObject: previewController, delegateProxy: RxQLPreviewControllerDataSourceProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxQLPreviewControllerDataSourceProxy(previewController: $0) }
    }
    
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return _forwardToDelegate?.numberOfPreviewItems(in: controller) ?? 0
    }
    
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        guard let dataSource = _forwardToDelegate else {
            fatalError("QLPreviewControllerDataSource is not set")
        }
        return dataSource.previewController(controller, previewItemAt: index)
    }
}
