//
//  LineView.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 6/26/18.
//

import UIKit

public class LineView: UIView {

    @IBInspectable public var lineColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable public var dashPhase: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable public var dashLength: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var dashLengthPatterns: [CGFloat]?
    public var lineJoin: CGLineJoin = .round
    public var lineCap: CGLineCap = .butt
    
    @IBInspectable public var masksToBounds: Bool {
        get {
            return self.layer.masksToBounds
        }
        set {
            self.layer.masksToBounds = newValue
        }
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override public func draw(_ rect: CGRect) {
        // Drawing code
        guard let context = UIGraphicsGetCurrentContext() else {
            fatalError("No context")
        }
        context.setLineWidth(rect.size.height)
        context.setLineDash(phase: dashPhase, lengths: dashLengthPatterns ?? [dashLength])
        context.setLineJoin(lineJoin)
        context.setLineCap(lineCap)
        context.setStrokeColor(lineColor.cgColor)
        context.move(to: .zero)
        context.addLine(to: CGPoint(x: rect.maxX, y: 0))
        context.strokePath()
        context.saveGState()
        
        setNeedsDisplay()
    }

}
