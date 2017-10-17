//
//  UIScrollViewExtension.swift
//  MerchantDashboard
//
//  Created by Tien Nhat Vu on 5/19/16.
//  Copyright © 2016 Paymentwall. All rights reserved.
//

import Foundation
import UIKit

enum ScrollDirection {
    case scrollDirectionNone,
    scrollDirectionCrazy,
    scrollDirectionLeft,
    scrollDirectionRight,
    scrollDirectionUp,
    scrollDirectionDown
}

extension UIScrollView {
    
    func determineScrollDirection(_ startOffset: CGPoint, endOffset: CGPoint) -> ScrollDirection {
        var scrollDirection: ScrollDirection
        // If the scrolling direction is changed on both X and Y it means the
        // scrolling started in one corner and goes diagonal. This will be
        // called ScrollDirectionCrazy
        if startOffset.x != endOffset.x && startOffset.y != endOffset.y {
            scrollDirection = .scrollDirectionCrazy
        }
        else {
            if startOffset.x > endOffset.x {
                scrollDirection = .scrollDirectionLeft
            }
            else if startOffset.x < endOffset.x {
                scrollDirection = .scrollDirectionRight
            }
            else if startOffset.y > endOffset.y {
                scrollDirection = .scrollDirectionUp
            }
            else if startOffset.y < endOffset.y {
                scrollDirection = .scrollDirectionDown
            }
            else {
                scrollDirection = .scrollDirectionNone
            }
        }
        return scrollDirection
    }
    
    func killScroll() {
        self.isScrollEnabled = false
        self.isScrollEnabled = true
    }}
