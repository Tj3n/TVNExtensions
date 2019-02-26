//
//  KeyboardNotificationRx.swift
//  TVNExtensions
//
//  Created by TienVu on 2/21/19.
//

import Foundation
import RxSwift

extension Reactive where Base: AnyObject {
    public func keyboardTracking() -> Observable<(height: CGFloat, duration: Double)> {
        return Observable.from([
            NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
                .map({ (notification) in
                    let deltaHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size.height
                    let duration = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as! NSNumber).doubleValue
                    return (deltaHeight, duration)
                }),
            NotificationCenter.default.rx.notification(UIResponder.keyboardDidShowNotification)
                .map({ (notification) in
                    let deltaHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size.height
                    let duration = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as! NSNumber).doubleValue
                    return (deltaHeight, duration)
                }),
            NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
                .map({ (notification) in
                    let duration = (notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as! NSNumber).doubleValue
                    return (0, duration)
                })
            ], scheduler: MainScheduler.instance)
            .merge()
    }
}
