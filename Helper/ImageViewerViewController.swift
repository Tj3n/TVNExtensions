//
//  ImageViewerViewController.swift
//
//  Created by TienVu on 11/6/18.
//

import UIKit
import AVFoundation

/// Full screen Image Viewer, can handle URL using Kingfisher
public class ImageViewerViewController: UIViewController {
    
    private lazy var scrollView: UIScrollView = {
        let v = UIScrollView(frame: .zero)
        v.delegate = self
        v.alwaysBounceVertical = true
        v.alwaysBounceHorizontal = true
        v.bounces = true
        v.bouncesZoom = true
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        return v
    }()
    
    private lazy var imageView: UIImageView = {
        let v = UIImageView(frame: .zero)
        v.image = image
        v.contentMode = .scaleAspectFit
        v.isUserInteractionEnabled = true
        v.addGestureRecognizer(panGesture)
        return v
    }()
    
    private lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
    
    private lazy var blurredView: UIVisualEffectView = {
        let v = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        return v
    }()
    
    private var image: UIImage?
    private lazy var originalPosition: CGPoint = view.center
    private var imageURL: URL?
    private var animator: ImageViewerAnimator?
    //    private var isZooming = false
    //    var shouldDismiss = false
    var urlHandleClosure: ((URL) -> (UIImage?))?
    
    /// Create imageViewer with transition animation from view/imageview/cell...
    ///
    /// - Parameters:
    ///   - image: image
    ///   - view: starting view
    convenience public init(image: UIImage?, from view: UIView?) {
        self.init(nibName:nil, bundle:nil)
        self.image = image
        setupModalPresention(from: view, image: image)
    }
    
    /// Create imageViewer from URL with transition animation from view/imageview/cell...
    ///
    /// - Parameters:
    ///   - imageURL: image URL
    ///   - placeholderImage: placeholder image, can be nil
    ///   - view: starting view
    convenience public init(imageURL: URL, placeholderImage: UIImage?, from view: UIView?) {
        self.init(nibName:nil, bundle:nil)
        self.imageURL = imageURL
        self.image = placeholderImage
        setupModalPresention(from: view, image: placeholderImage)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupView()
        calculateZoomScale()
        
        if let url = imageURL {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        let newImage = UIImage(data: imageData)
                        self.image = newImage
                        self.imageView.image = newImage
                    }
                }
            }
            
            //Kingfisher code
//            self.imageView.kf.setImage(with: url, placeholder: image) { [weak self] (img, error, cacheType, url) in
//                self?.image = img
//                self?.calculateZoomScale()
//            }
        }
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupModalPresention(from view: UIView?, image: UIImage?) {
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        modalPresentationCapturesStatusBarAppearance = true
        
        guard let view = view, let image = image else { return }
        animator = ImageViewerAnimator(from: view, image: image)
        transitioningDelegate = animator
    }
    
    private func setupView() {
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        view.addSubview(blurredView)
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        
        blurredView.edgesToSuperView()
        scrollView.edgesToSuperView()
        imageView.edgesToSuperView()
        imageView.setRelativeWidth(to: view)
        imageView.setRelativeHeight(to: view)
    }
    
    /// If horizontal image then get max zoom by height, else by width
    private func calculateZoomScale() {
        scrollView.minimumZoomScale = 1
        guard let image = image else { return }
        let isHorizontalImg = (image.size.width / image.size.height) >= 1
        let imageViewSize = aspectFitRect(forSize: image.size, insideRect: UIScreen.main.bounds)
        scrollView.maximumZoomScale = isHorizontalImg ?  UIScreen.main.bounds.size.height / imageViewSize.height : UIScreen.main.bounds.size.width / imageViewSize.width
    }
    
    @objc private func handleGesture(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: view)
        
        switch panGesture.state {
        case .began:
            originalPosition = imageView.center
            break
        case .changed:
            imageView.frame.origin = CGPoint(x: translation.x, y: translation.y)
            break
        case .ended:
            let velocity = panGesture.velocity(in: view)
            if velocity.y >= 1500 {
                UIView.animate(withDuration: 0.2 , animations: {
                    self.imageView.frame.origin = CGPoint(x: self.view.frame.origin.x, y: self.view.frame.size.height)
                }, completion: { (isCompleted) in
                    if isCompleted {
                        self.animator?.prepareForDismiss(from: self.imageView)
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.imageView.center = self.originalPosition
                })
            }
        default:
            break
        }
    }
}

//MARK: Helper
extension ImageViewerViewController {
    func aspectFitRect(forSize size: CGSize, insideRect: CGRect) -> CGRect {
        return AVMakeRect(aspectRatio: size, insideRect: insideRect)
    }
}

//MARK: UIScrollViewDelegate
extension ImageViewerViewController: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard let image = imageView.image else { return }
        let imageViewSize = aspectFitRect(forSize: image.size, insideRect: imageView.frame)
        let verticalInsets = -(scrollView.contentSize.height - max(imageViewSize.height, scrollView.bounds.height)) / 2
        let horizontalInsets = -(scrollView.contentSize.width - max(imageViewSize.width, scrollView.bounds.width)) / 2
        scrollView.contentInset = UIEdgeInsets(top: verticalInsets, left: horizontalInsets, bottom: verticalInsets, right: horizontalInsets)
        //        isZooming = scrollView.contentInset == .zero
    }
    
    //    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    //        print(velocity)
    //        if velocity.y > 2 || velocity.y < -2 {
    //            shouldDismiss = true
    //        } else {
    //            shouldDismiss = false
    //        }
    //    }
    //
    //    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    //        if shouldDismiss {
    //            self.dismiss(animated: true, completion: nil)
    //        }
    //    }
}