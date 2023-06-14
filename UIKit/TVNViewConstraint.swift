//
//  TVNViewConstraint.swift
//  TVNExtensions
//
//  Created by Vũ Tiến on 14/06/2023.
//

import Foundation
import UIKit

public struct TVNViewConstraint {
    public let view: UIView
    public let constraints: [NSLayoutConstraint]
    
    @discardableResult
    public func addTo(_ view: UIView) -> UIView {
        view.addSubview(view)
        return view
    }
    
    @discardableResult
    public func constraintView(from fromView: UIView? = nil, firstAttr: NSLayoutConstraint.Attribute, to toView: UIView?, secondAttr: NSLayoutConstraint.Attribute, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> Self {
        view.translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(item: fromView == nil ? view : fromView!,
                                            attribute: firstAttr,
                                            relatedBy: relation,
                                            toItem: toView,
                                            attribute: toView == nil ? .notAnAttribute : secondAttr,
                                            multiplier: mult,
                                            constant: by)
        constraint.priority = priority
        constraint.isActive = true
        return TVNViewConstraint(view: view, constraints: [constraint])
    }
    
    @discardableResult
    public func edgesToSuperView(top: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0) -> Self? {
        guard let v = view.superview else { return nil }
        return edges(to: v, top: top, bottom: bottom, left: left, right: right)
    }
    
    @discardableResult
    public func edges(to view: UIView, top: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0) -> Self {
        var contraints = [NSLayoutConstraint]()
        contraints.append(contentsOf: self.view.top(to: view, by: top).constraints)
        contraints.append(contentsOf: self.view.bottom(to: view, by: bottom).constraints)
        contraints.append(contentsOf: self.view.left(to: view, by: left).constraints)
        contraints.append(contentsOf: self.view.right(to: view, by: right).constraints)
        return TVNViewConstraint(view: self.view, constraints: constraints)
    }
    
    @discardableResult
    public func top(to view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> TVNViewConstraint {
        return constraintView(firstAttr: .top, to: view, secondAttr: .top, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func topMargin(to view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> TVNViewConstraint {
        return constraintView(firstAttr: .top, to: view, secondAttr: .topMargin, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func topToBottom(of view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> TVNViewConstraint {
        return constraintView(firstAttr: .top, to: view, secondAttr: .bottom, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func bottom(to view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> TVNViewConstraint {
        return constraintView(from: view, firstAttr: .bottom, to: self.view, secondAttr: .bottom, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func bottomMargin(to view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> TVNViewConstraint {
        return constraintView(from: view, firstAttr: .bottom, to: self.view, secondAttr: .bottomMargin, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func bottomToTop(of view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> TVNViewConstraint {
        return constraintView(from: view, firstAttr: .top, to: self.view, secondAttr: .bottom, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func left(to view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> TVNViewConstraint {
        return constraintView(firstAttr: .left, to: view, secondAttr: .left, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func leftToRight(of view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> TVNViewConstraint {
        return constraintView(firstAttr: .left, to: view, secondAttr: .right, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func right(to view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> TVNViewConstraint {
        return constraintView(from: view, firstAttr: .right, to: self.view, secondAttr: .right, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func rightToLeft(of view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> TVNViewConstraint {
        return constraintView(from: view, firstAttr: .left, to: self.view, secondAttr: .right, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func center(to view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> [TVNViewConstraint] {
        let centerX = constraintView(firstAttr: .centerX, to: view, secondAttr: .centerX, relation: relation, mult: mult, by: by, priority: priority)
        let centerY = constraintView(firstAttr: .centerY, to: view, secondAttr: .centerY, relation: relation, mult: mult, by: by, priority: priority)
        return [centerX, centerY]
    }
    
    @discardableResult
    public func centerX(to view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> TVNViewConstraint {
        return constraintView(firstAttr: .centerX, to: view, secondAttr: .centerX, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    public func centerY(to view: UIView, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, by: CGFloat = 0, priority: UILayoutPriority = .required) -> TVNViewConstraint {
        return constraintView(firstAttr: .centerY, to: view, secondAttr: .centerY, relation: relation, mult: mult, by: by, priority: priority)
    }
    
    @discardableResult
    func setSize(width: CGFloat? = nil, height: CGFloat? = nil, to view: UIView? = nil, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, priority: UILayoutPriority = .required) -> TVNViewConstraint? {
        if let width = width {
            return constraintView(firstAttr: .width, to: view, secondAttr: view == nil ? .notAnAttribute : .width, relation: relation, mult: mult, by: width, priority: priority)
        }
        
        if let height = height {
            return constraintView(firstAttr: .height, to: view, secondAttr: view == nil ? .notAnAttribute : .height, relation: relation, mult: mult, by: height, priority: priority)
        }
        return nil
    }
    
    @discardableResult
    public func setWidth(_ constant: CGFloat, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, priority: UILayoutPriority = .required) -> TVNViewConstraint {
        return setSize(width: constant, height: nil, to: nil, relation: relation, mult: mult, priority: priority)!
    }
    
    @discardableResult
    public func setRelativeWidth(to view: UIView, ratio: CGFloat = 1, relation: NSLayoutConstraint.Relation = .equal, by: CGFloat = 0, priority: UILayoutPriority = .required) -> TVNViewConstraint {
        return setSize(width: by, height: nil, to: view, relation: relation, mult: ratio, priority: priority)!
    }
    
    @discardableResult
    public func setHeight(_ constant: CGFloat, relation: NSLayoutConstraint.Relation = .equal, mult: CGFloat = 1, priority: UILayoutPriority = .required) -> TVNViewConstraint {
        return setSize(width: nil, height: constant, to: nil, relation: relation, mult: mult, priority: priority)!
    }
    
    @discardableResult
    public func setRelativeHeight(to view: UIView, ratio: CGFloat = 1, relation: NSLayoutConstraint.Relation = .equal, by: CGFloat = 0, priority: UILayoutPriority = .required) -> TVNViewConstraint {
        return setSize(width: nil, height: by, to: view, relation: relation, mult: ratio, priority: priority)!
    }
    
    @discardableResult
    public func setWidthHeightRatio(to view: UIView? = nil, ratio: CGFloat = 1, relation: NSLayoutConstraint.Relation = .equal, priority: UILayoutPriority = .required) -> TVNViewConstraint {
        return constraintView(firstAttr: .width, to: view ?? self.view, secondAttr: .height, relation: relation, mult: ratio, priority: priority)
    }
    
    public func stack(_ views: [UIView], axis: NSLayoutConstraint.Axis, spacing: CGFloat = 0) -> TVNViewConstraint {
        var prevView: UIView?
        var constraints = [NSLayoutConstraint]()
        for view in views {
            
            self.view.addSubview(view)
            
            switch axis {
            case .vertical:
                if let _ = prevView {
                    constraints.append(contentsOf: view.topToBottom(of: prevView!, by: spacing).constraints)
                } else {
                    constraints.append(contentsOf: view.top(to: self.view).constraints)
                }
                constraints.append(contentsOf: view.left(to: self.view).constraints)
                constraints.append(contentsOf: view.right(to: self.view).constraints)
                if view == views.last {
                    constraints.append(contentsOf: view.bottom(to: self.view).constraints)
                }
            case .horizontal:
                if let _ = prevView {
                    constraints.append(contentsOf: view.leftToRight(of: prevView!, by: spacing).constraints)
                } else {
                    constraints.append(contentsOf: view.left(to: self.view).constraints)
                }
                constraints.append(contentsOf: view.top(to: self.view).constraints)
                constraints.append(contentsOf: view.bottom(to: self.view).constraints)
                if view == views.last {
                    constraints.append(contentsOf: view.right(to: self.view).constraints)
                }
            default:
                break
            }
            prevView = view
        }
        
        return TVNViewConstraint(view: self.view, constraints: constraints)
    }
}
