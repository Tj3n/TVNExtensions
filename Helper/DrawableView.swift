//
//  DrawableView.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 12/12/17.
//

import UIKit

@IBDesignable
public class DrawableView: UIView {
    
    @IBInspectable public var lineColor: UIColor = UIColor.black {
        didSet {
            drawableView.lineColor = lineColor
        }
    }

    @IBInspectable public var lineWidth: CGFloat = 2.0 {
        didSet {
            drawableView.lineWidth = lineWidth
        }
    }
    @IBInspectable public var backgroundImage: UIImage? = nil {
        didSet {
            backgroundImageView.image = backgroundImage
            backgroundImageView.contentMode = .scaleAspectFit
        }
    }
    
    public var erasing = false {
        didSet {
            drawableView.erasing = erasing
        }
    }
    
    public var canvasImage: UIImage? {
        didSet {
            drawableView.canvasImage = canvasImage
        }
    }
    
    private var backgroundImageView = UIImageView(frame: CGRect.zero)
    private var drawableView: PrivateDrawableView = PrivateDrawableView(frame: CGRect.zero)

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        backgroundImageView.addTo(self)
        backgroundImageView.centerX(to: self)
        backgroundImageView.centerY(to: self)
        
        drawableView.addTo(self)
        drawableView.backgroundColor = .clear
        drawableView.isOpaque = false
        drawableView.edgesToSuperView()
    }
    
    public func getImage() -> UIImage? {
        return drawableView.getImage()
    }
}

class PrivateDrawableView: UIView {
    var lineColor: UIColor = UIColor.black
    var lineWidth: CGFloat = 2.0
    var erasing = false
    var canvasImage: UIImage?
    
    private var currentPoint = CGPoint.zero
    private var previousPoint = CGPoint.zero
    private var previousPreviousPoint = CGPoint.zero
    private var empty = true
    private var path: CGMutablePath = CGMutablePath()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func draw(_ rect: CGRect) {
        if !erasing {
            backgroundColor?.set()
            UIRectFill(rect)
            let context = UIGraphicsGetCurrentContext()!
            context.addPath(path)
            context.setLineCap(.round)
            context.setLineWidth(lineWidth)
            context.setStrokeColor(lineColor.cgColor)
            context.strokePath()
        }
        else {
            backgroundColor?.set()
            UIRectFill(rect)
            let context = UIGraphicsGetCurrentContext()!
            context.setBlendMode(.clear)
            context.addPath(path)
            context.setLineCap(.round)
            context.setLineWidth(lineWidth)
            context.strokePath()
        }
    }
    
    func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) * 0.5, y: (p1.y + p2.y) * 0.5)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        previousPoint = (touch?.previousLocation(in: self)) ?? CGPoint.zero
        previousPreviousPoint = (touch?.previousLocation(in: self)) ?? CGPoint.zero
        currentPoint = (touch?.location(in: self)) ?? CGPoint.zero
        touchesMoved(touches, with: event)
        empty = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let point = touch.location(in: self)
        let dx: CGFloat = point.x - currentPoint.x
        let dy: CGFloat = point.y - currentPoint.y
        if (dx * dx + dy * dy) < pow(lineWidth, 2.0) {
            return
        }
        previousPreviousPoint = previousPoint
        previousPoint = (touch.previousLocation(in: self))
        currentPoint = (touch.location(in: self))
        let mid1: CGPoint = midPoint(p1: previousPoint, p2: previousPreviousPoint)
        let mid2: CGPoint = midPoint(p1: currentPoint, p2: previousPoint)
        let subpath: CGMutablePath = CGMutablePath()
        subpath.move(to: CGPoint(x: mid1.x, y: mid1.y), transform: .identity)
        subpath.addQuadCurve(to: CGPoint(x: mid2.x, y: mid2.y), control: CGPoint(x: previousPoint.x, y: previousPoint.y), transform: .identity)
        let bounds: CGRect = subpath.boundingBox
        let drawBox: CGRect = bounds.insetBy(dx: -0.5 * lineWidth, dy: -0.5 * lineWidth)
        path.addPath(subpath, transform: .identity)
        setNeedsDisplay(drawBox)
    }
    
    func getImage() -> UIImage? {
        guard !empty else { return nil }
        UIGraphicsBeginImageContext(bounds.size)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let drawImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIGraphicsBeginImageContext(bounds.size)
        if let canvasImage = canvasImage {
            canvasImage.draw(in: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height))
        }
        drawImage?.draw(in: CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height), blendMode: .normal, alpha: 0.8)
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

