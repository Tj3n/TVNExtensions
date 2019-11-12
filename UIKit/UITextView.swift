//
//  UITextView.swift
//  TVNExtensions
//
//  Created by Vũ Tiến on 11/12/19.
//

import Foundation
import UIKit

public extension UITextView {
    func removePadding() {
        textContainerInset = UIEdgeInsets( top: 0, left: -textContainer.lineFragmentPadding, bottom: 0, right: -textContainer.lineFragmentPadding)
    }
}
