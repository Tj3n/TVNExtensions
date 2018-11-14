**CALayer** Animatable layer properties -- the other CALayer types below all inherit from CALayer, so these also apply to those:

    anchorPoint
    backgroundColor
    backgroundFilters
    borderColor
    borderWidth
    bounds
    compositingFilter
    contents
    contentsRect
    cornerRadius
    doubleSided
    filters
    frame
    hidden
    mask
    masksToBounds
    opacity
    position
    shadowColor
    shadowOffset
    shadowOpacity
    shadowPath
    shadowRadius
    sublayers
    sublayerTransform
    transform
    zPosition

**CAEmitterLayer** animatable properties:

    emitterPosition
    emitterZPosition
    emitterSize

**CAGradientLayer** animatable properties:

    colors
    locations
    endPoint
    startPoint

**CAReplicatorLayer** animatable properties:

    instanceDelay
    instanceTransform
    instanceRedOffset
    instanceGreenOffset
    instanceBlueOffset
    instanceAlphaOffset

**CAShapeLayer** animatable properties:

    fillColor
    lineDashPhase
    lineWidth
    miterLimit
    strokeColor
    strokeStart
    strokeEnd


**CATextLayer** animatable properties:

    fontSize
    foregroundColor

**CATiledLayer** animatable properties:

    I feel like tileSize is animatable, but documentation doesn't agree.
    
**CATransform3D** Key-Value Coding Extensions:

    rotation.x
    rotation.y
    rotation.z
    rotation
    scale.x
    scale.y
    scale.z
    scale
    translation.x
    translation.y
    translation.z

**CGPoint** keyPaths:

    x
    y

**CGSize** keyPaths:

    width
    height

**CGRect** keyPaths:

    origin
    origin.x
    origin.y
    size
    size.width
    size.height

[Reference](https://stackoverflow.com/questions/44230796/what-is-the-full-keypath-list-for-cabasicanimation?rq=1)