//
//  RxImagePickerDelegateProxy.swift
//  TVNExtensions
//
//  Created by TienVu on 3/5/19.
//

import Foundation
import RxCocoa
import TVNExtensions
import UIKit

///RxImagePickerDelegateProxy
public class RxImagePickerDelegateProxy:
    DelegateProxy<UIImagePickerController, UIImagePickerControllerDelegate & UINavigationControllerDelegate>,
    DelegateProxyType,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {
    
    public init(imagePicker: UIImagePickerController) {
        super.init(parentObject: imagePicker, delegateProxy: RxImagePickerDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxImagePickerDelegateProxy(imagePicker: $0) }
    }
    
    public static func currentDelegate(for object: UIImagePickerController)
        -> (UIImagePickerControllerDelegate & UINavigationControllerDelegate)? {
            return object.delegate
    }
    
    public static func setCurrentDelegate(_ delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?,
                                          to object: UIImagePickerController) {
        object.delegate = delegate
    }
}
