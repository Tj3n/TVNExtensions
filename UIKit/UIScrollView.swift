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
    
    public func scrollToTop(animated: Bool, additionalOffsetY: CGFloat = 0) {
        self.setContentOffset(CGPoint(x: contentOffset.x, y: additionalOffsetY), animated: animated)
    }
    
    public func scrollToBottom(animated: Bool, additionalOffsetY: CGFloat = 0) {
        var bottomOffsetY: CGFloat = 0
        if #available(iOS 11.0, *) {
            bottomOffsetY = max(self.contentSize.height - self.bounds.height + self.contentInset.bottom + self.safeAreaInsets.bottom + additionalOffsetY, 0)
        } else {
            bottomOffsetY = max(self.contentSize.height - self.bounds.height + self.contentInset.bottom + additionalOffsetY, 0)
        }
        
        self.setContentOffset(CGPoint(x: contentOffset.x, y: bottomOffsetY), animated: animated)
    }
    
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
        } else {
            if startOffset.x > endOffset.x {
                scrollDirection = .left
            } else if startOffset.x < endOffset.x {
                scrollDirection = .right
            } else if startOffset.y > endOffset.y {
                scrollDirection = .up
            } else if startOffset.y < endOffset.y {
                scrollDirection = .down
            } else {
                scrollDirection = .none
            }
        }
        return scrollDirection
    }
    
    public func killScroll() {
        self.isScrollEnabled = false
        self.isScrollEnabled = true
    }
}

extension UIScrollView {
    public typealias RefreshAction = (_ refreshControl: UIRefreshControl)->()
    
    private class ActionStore: NSObject {
        let action: RefreshAction
        init(_ action: @escaping RefreshAction) {
            self.action = action
        }
    }
    
    private struct AssociatedKeys {
        static var refreshActionKey = "refreshActionKey"
    }
    
    /// MUST USE [unowned self] to prevent retain cycle
    ///
    /// - Parameter action: closure for .valueChanged action
    public func addRefreshControl(action: @escaping RefreshAction) -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
        refreshAction = action
        refreshControl.addTarget(self, action: #selector(executeRefreshAction(_:)), for: .valueChanged)
        self.addSubview(refreshControl)
        return refreshControl
    }
    
    @objc func executeRefreshAction(_ sender: UIRefreshControl) {
        refreshAction?(sender)
    }
    
    private var refreshAction: RefreshAction? {
        get {
            guard let store = objc_getAssociatedObject(self, &AssociatedKeys.refreshActionKey) as? ActionStore else { return nil }
            return store.action
        }
        
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.refreshActionKey, ActionStore(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
