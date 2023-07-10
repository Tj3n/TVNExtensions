//
//  UIImagePicker+Rx.swift
//  TVNExtensions
//
//  Created by TienVu on 3/5/19.
//

import Foundation
import Photos
import RxSwift
import RxCocoa
import UIKit

///Authorization
extension PHPhotoLibrary {
    static public var authorized: Observable<Bool> {
        return Observable.create { observer in
            
            DispatchQueue.main.async {
                if authorizationStatus() == .authorized {
                    observer.onNext(true)
                    observer.onCompleted()
                } else {
                    observer.onNext(false)
                    requestAuthorization { newStatus in
                        observer.onNext(newStatus == .authorized)
                        observer.onCompleted()
                    }
                }
            }
            
            return Disposables.create()
        }
    }
}

///UIImagePickerController reactive extension
extension Reactive where Base: UIImagePickerController {
    static public func createWithParent(_ parent: UIViewController?,
                                 animated: Bool = true,
                                 configureImagePicker: @escaping (UIImagePickerController) throws -> () = { _ in })
        -> Observable<UIImagePickerController> {
            return Observable.create { [weak parent] observer in
                
                let imagePicker = UIImagePickerController()
                
                let dismissDisposable = Observable.merge(
                    imagePicker.rx.didFinishPickingMediaWithInfo.map{_ in ()},
                    imagePicker.rx.imagePickerControllerDidCancel
                    )
                    .subscribe(onNext: {  _ in
                        observer.on(.completed)
                    })
                
                do {
                    try configureImagePicker(imagePicker)
                }
                catch let error {
                    observer.on(.error(error))
                    return Disposables.create()
                }
                
                guard let parent = parent else {
                    observer.on(.completed)
                    return Disposables.create()
                }
                
                parent.present(imagePicker, animated: animated, completion: nil)
                observer.on(.next(imagePicker))
                
                return Disposables.create(dismissDisposable, Disposables.create {
                    dismissViewController(imagePicker, animated: animated)
                })
            }
    }
    
    public var pickerDelegate: DelegateProxy<UIImagePickerController, UIImagePickerControllerDelegate & UINavigationControllerDelegate > {
        return RxImagePickerDelegateProxy.proxy(for: base)
    }
    
    public var didFinishPickingMediaWithInfo: Observable<[UIImagePickerController.InfoKey: Any]> {
        return pickerDelegate
            .methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerController(_:didFinishPickingMediaWithInfo:)))
            .map { $0[1] as? [UIImagePickerController.InfoKey: Any] ?? [:] }
    }
    
    public var imagePickerControllerDidCancel: Observable<Void> {
        return pickerDelegate
            .methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerControllerDidCancel(_:)))
            .mapToVoid()
    }
}

func dismissViewController(_ viewController: UIViewController, animated: Bool) {
    if viewController.isBeingDismissed || viewController.isBeingPresented {
        DispatchQueue.main.async {
            dismissViewController(viewController, animated: animated)
        }
        return
    }
    
    if viewController.presentingViewController != nil {
        viewController.dismiss(animated: animated, completion: nil)
    }
}
