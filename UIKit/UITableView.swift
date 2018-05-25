//
//  UITableViewExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 3/17/16.
//  Copyright © 2016 Paymentwall. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    
    /// Auto dequeue cell with custom cell class
    ///
    /// - Parameter type: Custom cell class
    /// - Returns: Custom cell
    public func dequeueReusableCell<T: UITableViewCell>(_ type: T.Type) -> T {
        guard let cell = self.dequeueReusableCell(withIdentifier: String(describing: type)) as? T else {
            fatalError("\(String(describing: type)) cell could not be instantiated because it was not found on the tableView")
        }
        return cell
    }
    
    /// Check if tableView is empty
    public var isEmpty: Bool {
        get {
            return self.visibleCells.isEmpty
        }
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
}

extension UITableView {
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
    
    public func addRefreshControl(action: RefreshAction) -> UIRefreshControl {
        let refreshControl = UIRefreshControl()
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
