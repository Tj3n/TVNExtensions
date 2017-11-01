//
//  UITableViewExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 3/17/16.
//  Copyright © 2016 Paymentwall. All rights reserved.
//

import Foundation
import UIKit

extension UITableView
{
    /**
     Auto dequeue cell with custom cell class
     */
    public func dequeueReusableCell<T: UITableViewCell>(_ type: T.Type) -> T
    {
        guard let cell = self.dequeueReusableCell(withIdentifier: String(describing: type)) as? T else {
            fatalError("\(String(describing: type)) cell could not be instantiated because it was not found on the tableView")
        }
        return cell
    }
    
}
