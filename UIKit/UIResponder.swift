//
//  UIResponderExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 3/17/16.
//  Copyright © 2016 Tien Nhat Vu. All rights reserved.
//

import Foundation
import UIKit

extension UIResponder {
    
    //return current first responder (textfield)
    fileprivate weak static var _currentFirstResponder: UIResponder? = nil
    
    public class func currentFirstResponder() -> UIResponder? {
        UIResponder._currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(UIResponder.findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return UIResponder._currentFirstResponder
    }
    
    @objc internal func findFirstResponder(_ sender: AnyObject) {
        UIResponder._currentFirstResponder = self
    }
}
