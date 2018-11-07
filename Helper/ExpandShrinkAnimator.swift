//
//  ViewExpandAnimationController.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 4/13/18.
//

import Foundation
import UIKit

fileprivate enum ExpandShrinkAnimatorMode {
    case presenting,
    dismissing,
    none
}

/// Check Demo project for how to use
public class ExpandShrinkAnimator: NSObject {
    let presentationTransition: ExpandShrinkTransition
    
    public init(fromView: UIView, toView: UIView) {
        self.presentationTransition = ExpandShrinkTransition(fromView: fromView, toView: toView)
        super.init()
    }
}

// MARK: - If modal presentation
/// Set nextVC.transitioningDelegate = animator
extension ExpandShrinkAnimator: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentationTransition.source = source
        presentationTransition.mode = .presenting
        return self.presentationTransition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentationTransition.mode = .dismissing
        return self.presentationTransition
    }
}

// MARK: - If push/pop with navigation controller
/// Set self.navigationController?.delegate = animator
extension ExpandShrinkAnimator: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentationTransition.mode = operation == .push ? .presenting : .dismissing
        return self.presentationTransition
    }
}


class ExpandShrinkTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    fileprivate var mode: ExpandShrinkAnimatorMode = .none
    var source: UIViewController?
    var containerSourceBackgroundImage: UIImage?
    var containerDestinationBackgroundImage: UIImage?
    
    private let kExpandShrinkTransitionDuration: TimeInterval = 0.5
    lazy var containerImageView: UIImageView = {
        let v = UIImageView(frame: UIScreen.main.bounds)
        return v
    }()
    
    private var fromView: UIView?
    private var toView: UIView?
    
    public init(fromView: UIView, toView: UIView) {
        self.fromView = fromView
        self.toView = toView
        super.init()
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return kExpandShrinkTransitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            let toVCView = toVC.view,
            let fromVCView = fromVC.view,
            let toView = toView,
            let fromView = fromView,
            mode != .none else {
                return
        }
        
        var initialF = CGRect.zero
        var finalF = CGRect.zero
        
        let container = transitionContext.containerView
        container.addSubview(containerImageView)
        container.addSubview(toVC.view)
        toVC.view.frame = transitionContext.finalFrame(for: toVC)
        
//        if let source = source, source.navigationController != toVC.navigationController || source.navigationController == nil  && toVC.navigationController == nil  {
            toVC.view.layoutIfNeeded()
//        }
        
        switch mode {
        case .presenting:
            initialF = (fromView.superview ?? fromVCView).convert(fromView.frame, to: nil)
            finalF = (toView.superview ?? toVCView).convert(toView.frame, to: nil)
            containerImageView.backgroundColor = toVC.view.backgroundColor
            if let img = containerDestinationBackgroundImage {
                containerImageView.image = img
            }
        case .dismissing:
            initialF = (toView.superview ?? toVCView).convert(toView.frame, to: nil)
            finalF = (fromView.superview ?? fromVCView).convert(fromView.frame, to: nil)
            containerImageView.backgroundColor = fromVC.view.backgroundColor
            if let img = containerSourceBackgroundImage {
                containerImageView.image = img
            }
        default:
            return
        }
        print(initialF, finalF)
        //Origin Frame - fade to 0
        let snapshot = fromVC.view.resizableSnapshotView(from: initialF, afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero)!
        snapshot.frame = initialF
        container.addSubview(snapshot)
        
        //Destination Frame - hides behind origin snapshot
        let toSnapshot = toVC.view.resizableSnapshotView(from: finalF, afterScreenUpdates: true, withCapInsets: .zero)!
        toSnapshot.frame = initialF
        container.insertSubview(toSnapshot, belowSubview: snapshot)
        
        let screenW = UIScreen.main.bounds.width
        let screenH = UIScreen.main.bounds.height
        
        //Top fromVC - move up
        let topInitialF = CGRect(x: 0, y: 0, width: screenW, height: initialF.minY)
        let topFinalF = CGRect(x: 0, y: -initialF.minY, width: screenW, height: initialF.minY)
        let topSnapshot = fromVC.view.resizableSnapshotView(from: topInitialF, afterScreenUpdates: true, withCapInsets: .zero)!
        topSnapshot.frame = topInitialF
        
        //Bottom fromVC - move down
        let bottomInitialF = CGRect(x: 0, y: initialF.maxY, width: screenW, height: screenH-initialF.maxY)
        let bottomFinalF = CGRect(x: 0, y: screenH, width: screenW, height: screenH-initialF.maxY)
        let bottomSnapshot = fromVC.view.resizableSnapshotView(from: bottomInitialF, afterScreenUpdates: true, withCapInsets: .zero)!
        bottomSnapshot.frame = bottomInitialF
        
        //Top toVC - move down
        let topToInitialF = CGRect(x: 0, y: -finalF.minY, width: screenW, height: finalF.minY)
        let topToFinalF = CGRect(x: 0, y: 0, width: screenW, height: finalF.minY)
        let topToSnapshot = toVC.view.resizableSnapshotView(from: topToFinalF, afterScreenUpdates: true, withCapInsets: .zero)!
        topToSnapshot.frame = topToInitialF
        
        //Bottom toVC - move up
        let bottomToInitialF = CGRect(x: 0, y: screenH, width: screenW, height: screenH-finalF.maxY)
        let bottomToFinalF = CGRect(x: 0, y: finalF.maxY, width: screenW, height: screenH-finalF.maxY)
        let bottomToSnapshot = toVC.view.resizableSnapshotView(from: bottomToFinalF, afterScreenUpdates: true, withCapInsets: .zero)!
        bottomToSnapshot.frame = bottomToInitialF
        
        let sideSnapshotRatio = finalF.height/initialF.height
        
        //Left fromVC - move right
        let leftInitialF = CGRect(x: 0, y: initialF.minY, width: initialF.minX, height: initialF.height)
        let leftFinalF = CGRect(x: -leftInitialF.width*sideSnapshotRatio, y: finalF.minY, width: leftInitialF.width*sideSnapshotRatio, height: finalF.height)
        let leftSnapshot = fromVC.view.resizableSnapshotView(from: leftInitialF, afterScreenUpdates: true, withCapInsets: .zero)!
        leftSnapshot.frame = leftInitialF
        
        //Right fromVC - move left
        let rightInitialF = CGRect(x: initialF.maxX, y: initialF.minY, width: screenW-initialF.maxX, height: initialF.height)
        let rightFinalF = CGRect(x: screenW, y: finalF.minY, width: rightInitialF.width*sideSnapshotRatio, height: finalF.height)
        let rightSnapshot = fromVC.view.resizableSnapshotView(from: rightInitialF, afterScreenUpdates: true, withCapInsets: .zero)!
        rightSnapshot.frame = rightInitialF
        
        let sideToSnapshotRatio = initialF.height/finalF.height
        
        //Left toVC - move right
        let leftToFinalF = CGRect(x: 0, y: finalF.minY, width: finalF.minX, height: finalF.height)
        let leftToInitialF = CGRect(x: -(leftToFinalF.width*sideToSnapshotRatio), y: initialF.minY, width: leftToFinalF.width*sideToSnapshotRatio, height: initialF.height)
        let leftToSnapshot = toVC.view.resizableSnapshotView(from: leftToFinalF, afterScreenUpdates: true, withCapInsets: .zero)!
        leftToSnapshot.frame = leftToInitialF
        
        //Right toVC - move left
        let rightToFinalF = CGRect(x: finalF.maxX, y: finalF.minY, width: screenW - finalF.maxX, height: finalF.height)
        let rightToInitialF = CGRect(x: screenW, y: initialF.minY, width: rightToFinalF.width*sideToSnapshotRatio, height: initialF.height)
        let rightToSnapshot = toVC.view.resizableSnapshotView(from: rightToFinalF, afterScreenUpdates: true, withCapInsets: .zero)!
        rightToSnapshot.frame = rightToInitialF
        
        let duration = transitionDuration(using: transitionContext)
        fromVC.view.alpha = 0
        toVC.view.alpha = 0
        
        container.addSubview(leftSnapshot)
        container.addSubview(rightSnapshot)
        container.addSubview(topSnapshot)
        container.addSubview(bottomSnapshot)
        container.addSubview(topToSnapshot)
        container.addSubview(bottomToSnapshot)
        container.addSubview(leftToSnapshot)
        container.addSubview(rightToSnapshot)
        
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: {
            snapshot.frame = finalF
            toSnapshot.frame = finalF
            snapshot.alpha = 0
            
            leftSnapshot.frame = leftFinalF
            rightSnapshot.frame = rightFinalF
            
            topSnapshot.frame = topFinalF
            bottomSnapshot.frame = bottomFinalF
            
            topToSnapshot.frame = topToFinalF
            bottomToSnapshot.frame = bottomToFinalF
            
            leftToSnapshot.frame = leftToFinalF
            rightToSnapshot.frame = rightToFinalF
        }) { (_) in
            fromVC.view.alpha = 1
            toVC.view.alpha = 1
            self.containerImageView.removeFromSuperview()
            
            snapshot.removeFromSuperview()
            toSnapshot.removeFromSuperview()
            
            leftSnapshot.removeFromSuperview()
            rightSnapshot.removeFromSuperview()
            
            topSnapshot.removeFromSuperview()
            bottomSnapshot.removeFromSuperview()
            
            topToSnapshot.removeFromSuperview()
            bottomToSnapshot.removeFromSuperview()
            
            leftToSnapshot.removeFromSuperview()
            rightToSnapshot.removeFromSuperview()
            
            self.mode = .none
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
