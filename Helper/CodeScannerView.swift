//
//  File.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 11/30/17.
//

import Foundation
import AVFoundation
import UIKit

public class CodeScannerView: UIView {
    private var captureSession: AVCaptureSession?
    private weak var captureMetadataOutputObjectsDelegate: AVCaptureMetadataOutputObjectsDelegate?
    private var scanCompleteBlock: ((_ message: String, _ error: String?)->())?
    
    let q = DispatchQueue(label: "CodeScannerViewQueue")
    
    private lazy var captureMetadataOutput: AVCaptureMetadataOutput = {
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureMetadataOutput.setMetadataObjectsDelegate(captureMetadataOutputObjectsDelegate, queue: q)
        return captureMetadataOutput
    }()
    
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer? {
        didSet {
            oldValue?.removeFromSuperlayer()
            guard let videoPreviewLayer = videoPreviewLayer else { return }
            self.layer.addSublayer(videoPreviewLayer)
            updatePreviewLayerOrientation(videoPreviewLayer)
        }
    }
    
    /// Code type to scan
    public var codeTypes: [AVMetadataObject.ObjectType] = [.qr] {
        didSet {
            setupMetadataOutput()
        }
    }
    
    /// The rect to capture the metadata
    public var scanRect: CGRect = UIScreen.main.bounds {
        didSet {
            setupMetadataOutput()
        }
    }
    
    /// false will freeze instead of stop scanner, call `resumeReading` if freeze, call `stopReading` if stop
    public var stopAfterRead = false
    
    public private(set) var isScanning = false
    public private(set) var isFreezing = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //Use own AVCaptureMetadataOutputObjectsDelegate delegate
    public init(frame: CGRect = UIScreen.main.bounds, captureMetadataOutputObjectsDelegate: AVCaptureMetadataOutputObjectsDelegate) {
        super.init(frame: frame)
        self.captureMetadataOutputObjectsDelegate = captureMetadataOutputObjectsDelegate
    }
    
    //Use view's AVCaptureMetadataOutputObjectsDelegate with completion closure
    public init(frame: CGRect = UIScreen.main.bounds, scanCompletion: @escaping (_ message: String, _ error: String?)->() ) {
        super.init(frame: frame)
        self.captureMetadataOutputObjectsDelegate = self
        self.scanCompleteBlock = scanCompletion
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer?.frame = self.bounds
        if isScanning || isFreezing, let videoPreviewLayer = videoPreviewLayer {
            updatePreviewLayerOrientation(videoPreviewLayer)
            setupMetadataOutput()
        }
    }
    
    deinit {
        stopReading()
    }
    
    public override func removeFromSuperview() {
        stopReading()
        super.removeFromSuperview()
    }
    
    public func startReading() throws {
        if isFreezing && !isScanning {
            resumeReading()
        }
        
        self.captureSession = AVCaptureSession()
        
        guard let captureSession = self.captureSession else {
            return
        }
        
        let captureDevice = AVCaptureDevice.default(for: .video)!
        let input = try AVCaptureDeviceInput(device: captureDevice)
        captureSession.addInput(input)
        
        self.videoPreviewLayer = setupPreviewLayer(session: captureSession)
        setupMetadataOutput()
        
        self.isScanning = true
        
        captureSession.startRunning()
    }
    
    func updatePreviewLayerOrientation(_ previewLayer: AVCaptureVideoPreviewLayer) {
        guard let previewLayerConnection = previewLayer.connection else {
            return
        }
        
        if previewLayerConnection.isVideoOrientationSupported {
            switch (UIDevice.current.orientation) {
            case .portrait: previewLayerConnection.videoOrientation = .portrait
            case .landscapeRight: previewLayerConnection.videoOrientation = .landscapeLeft
            case .landscapeLeft: previewLayerConnection.videoOrientation = .landscapeRight
            case .portraitUpsideDown: previewLayerConnection.videoOrientation = .portraitUpsideDown
            default: previewLayerConnection.videoOrientation = .portrait
            }
        }
    }
    
    func setupPreviewLayer(session: AVCaptureSession) -> AVCaptureVideoPreviewLayer {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = self.layer.bounds
        return previewLayer
    }
    
    func setupMetadataOutput() {
        let output = self.captureMetadataOutput
        if let captureSession = self.captureSession, captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        if output.availableMetadataObjectTypes.count > 0 {
            output.metadataObjectTypes = codeTypes
        }
        if let previewLayer = videoPreviewLayer {
            output.rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: scanRect)
        }
    }
    
    @objc public func stopReading() {
        guard let captureSession = captureSession else {
            return
        }
        
        captureSession.stopRunning()
        self.captureSession = nil
        isScanning = false
        videoPreviewLayer?.removeFromSuperlayer()
    }
    
    @objc public func freezeReading() {
        videoPreviewLayer?.connection?.isEnabled = false
        isScanning = false
        isFreezing = true
    }
    
    public func resumeReading() {
        videoPreviewLayer?.connection?.isEnabled = true
        isScanning = true
        isFreezing = false
    }
}

extension CodeScannerView: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        guard isScanning else { return }
        
        guard metadataObjects.count > 0 else {
            self.scanCompleteBlock?("", "Invalid Code")
            return
        }
        
        guard let obj = metadataObjects.first else {
            self.scanCompleteBlock?("", "Invalid Code")
            return
        }
        
        guard codeTypes.contains(obj.type) else {
            self.scanCompleteBlock?("", "Wrong code type or invalid code")
            return
        }
        
        if stopAfterRead {
            performSelector(onMainThread: #selector(stopReading), with: nil, waitUntilDone: false)
        } else {
            performSelector(onMainThread: #selector(freezeReading), with: nil, waitUntilDone: false)
        }
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        DispatchQueue.main.async {
            if let readableObj = obj as? AVMetadataMachineReadableCodeObject {
                guard let str = readableObj.stringValue else {
                    self.scanCompleteBlock?("", "Invalid Code")
                    return
                }
                self.scanCompleteBlock?(str, nil)
            } else {
                self.scanCompleteBlock?("", "Wrong code type or invalid code")
            }
        }
    }
}

