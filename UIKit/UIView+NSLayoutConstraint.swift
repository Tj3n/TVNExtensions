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
    public func addTo(_ view: UIView) -> Self {
        view.addSubview(self)
        return self
    }
    
    @discardableResult
    public func constraintView(from fromView: UIView? = nil, firstAttr: NSLayoutConstraint.Attribute, to toView: UIView?, secondAttr: NSLayoutConstraint.Attribute, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(item: fromView == nil ? self : fromView!,
                                            attribute: firstAttr,
                                            relatedBy: relation,
                                            toItem: toView,
                                            attribute: toView == nil ? .notAnAttribute : secondAttr,
                                            multiplier: mult,
                                            constant: by)
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    public func edgesToSuperView(top: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0) -> [NSLayoutConstraint] {
        guard let v = self.superview else { return [NSLayoutConstraint]() }
        return edges(to: v, top: top, bottom: bottom, left: left, right: right)
    }
    
    @discardableResult
    public func edges(to view: UIView, top: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0) -> [NSLayoutConstraint] {
        var contraints = [NSLayoutConstraint]()
        contraints.append(self.top(to: view, by: top))
        contraints.append(self.bottom(to: view, by: bottom))
        contraints.append(self.left(to: view, by: left))
        contraints.append(self.right(to: view, by: right))
        return contraints
    }
    
    @discardableResult
    public func top(to view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constraintView(firstAttr: .top, to: view, secondAttr: .top, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func topMargin(to view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constraintView(firstAttr: .top, to: view, secondAttr: .topMargin, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func topToBottom(of view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constraintView(firstAttr: .top, to: view, secondAttr: .bottom, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func bottom(to view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constraintView(from: view, firstAttr: .bottom, to: self, secondAttr: .bottom, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func bottomMargin(to view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constraintView(from: view, firstAttr: .bottom, to: self, secondAttr: .bottomMargin, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func bottomToTop(of view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constraintView(from: view, firstAttr: .top, to: self, secondAttr: .bottom, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func left(to view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constraintView(firstAttr: .left, to: view, secondAttr: .left, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func leftToRight(of view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constraintView(firstAttr: .left, to: view, secondAttr: .right, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func right(to view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constraintView(from: view, firstAttr: .right, to: self, secondAttr: .right, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func rightToLeft(of view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constraintView(from: view, firstAttr: .left, to: self, secondAttr: .right, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func center(to view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> [NSLayoutConstraint] {
        let centerX = constraintView(firstAttr: .centerX, to: view, secondAttr: .centerX, relation: relation, mult: mult, by: by, priority: priority)
        let centerY = constraintView(firstAttr: .centerY, to: view, secondAttr: .centerY, relation: relation, mult: mult, by: by, priority: priority)
        return [centerX, centerY]
    }
    
    @discardableResult
    public func centerX(to view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constraintView(firstAttr: .centerX, to: view, secondAttr: .centerX, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func centerY(to view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constraintView(firstAttr: .centerY, to: view, secondAttr: .centerY, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    func setSize(width: CGFloat? = nil, height: CGFloat? = nil, to view: UIView? = nil, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        if let width = width {
            return constraintView(firstAttr: .width, to: view, secondAttr: view == nil ? .notAnAttribute : .width, relation: relation, mult: mult, by: width, priority: priority)
        }
        
        if let height = height {
            return constraintView(firstAttr: .height, to: view, secondAttr: view == nil ? .notAnAttribute : .height, relation: relation, mult: mult, by: height, priority: priority)
        }
        return NSLayoutConstraint()
    }
    
    @discardableResult
    public func setWidth(_ constant: CGFloat, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return setSize(width: constant, height: nil, to: nil, relation: relation, mult: mult, priority: priority)
    }
    
    @discardableResult
    public func setRelativeWidth(to view: UIView, ratio: CGFloat = 1, relation: NSLayoutConstraint.Relation = .equal, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return setSize(width: by, height: nil, to: view, relation: relation, mult: ratio, priority: priority)
    }
    
    @discardableResult
    public func setHeight(_ constant: CGFloat, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return setSize(width: nil, height: constant, to: nil, relation: relation, mult: mult, priority: priority)
    }
    
    @discardableResult
    public func setRelativeHeight(to view: UIView, ratio: CGFloat = 1, relation: NSLayoutConstraint.Relation = .equal, by: CGFloat = 0, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return setSize(width: nil, height: by, to: view, relation: relation, mult: ratio, priority: priority)
    }
    
    @discardableResult
    public func setWidthHeightRatio(to view: UIView? = nil, ratio: CGFloat = 1, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> NSLayoutConstraint {
        return constraintView(firstAttr: .width, to: view ?? self, secondAttr: .height, relation: relation, mult: ratio, priority: priority)
    }
    
    public func stack(_ views: [UIView], axis: NSLayoutConstraint.Axis, spacing: CGFloat = 0) {
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
            default:
                break
            }
            prevView = view
        }
    }
}
