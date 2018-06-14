//
//  ParticleView.swift
//  Passport
//
//  Created by Tien Nhat Vu on 6/13/18.
//  Copyright © 2018 Paymentwall. All rights reserved.
//

import Foundation
import SpriteKit
import TVNExtensions

public class ParticleView: SKView {
    public lazy var particleScene: ParticleScene = {
        let particleScene = ParticleScene(size: self.bounds.size)
        return particleScene
    }()
    
    public var shouldChangeLineOpacityWithMaxDistance = true {
        didSet {
            particleScene.shouldChangeLineOpacityWithMaxDistance = shouldChangeLineOpacityWithMaxDistance
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.particleScene = ParticleScene(size: frame.size)
        particleScene.scaleMode = .aspectFill
        particleScene.backgroundColor = UIColor(hexString: "231553")
        self.presentScene(particleScene)
    }
    
    public init(frame: CGRect,
         maxDistance: CGFloat = 0,
         maxPoints: Int = 20,
         nodeColor: UIColor = .white,
         lineColor: UIColor = .white,
         nodeSizeRange: ClosedRange<CGFloat> = 5...10,
         speedRange: ClosedRange<CGFloat> = 10...50,
         lineWidth: CGFloat = 1,
         backgroundColor: UIColor = UIColor(hexString: "231553")) {
        super.init(frame: frame)
        let scene = ParticleScene(size: frame.size, maxDistance: maxDistance, maxPoints: maxPoints, nodeColor: nodeColor, lineColor: lineColor, nodeSizeRange: nodeSizeRange, speedRange: speedRange, lineWidth: lineWidth)
        self.particleScene = scene
        particleScene.scaleMode = .aspectFill
        particleScene.backgroundColor = backgroundColor
        self.presentScene(particleScene)
    }
    
    public init(frame: CGRect, scene: ParticleScene) {
        super.init(frame: frame)
        self.particleScene = scene
        self.presentScene(particleScene)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.presentScene(particleScene)
    }
    
    override public func layoutSubviews() {
        particleScene.size = self.bounds.size
    }
    
    public func start() {
        isPaused = false
    }
    
    public func pause() {
        isPaused = true
    }
}

public class ParticleScene: SKScene {
    let maxDistance: CGFloat
    let maxPoints: Int
    let nodeColor: UIColor
    let lineColor: UIColor
    let nodeSizeRange: ClosedRange<CGFloat>
    let speedRange: ClosedRange<CGFloat>
    let lineWidth: CGFloat
    
    public var shouldChangeLineOpacityWithMaxDistance = true
    
    private var nodes = [SKSpriteNode]()
    private var lines = [SKShapeNode]() {
        willSet {
            self.removeChildren(in: lines)
        }
        didSet {
            self.lines.forEach({ self.addChild($0) })
        }
    }
    
    private let defaultMaxDistance: CGFloat = {
        return min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 2.5
    }()
    
    public init(size: CGSize,
         maxDistance: CGFloat = 0,
         maxPoints: Int = 20,
         nodeColor: UIColor = .white,
         lineColor: UIColor = .white,
         nodeSizeRange: ClosedRange<CGFloat> = 5...10,
         speedRange: ClosedRange<CGFloat> = 10...50,
         lineWidth: CGFloat = 1) {
        self.maxDistance = maxDistance > 0 ? maxDistance : defaultMaxDistance
        self.maxPoints = maxPoints
        self.nodeColor = nodeColor
        self.lineColor = lineColor
        self.nodeSizeRange = nodeSizeRange
        self.speedRange = speedRange
        self.lineWidth = lineWidth
        
        super.init(size: size)
        
        setupNodes()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.maxDistance = defaultMaxDistance
        self.maxPoints = 20
        self.nodeColor = .white
        self.lineColor = .white
        self.nodeSizeRange = 2...8
        self.speedRange = 10...50
        self.lineWidth = 1
        super.init(coder: aDecoder)
    }
    
    func getRoundNode(size: CGFloat, color: UIColor) -> SKSpriteNode {
        let rectSize = CGSize(width: size, height: size)
        UIGraphicsBeginImageContextWithOptions(rectSize, true, 0)
        color.setFill()
        let rect = CGRect(origin: .zero, size: rectSize)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: size/2)
        path.fill()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let texture = SKTexture(image: img!)
        return SKSpriteNode(texture: texture)
    }
    
    func setupNodes() {
        (0...maxPoints).forEach({ _ in
            let node = getRoundNode(size: CGFloat.random(between: nodeSizeRange.lowerBound, and: nodeSizeRange.upperBound),
                                    color: nodeColor)
            node.position = CGPoint(x: CGFloat.random(between: 0, and: size.width),
                                    y: CGFloat.random(between: 0, and: size.height))
            nodes.append(node)
            self.addChild(node)
            
            let action = generateNodeAction(direction: CGFloat.random(between: 0, and: 2 * .pi),
                                            speed: CGFloat.random(between: speedRange.lowerBound, and: speedRange.upperBound),
                                            midPoint: node.position)
            node.run(action)
        })
    }
    
    func generateNodeAction(direction: CGFloat, speed: CGFloat, midPoint: CGPoint) -> SKAction {
        let directionX = speed * cos(direction)
        let directionY = speed * sin(direction)
        
        let action = SKAction.customAction(withDuration: Double(HUGE)) { node, elapsedTime in
            DispatchQueue.global(qos: .userInteractive).async {
                let w = self.size.width
                let h = self.size.height
                
                let newX = (midPoint.x + directionX * elapsedTime).remainder(dividingBy: w)
                let newY = (midPoint.y + directionY * elapsedTime).remainder(dividingBy: h)
                
                DispatchQueue.main.async {
                    node.position = CGPoint(x: newX < 0 ? w+newX : newX, y: newY < 0 ? h+newY : newY)
                }
            }
        }
        return action
    }

    override public func update(_ currentTime: TimeInterval) {
        createLines()
    }
    
    func createLines() {
        DispatchQueue.global(qos: .userInitiated).async {
            var newLines = [SKShapeNode]()
            for i in 0..<self.nodes.count {
                for j in i+1..<self.nodes.count {
                    let iNode = self.nodes[i]
                    let jNode = self.nodes[j]
                    let ijDistanceDoubled = pow((iNode.position.x - jNode.position.x).fastFloor(), 2) + pow((iNode.position.y - jNode.position.y).fastFloor(), 2)
                    
                    let maxDistanceDoubled = pow(self.maxDistance, 2)
                    if ijDistanceDoubled < maxDistanceDoubled {
                        let pathToDraw: CGMutablePath = CGMutablePath()
                        let line:SKShapeNode = SKShapeNode(path:pathToDraw)
                        
                        pathToDraw.move(to: iNode.position)
                        pathToDraw.addLine(to: jNode.position)
                        
                        line.path = pathToDraw
                        line.lineWidth = self.lineWidth
                        line.strokeColor = self.shouldChangeLineOpacityWithMaxDistance ? self.lineColor.withAlphaComponent(1 - ijDistanceDoubled/maxDistanceDoubled) : self.lineColor
                        
                        newLines.append(line)
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.lines = newLines
            }
        }
    }
}
