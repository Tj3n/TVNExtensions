//
//  HeaderCollapsableTableView.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 7/16/18.
//

import Foundation
import UIKit

public protocol HeaderCollapsableTableView: class where Self: UIScrollViewDelegate {
    /// Vary starting height, should be min or max
    var currentHeight: CGFloat { get set }
    /// Default should be 0.0
    var previousScrollOffset: CGFloat { get set }
    var maxHeaderHeight: CGFloat { get }
    var minHeaderHeight: CGFloat { get }
    var shouldCollapseHeader: Bool { get }
    
    /// Conform this function to update header view
    ///
    /// - Parameters:
    ///   - newHeight: Will be minHeaderHeight <= newHeight <= maxHeaderHeight
    ///   - percentage: percentage of the min and max height, useful for alpha animation
    ///   - animated: indicator that the update should be wrapped inside animate block
    func updateHeaderView(newHeight: CGFloat, percentage: CGFloat, animated: Bool)
    
    /// Main handler for updating header height, call from similar UIScrollViewDelegate
    ///
    /// - Parameter scrollView: scrollView
    func collapsableScrollViewDidScroll(_ scrollView: UIScrollView)
    
    /// Handler for stop scrolling mid-way, call from similar UIScrollViewDelegate
    ///
    /// - Parameter scrollView: scrollView
    func collapsableScrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    
    /// Handler for stop scrolling mid-way, call from similar UIScrollViewDelegate
    ///
    /// - Parameter scrollView: scrollView
    func collapsableScrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
}

extension HeaderCollapsableTableView {
    func getCurrentPercentage(_ newHeight: CGFloat) -> CGFloat {
        return (newHeight-minHeaderHeight)/(maxHeaderHeight-minHeaderHeight)
    }
    
    public func collapsableScrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldCollapseHeader else { return }

        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = max(scrollView.contentSize.height - scrollView.frame.size.height, 0);
        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom

        currentHeight = currentHeight > maxHeaderHeight ? maxHeaderHeight : currentHeight < minHeaderHeight ? minHeaderHeight : currentHeight
        var newHeight = currentHeight
        if isScrollingDown {
            newHeight = max(self.minHeaderHeight, currentHeight - abs(scrollDiff))
        } else if isScrollingUp {
            newHeight = min(self.maxHeaderHeight, currentHeight + abs(scrollDiff))
        }
        
        if newHeight != currentHeight {
            let percentage = getCurrentPercentage(newHeight)
            updateHeaderView(newHeight: newHeight, percentage: percentage, animated: false)
            currentHeight = newHeight
        }

        self.previousScrollOffset = scrollView.contentOffset.y
    }

    public func collapsableScrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidStopScrolling()
    }

    public func collapsableScrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewDidStopScrolling()
        }
    }

    func scrollViewDidStopScrolling() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let midPoint = self.minHeaderHeight + (range / 2)
        var newHeight: CGFloat
        if currentHeight > midPoint {
            newHeight = self.maxHeaderHeight
        } else {
            newHeight = self.minHeaderHeight
        }
        
        let percentage = getCurrentPercentage(newHeight)
        updateHeaderView(newHeight: newHeight, percentage: percentage, animated: true)
        currentHeight = newHeight
    }
}
