//
//  ParallaxBackgroundView.swift
//  TVNExtensions
//
//  Created by Vũ Tiến on 4/17/20.
//

import Foundation
import UIKit

class ParallaxBackgroundView <T: UIImageView> : UIView {
    
    var backgroundImageView: T!
    var backgroundImageViewHeightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        backgroundImageView = T(image: nil)
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.addTo(self)
        backgroundImageViewHeightConstraint = backgroundImageView.setRelativeHeight(to: self)
        backgroundImageView.top(to: self, priority: UILayoutPriority(rawValue: 999))
        backgroundImageView.bottom(to: self)
        backgroundImageView.left(to: self)
        backgroundImageView.right(to: self)
        backgroundImageView.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.sendSubviewToBack(backgroundImageView)
    }

    /// Call from `scrollViewDidScroll` when `scrollView.contentOffset.y < 0`
    /// - Parameter offset: scrollView.contentOffset
    func updateBackgroundHeightOnScroll(offset: CGPoint) {
        if offset.y < 0 {
            backgroundImageViewHeightConstraint.constant = offset.y * -1
            layoutIfNeeded()
        }
    }
}
