//
//  RxQLPreviewControllerDelegateProxy.swift
//  TVNExtensions
//
//  Created by TienVu on 3/5/19.
//

import Foundation
import RxSwift
import RxCocoa
import QuickLook

extension QLPreviewController: HasDelegate {
    
}

open class RxQLPreviewControllerDelegateProxy:
    DelegateProxy<QLPreviewController, QLPreviewControllerDelegate>,
    DelegateProxyType,
    QLPreviewControllerDelegate {
    
    init(controller: QLPreviewController) {
        super.init(parentObject: controller, delegateProxy: RxQLPreviewControllerDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        return self.register (make: RxQLPreviewControllerDelegateProxy.init(controller:))
    }
}
