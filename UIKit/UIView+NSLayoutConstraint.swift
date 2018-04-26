//
//  UIView+NSLayoutConstraint.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 4/18/18.
//

import Foundation
import UIKit

// MARK: - Constraint
extension UIView {
    @discardableResult
    public func addTo(view: UIView) -> Self {
        view.addSubview(self)
        return self
    }
    
    @discardableResult
    func constraintView(firstAttr: NSLayoutAttribute, to view: UIView?, secondAttr: NSLayoutAttribute, relation: NSLayoutRelation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: firstAttr,
                                            relatedBy: relation,
                                            toItem: view,
                                            attribute: view == nil ? .notAnAttribute : secondAttr,
                                            multiplier: mult,
                                            constant: by)
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    public func top(to view: UIView, relation: NSLayoutRelation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constraintView(firstAttr: .topMargin, to: view, secondAttr: .topMargin, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func topToBottom(of view: UIView, relation: NSLayoutRelation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constraintView(firstAttr: .topMargin, to: view, secondAttr: .bottomMargin, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func bottom(to view: UIView, relation: NSLayoutRelation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constraintView(firstAttr: .bottomMargin, to: view, secondAttr: .bottomMargin, relation: relation, mult: mult, by: -by, priority: priority)
    }
    
    @discardableResult
    public func bottomToTop(of view: UIView, relation: NSLayoutRelation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constraintView(firstAttr: .bottomMargin, to: view, secondAttr: .topMargin, relation: relation, mult: mult, by: -by, priority: priority)
    }
    
    @discardableResult
    public func left(to view: UIView, relation: NSLayoutRelation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constraintView(firstAttr: .leftMargin, to: view, secondAttr: .leftMargin, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func leftToRight(of view: UIView, relation: NSLayoutRelation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constraintView(firstAttr: .leftMargin, to: view, secondAttr: .rightMargin, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func right(to view: UIView, relation: NSLayoutRelation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constraintView(firstAttr: .rightMargin, to: view, secondAttr: .rightMargin, relation: relation, mult: mult, by: -by, priority: priority)
    }
    
    @discardableResult
    public func rightToLeft(of view: UIView, relation: NSLayoutRelation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constraintView(firstAttr: .rightMargin, to: view, secondAttr: .leftMargin, relation: relation, mult: mult, by: -by, priority: priority)
    }
    
    @discardableResult
    public func centerX(to view: UIView, relation: NSLayoutRelation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constraintView(firstAttr: .centerX, to: view, secondAttr: .centerX, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func centerY(to view: UIView, relation: NSLayoutRelation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constraintView(firstAttr: .centerY, to: view, secondAttr: .centerY, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    func setSize(width: CGFloat? = nil, height: CGFloat? = nil, to view: UIView? = nil, relation: NSLayoutRelation = .equal, mult: CGFloat = 1, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        if let width = width {
            return constraintView(firstAttr: .width, to: view, secondAttr: view == nil ? .notAnAttribute : .width, relation: relation, mult: mult, by: width, priority: priority)
        }
        
        if let height = height {
            return constraintView(firstAttr: .height, to: view, secondAttr: view == nil ? .notAnAttribute : .height, relation: relation, mult: mult, by: height, priority: priority)
        }
        return NSLayoutConstraint()
    }
    
    @discardableResult
    public func setWidth(_ constant: CGFloat, relation: NSLayoutRelation = .equal, mult: CGFloat = 1, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return setSize(width: constant, height: nil, to: nil, relation: relation, mult: mult, priority: priority)
    }
    
    @discardableResult
    public func setRelativeWidth(to view: UIView, ratio: CGFloat = 1, relation: NSLayoutRelation = .equal, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return setSize(width: by, height: nil, to: view, relation: relation, mult: ratio, priority: priority)
    }
    
    @discardableResult
    public func setHeight(_ constant: CGFloat, relation: NSLayoutRelation = .equal, mult: CGFloat = 1, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return setSize(width: nil, height: constant, to: nil, relation: relation, mult: mult, priority: priority)
    }
    
    @discardableResult
    public func setRelativeHeight(to view: UIView, ratio: CGFloat = 1, relation: NSLayoutRelation = .equal, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return setSize(width: nil, height: by, to: view, relation: relation, mult: ratio, priority: priority)
    }
    
    @discardableResult
    public func setWidthHeightRatio(to view: UIView? = nil, ratio: CGFloat = 1, relation: NSLayoutRelation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constraintView(firstAttr: .width, to: view ?? self, secondAttr: .height, relation: relation, mult: ratio, priority: priority)
    }
    
    public func stack(_ views: [UIView], axis: UILayoutConstraintAxis, spacing: CGFloat = 0) {
        var prevView: UIView?
        for view in views {
            
            self.addSubview(view)
            
            switch axis {
            case .vertical:
                if let _ = prevView {
                    view.topToBottom(of: prevView!, by: spacing)
                } else {
                    view.top(to: self)
                }
                view.left(to: self)
                view.right(to: self)
                if view == views.last {
                    view.bottom(to: self)
                }
            case .horizontal:
                if let _ = prevView {
                    view.leftToRight(of: prevView!, by: spacing)
                } else {
                    view.left(to: self)
                }
                view.top(to: self)
                view.bottom(to: self)
                if view == views.last {
                    view.right(to: self)
                }
            }
            prevView = view
        }
    }
}
