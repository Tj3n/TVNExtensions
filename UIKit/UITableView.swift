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
    
    /// Auto dequeue cell with custom cell class, the identifier must have the same name as the cell class
    ///
    /// - Parameter type: Custom cell class
    /// - Returns: Custom cell
    public func dequeueReusableCell<T: UITableViewCell>(_ type: T.Type) -> T {
        guard let cell = self.dequeueReusableCell(withIdentifier: String(describing: type)) as? T else {
            fatalError("\(String(describing: type)) cell could not be instantiated because it was not found on the tableView")
        }
        return cell
    }
    
    /// Auto dequeue cell with custom cell class, the identifier must have the same name as the cell class
    ///
    /// - Parameter type: Custom cell class
    /// - Returns: Custom cell
    public func dequeueReusableCell<T: UITableViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withIdentifier: String(describing: type), for: indexPath) as? T else {
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
    
    /// Get indexPath from cell's subview
    ///
    /// - Parameter subview: cell's subview
    /// - Returns: cell's indexPath
    public func indexPathForRowSubview(_ subview: UIView) -> IndexPath? {
        let point = subview.convert(subview.center, to: self)
        return self.indexPathForRow(at: point)
    }
}
