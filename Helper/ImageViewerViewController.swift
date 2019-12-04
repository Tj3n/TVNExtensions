//
//  ImageViewerViewController.swift
//
//  Created by TienVu on 11/6/18.
//

import UIKit
import AVFoundation
#if canImport(Kingfisher)
import Kingfisher
#endif

/// Full screen Image Viewer, to handle URL with Kingfisher add to podfile: pod 'TVNExtensions/Kingfisher'
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
        v.addGestureRecognizer(doubleTapGesture)
        panGesture.delegate = self
        return v
    }()
    
    private lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
    private lazy var doubleTapGesture: UITapGestureRecognizer = {
        let g = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapGesture(_:)))
        g.numberOfTapsRequired = 2
        return g
    }()
    
    private lazy var blurredView: UIVisualEffectView = {
        let v = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        return v
    }()
    
    private lazy var closeBtn: UIButton = {
        var v: UIButton
        if #available(iOS 13.0, *) {
            v = UIButton(type: .close)
        } else {
            v = UIButton(type: .roundedRect)
            v.setTitle("X", for: .normal)
            v.tintColor = .white
            v.borderWidth = 1
            v.borderColor = .white
            v.cornerRadius = 15
        }
        v.addTarget(self, action: #selector(closeBtnTouch(_:)), for: .touchUpInside)
        return v
    }()
    
    private var image: UIImage?
    private lazy var originalPosition: CGPoint = view.center
    private var imageURL: URL?
    private var animator: ImageViewerAnimator?
    //    private var isZooming = false
    //    var shouldDismiss = false
    private var downloadedImgCompletion: ((UIImage?) -> ())?
    
    /// Create imageViewer with transition animation from view/imageview/cell...
    ///
    /// - Parameters:
    ///   - image: image
    ///   - view: starting view
    ///   - clippingTransition: Set to false if the from view has bound clipping
    convenience public init(image: UIImage?, from view: UIView?, clippingTransition: Bool = true) {
        self.init(nibName:nil, bundle:nil)
        self.image = image
        setupModalPresention(from: view, image: image, clippingTransition: clippingTransition)
    }
    
    /// Create imageViewer from URL with transition animation from view/imageview/cell...
    ///
    /// - Parameters:
    ///   - imageURL: image URL
    ///   - placeholderImage: placeholder image, can be nil
    ///   - view: starting view
    ///   - clippingTransition: Set to false if the from view has bound clipping
    ///   - completion: completion closure after finished image downloading
    convenience public init(imageURL: URL, placeholderImage: UIImage?, from view: UIView?, clippingTransition: Bool = true, completion: ((UIImage?) -> ())?) {
        self.init(nibName:nil, bundle:nil)
        self.imageURL = imageURL
        self.image = placeholderImage
        self.downloadedImgCompletion = completion
        setupModalPresention(from: view, image: placeholderImage, clippingTransition: clippingTransition)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupView()
        calculateZoomScale()
        
        if let url = imageURL {
            #if canImport(Kingfisher)
            self.imageView.kf.indicatorType = .activity
            self.imageView.kf.setImage(with: url, placeholder: image) { [weak self] (img, error, cacheType, url) in
                self?.image = img
                self?.calculateZoomScale()
                self?.downloadedImgCompletion?(img)
            }
            #else
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async { [weak self] in
                        let newImage = UIImage(data: imageData)
                        self?.image = newImage
                        self?.imageView.image = newImage
                        self?.calculateZoomScale()
                        self?.downloadedImgCompletion?(newImage)
                    }
                }
            }
            #endif
        }
    }
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupModalPresention(from view: UIView?, image: UIImage?, clippingTransition: Bool) {
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        modalPresentationCapturesStatusBarAppearance = true
        
        guard let view = view, let image = image else { return }
        animator = ImageViewerAnimator(from: view, image: image, clippingTransition: clippingTransition)
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
        view.addSubview(closeBtn)
        
        blurredView.edgesToSuperView()
        scrollView.edgesToSuperView()
        imageView.edgesToSuperView()
        imageView.setRelativeWidth(to: view)
        imageView.setRelativeHeight(to: view)
        closeBtn.topMargin(to: view, by: 16)
        closeBtn.right(to: view, by: 16)
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .dark //Light mode for close button will be hard to see
        } else {
            closeBtn.setWidth(30)
            closeBtn.setHeight(30)
        }
    }
    
    @objc func closeBtnTouch(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState, animations: {
            if #available(iOS 13.0, *) {
                self.imageView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
            } else {
                self.imageView.layer.frame.origin = CGPoint(x: self.view.frame.origin.x, y: self.view.frame.size.height)
            }
        }) { (isCompleted) in
            if isCompleted {
                self.animator?.prepareForDismiss(from: self.imageView)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    /// If horizontal image then get max zoom by height, else by width
    private func calculateZoomScale() {
        scrollView.minimumZoomScale = 1
        guard let image = image else { return }
        let imageViewSize = aspectFitRect(forSize: image.size, insideRect: UIScreen.main.bounds)
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        scrollView.maximumZoomScale = max(screenWidth / imageViewSize.width, screenHeight / imageViewSize.height)
    }
    
    @objc private func handleDoubleTapGesture(_ tapGesture: UITapGestureRecognizer) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            let position = tapGesture.location(in: tapGesture.view)
            let zoomRect = calculateZoomRect(scale: scrollView.maximumZoomScale, center: position)
            scrollView.zoom(to: zoomRect, animated: true)
        }
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
                if #available(iOS 13.0, *) {
                    self.imageView.transform = CGAffineTransform(translationX: translation.x, y: translation.y).concatenating(CGAffineTransform(scaleX: scrollView.zoomScale, y: scrollView.zoomScale))
                }
                UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState, animations: {
                    if #available(iOS 13.0, *) {
                        self.imageView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
                    } else {
                        self.imageView.layer.frame.origin = CGPoint(x: self.view.frame.origin.x, y: self.imageView.frame.size.height)
                    }
                }) { (isCompleted) in
                    if isCompleted {
                        self.animator?.prepareForDismiss(from: self.imageView)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
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
    func calculateZoomRect(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width  = imageView.frame.size.width / scale
        let newCenter = scrollView.convert(center, from: imageView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    func aspectFitRect(forSize size: CGSize, insideRect: CGRect) -> CGRect {
        return AVMakeRect(aspectRatio: size, insideRect: insideRect)
    }
}

//MARK:
extension ImageViewerViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if #available(iOS 13, *) {
            if (gestureRecognizer is UIPanGestureRecognizer || gestureRecognizer is UIRotationGestureRecognizer) {
                return true
            }
        }
        return false
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
