//
//  ViewExpandAnimationController.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 4/13/18.
//

import Foundation

public protocol ExpandShrinkAnimatorProtocol: class {
    var destinationFrame: CGRect { get }
}

public class ExpandShrinkAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    public enum ExpandShrinkAnimatorMode {
        case presenting,
        dismissing,
        none
    }
    
    let kExpandShrinkTransitionDuration = 0.5
    
    public var originFrame = CGRect.zero
    public var mode: ExpandShrinkAnimatorMode = .none
    public var source: UIViewController?
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return kExpandShrinkTransitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            mode != .none else {
                return
        }
        
        var initialF = CGRect.zero
        var finalF = CGRect.zero
        
        if let source = source, source.navigationController != toVC.navigationController  {
            toVC.view.layoutIfNeeded()
        }
        
        let container = transitionContext.containerView
        container.backgroundColor = .white
        container.addSubview(toVC.view)
        toVC.view.frame = transitionContext.finalFrame(for: toVC)
        
        switch mode {
        case .presenting:
            guard toVC is ExpandShrinkAnimatorProtocol else { return }
            initialF = originFrame
            finalF = (toVC as! ExpandShrinkAnimatorProtocol).destinationFrame
        case .dismissing:
            guard fromVC is ExpandShrinkAnimatorProtocol else { return }
            initialF = (fromVC as! ExpandShrinkAnimatorProtocol).destinationFrame
            finalF = originFrame
        default:
            return
        }

        let snapshot = fromVC.view.resizableSnapshotView(from: initialF, afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero)!
        snapshot.frame = initialF
        snapshot.alpha = 1
        container.addSubview(snapshot)
        
        ///Add snap on all 4 sides to make animation better
        
        let duration = transitionDuration(using: transitionContext)
        
        toVC.view.alpha = 0
        
        UIView.animate(withDuration: 0.3, animations: {
            fromVC.view.alpha = 0
        }) { (completed) in
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: [.curveEaseInOut], animations: {
                snapshot.frame = finalF
            }, completion: { (completed) in
                UIView.animate(withDuration: 0.3, animations: {
                    toVC.view.alpha = 1
                }, completion: { (_) in
                    fromVC.view.alpha = 1
                    snapshot.removeFromSuperview()
                    self.mode = .none
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                })
            })
        }
    }
}

// MARK: - If modal presentation
/// Set nextVC.transitioningDelegate = animator
extension ExpandShrinkAnimator: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.source = source
        self.mode = .presenting
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.mode = .dismissing
        return self
    }
}

// MARK: - If push/pop with navigation controller
/// Set self.navigationController?.delegate = animator
extension ExpandShrinkAnimator: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.mode = operation == .push ? .presenting : .dismissing
        return self
    }
}
