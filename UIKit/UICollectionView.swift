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
    
    /// Get indexPath from cell's subview
    ///
    /// - Parameter subview: cell's subview
    /// - Returns: cell's indexPath
    public func indexPathForItemSubview(_ subview: UIView) -> IndexPath? {
        let point = subview.convert(subview.frame, to: self)
        return self.indexPathForItem(at: point.origin)
    }
    
    /// Use with UIScrollViewDelegate
    /// [Source](https://stackoverflow.com/questions/33855945/uicollectionview-snap-onto-cell-when-scrolling-horizontally)
    /// ````
    /// func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    ///     self.collectionView.scrollToNearestVisibleCollectionViewCell()
    /// }
    /// func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    ///     if !decelerate {
    ///         self.collectionView.scrollToNearestVisibleCollectionViewCell()
    ///     }
    /// }
    /// ````
    public func scrollToNearestVisibleCollectionViewCell() {
        self.decelerationRate = .fast
        let visibleCenterPositionOfScrollView = Float(self.contentOffset.x + (self.bounds.size.width / 2))
        var closestCellIndex = -1
        var closestDistance: Float = .greatestFiniteMagnitude
        for i in 0..<self.visibleCells.count {
            let cell = self.visibleCells[i]
            let cellWidth = cell.bounds.size.width
            let cellCenter = Float(cell.frame.origin.x + cellWidth / 2)

            // Now calculate closest cell
            let distance: Float = fabsf(visibleCenterPositionOfScrollView - cellCenter)
            if distance < closestDistance {
                closestDistance = distance
                closestCellIndex = self.indexPath(for: cell)!.row
            }
        }
        if closestCellIndex != -1 {
            self.scrollToItem(at: IndexPath(row: closestCellIndex, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
}
