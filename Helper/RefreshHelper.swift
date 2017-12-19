//
//  RefreshHelper.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 10/24/17.
//

import Foundation
import CCommonCrypto

public protocol RefreshHelper {
    func setupRefreshControl(_ tableView: UITableView, target: AnyObject, action: Selector)
}

public extension RefreshHelper where Self: UIViewController {
    /// Setup refresh control
    ///
    /// - Parameters:
    ///   - tableView: tableView to add refresh control
    ///   - target: View controller contains tableView
    ///   - action: @objc func refresh(_ sender: UIRefreshControl)
    public func setupRefreshControl(_ tableView: UITableView, target: AnyObject, action: Selector) {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(target, action: action, for: .valueChanged)
//        let tableViewController = UITableViewController()
//        tableViewController.tableView = tableView
//        tableViewController.refreshControl = refreshControl
        tableView.addSubview(refreshControl)
    }
}
