//
//  ImageViewerAnimator.swift
//
//  Created by TienVu on 11/7/18.
//

import UIKit

class ImageViewerAnimator: NSObject, UIViewControllerTransitioningDelegate {
    let presentationTransition: ImageViewerTransition
    
    init(from imageView: UIImageView) {
        presentationTransition = ImageViewerTransition(from: imageView, image: imageView.image, clippingTransition: true)
        super.init()
    }
    
    init(from view: UIView, image: UIImage?, clippingTransition: Bool = true) {
        presentationTransition = ImageViewerTransition(from: view, image: image, clippingTransition: clippingTransition)
        super.init()
    }
    
    func prepareForDismiss(from view: UIView?, image: UIImage?) {
        if let view = view { presentationTransition.dismissFromView = view }
        if let image = image { presentationTransition.fromImage = image }
    }
    
    func prepareForDismiss(from imageView: UIImageView) {
        self.prepareForDismiss(from: imageView, image: imageView.image)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentationTransition.isPresenting = true
        return presentationTransition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentationTransition.isPresenting = false
        return presentationTransition
    }
}
