//
//  HeaderCollapsableTableView.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 7/16/18.
//

import Foundation
import UIKit

public protocol HeaderCollapsableTableView: AnyObject where Self: UIScrollViewDelegate {
    /// Vary starting height of the header, should be min or max
    var currentHeight: CGFloat { get set }
    /// Default should be 0.0
    var previousScrollOffset: CGFloat { get set }
    var maxHeaderHeight: CGFloat { get }
    var minHeaderHeight: CGFloat { get }
    
    /// Conform this function to update header view
    ///
    /// - Parameters:
    ///   - newHeight: Will be (minHeaderHeight <= newHeight <= maxHeaderHeight)
    ///   - percentage: percentage of the min and max height, useful for alpha animation
    ///   - isUp: indicator that the view is going up or not, isUp == smaller newHeight
    ///   - animated: indicator that the update should be wrapped inside animate block
    func updateHeaderView(newHeight: CGFloat, percentage: CGFloat, isUp: Bool, animated: Bool)
    
    /// Tell the function to collapse header on scrolling up or not. Can be override.
    ///
    /// **Default**:
    /// ```
    /// (scrollView.contentSize.height > scrollView.frame.height) || (currentHeight < maxHeaderHeight && currentHeight > minHeaderHeight)`
    /// ```
    ///
    /// - Parameter scrollView: scrollView
    /// - Returns: shouldCollapseHeader
    func shouldCollapseHeader(for scrollView: UIScrollView) -> Bool
    
    /// `false` will make header expand only when `contentOffset.y <= 0`. Default `true`. Can be override.
    func shouldExpandHeaderImmediatelyOnScrollDown(for scrollView: UIScrollView) -> Bool
    
    /// Main handler for updating header height, call from similar UIScrollViewDelegate, shouldn't be override
    ///
    /// - Parameter scrollView: scrollView
    func collapsableScrollViewDidScroll(_ scrollView: UIScrollView)
    
    /// Handler for stop scrolling mid-way, call from similar UIScrollViewDelegate, shouldn't be override
    ///
    /// - Parameter scrollView: scrollView
    func collapsableScrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    
    /// Handler for stop scrolling mid-way, call from similar UIScrollViewDelegate, shouldn't be override
    ///
    /// - Parameter scrollView: scrollView
    func collapsableScrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
}

extension HeaderCollapsableTableView {
    public func shouldCollapseHeader(for scrollView: UIScrollView) -> Bool {
        let canScroll = scrollView.contentSize.height > scrollView.frame.height
        let inMiddleOfAnimation = currentHeight < maxHeaderHeight && currentHeight > minHeaderHeight
        return canScroll || inMiddleOfAnimation
    }
    
    public func shouldExpandHeaderImmediatelyOnScrollDown(for scrollView: UIScrollView) -> Bool {
        return true
    }
    
    func getCurrentPercentage(_ newHeight: CGFloat) -> CGFloat {
        return (newHeight-minHeaderHeight)/(maxHeaderHeight-minHeaderHeight)
    }
    
    public func collapsableScrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = max(scrollView.contentSize.height - scrollView.frame.size.height, 0);
        let isScrollingUp = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingDown = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom

        currentHeight = currentHeight > maxHeaderHeight ? maxHeaderHeight : currentHeight < minHeaderHeight ? minHeaderHeight : currentHeight
        var newHeight = currentHeight
        var isUp: Bool = false
        let shouldExpandImmediatelly = self.shouldExpandHeaderImmediatelyOnScrollDown(for: scrollView)
        if isScrollingUp && shouldCollapseHeader(for: scrollView) {
            newHeight = max(self.minHeaderHeight, currentHeight - abs(scrollDiff))
            isUp = true
        } else if isScrollingDown && (shouldExpandImmediatelly || (!shouldExpandImmediatelly && scrollView.contentOffset.y <= 0)) {
            newHeight = min(self.maxHeaderHeight, currentHeight + abs(scrollDiff))
        }
        
        if newHeight != currentHeight {
            let percentage = getCurrentPercentage(newHeight)
            updateHeaderView(newHeight: newHeight, percentage: percentage, isUp: isUp, animated: false)
            currentHeight = newHeight
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: previousScrollOffset), animated: false)
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
        var isUp: Bool
        if currentHeight > midPoint {
            newHeight = self.maxHeaderHeight
            isUp = false
        } else {
            newHeight = self.minHeaderHeight
            isUp = true
        }
        
        let percentage = getCurrentPercentage(newHeight)
        updateHeaderView(newHeight: newHeight, percentage: percentage, isUp: isUp, animated: true)
        currentHeight = newHeight
    }
}
