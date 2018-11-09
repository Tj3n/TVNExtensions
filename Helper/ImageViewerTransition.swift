//
//  ImageViewerTransition.swift
//
//  Created by TienVu on 11/7/18.
//

import UIKit

class ImageViewerTransition: NSObject, UIViewControllerAnimatedTransitioning {
    let kImageViewerAnimatorDuration = 0.5
    var fromView: UIView
    var fromImage: UIImage?
    var isPresenting: Bool = false
    var dismissFromView: UIView?
    
    init(from view: UIView, image: UIImage?) {
        self.fromView = view
        self.fromImage = image
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return kImageViewerAnimatorDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            let fromVCView = fromVC.view,
            let toView = toVC.view else {
                return
        }
        
        let containerView = transitionContext.containerView
        
        let imageView = UIImageView(image: fromImage)
        let fromViewFrame = (fromView.superview ?? fromVCView).convert(fromView.frame, to: nil)
//        let imageView = fromVCView.resizableSnapshotView(from: fromViewFrame, afterScreenUpdates: true, withCapInsets: .zero)!
        var dismissingFrame = CGRect(x: 0, y: containerView.bounds.height, width: containerView.bounds.width, height: containerView.bounds.height)
        if let dismissFromView = dismissFromView {
            dismissingFrame = dismissFromView.frame
        }
        imageView.frame = isPresenting ? fromViewFrame : dismissingFrame
        imageView.contentMode = isPresenting ? fromView.contentMode : .scaleAspectFit
        
        let fadeView = isPresenting ? UIVisualEffectView(effect: nil) : UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        fadeView.frame = toView.frame
        
        toView.frame = containerView.bounds
        self.fromView.alpha = 0
        
        let snapshot = toView.resizableSnapshotView(from: toView.frame, afterScreenUpdates: true, withCapInsets: .zero)!
        
        if isPresenting {
            containerView.addSubview(toVC.view)
            toView.alpha = 0
        } else {
            containerView.addSubview(snapshot)
        }
        containerView.addSubview(fadeView)
        containerView.addSubview(imageView)
        
        if #available(iOS 10.0, *) {
            let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), dampingRatio: 0.7) {
                fadeView.effect = self.isPresenting ? UIBlurEffect(style: .dark) : nil
                imageView.contentMode = .scaleAspectFit
                imageView.frame = self.isPresenting ? containerView.bounds : fromViewFrame
            }
            
            animator.addCompletion { (position) in
                if position == .end {
                    toView.alpha = 1
                    self.fromView.alpha = 1
                    snapshot.removeFromSuperview()
                    fadeView.removeFromSuperview()
                    imageView.removeFromSuperview()
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                }
            }
            
            animator.startAnimation()
        } else {
            UIView.animate(withDuration: transitionDuration(using: transitionContext),
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0,
                           options: .curveEaseOut,
                           animations: {
                            fadeView.effect = self.isPresenting ? UIBlurEffect(style: .dark) : nil
                            imageView.contentMode = .scaleAspectFit
                            imageView.frame = self.isPresenting ? containerView.bounds : fromViewFrame
            }, completion: { _ in
                toView.alpha = 1
                self.fromView.alpha = 1
                snapshot.removeFromSuperview()
                fadeView.removeFromSuperview()
                imageView.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}
