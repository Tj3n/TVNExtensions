//
//  UIScrollViewExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 5/19/16.
//  Copyright © 2016 Paymentwall. All rights reserved.
//

import Foundation
import UIKit

public enum ScrollDirection {
    case none,
    crazy,
    left,
    right,
    up,
    down
}

extension UIScrollView {
    
    /// Setup refresh control
    ///
    /// - Parameters:
    ///   - tableView: tableView to add refresh control
    ///   - target: View controller contains tableView
    ///   - action: @objc func refresh(_ sender: UIRefreshControl)
    public func addRefreshControl(target: AnyObject, action: Selector) -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(target, action: action, for: .valueChanged)
        self.addSubview(refreshControl)
        return refreshControl
    }
    
    public func determineScrollDirection(_ startOffset: CGPoint, endOffset: CGPoint) -> ScrollDirection {
        var scrollDirection: ScrollDirection
        // If the scrolling direction is changed on both X and Y it means the
        // scrolling started in one corner and goes diagonal. This will be
        // called ScrollDirectionCrazy
        if startOffset.x != endOffset.x && startOffset.y != endOffset.y {
            scrollDirection = .crazy
        }
        else {
            if startOffset.x > endOffset.x {
                scrollDirection = .left
            }
            else if startOffset.x < endOffset.x {
                scrollDirection = .right
            }
            else if startOffset.y > endOffset.y {
                scrollDirection = .up
            }
            else if startOffset.y < endOffset.y {
                scrollDirection = .down
            }
            else {
                scrollDirection = .none
            }
        }
        return scrollDirection
    }
    
    public func killScroll() {
        self.isScrollEnabled = false
        self.isScrollEnabled = true
    }}
