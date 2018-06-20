//
//  UICollectionView.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 6/18/18.
//

import Foundation

extension UICollectionView {
    
    /// Auto dequeue cell with custom cell class, the identifier must have the same name as the cell class
    ///
    /// - Parameter type: Custom cell class
    /// - Returns: Custom cell
    public func dequeueReusableCell<T: UICollectionViewCell>(_ type: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: String(describing: type), for: indexPath) as? T else {
            fatalError("\(String(describing: type)) cell could not be instantiated because it was not found on the tableView")
        }
        return cell
    }
}
