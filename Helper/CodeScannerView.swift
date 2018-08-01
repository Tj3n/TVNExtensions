//
//  File.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 11/30/17.
//

import Foundation
import AVFoundation
import UIKit

/** How to use:
 viewDidLoad: Create `CodeScannerView` with [unowned self] callback, add as subview, run `scannerView.startReading` when needed
 viewDidLayoutSubviews: Update `scannerView.scanRect` if needed
**/
public class CodeScannerView: UIView {
    /// Code type to scan
    public var codeTypes: [AVMetadataObject.ObjectType] = [.qr] {
        didSet {
            q.async {
                self.setupMetadataOutput()
            }
        }
    }
    
    /// The rect to capture the metadata
    public var scanRect: CGRect = UIScreen.main.bounds {
        didSet {
            q.async {
                self.setupMetadataOutput()
            }
        }
    }
    
    /// false will freeze instead of stop scanner, call `resumeReading` if freeze, call `stopReading` if stop
    public var stopAfterRead = false
    
    public private(set) var isScanning = false
    public private(set) var isFreezing = false
    
    private var captureSession: AVCaptureSession?
    private weak var captureMetadataOutputObjectsDelegate: AVCaptureMetadataOutputObjectsDelegate?
    private var scanCompleteBlock: ((_ message: String?, _ error: String?)->())?
    private let q = DispatchQueue(label: "CodeScannerViewQueue")
    private lazy var captureMetadataOutput: AVCaptureMetadataOutput = {
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureMetadataOutput.setMetadataObjectsDelegate(captureMetadataOutputObjectsDelegate, queue: q)
        return captureMetadataOutput
    }()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer? {
        didSet {
            oldValue?.removeFromSuperlayer()
            guard let videoPreviewLayer = self.videoPreviewLayer else { return }
            videoPreviewLayer.frame = self.layer.bounds
            self.layer.addSublayer(videoPreviewLayer)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Init with custom AVCaptureMetadataOutputObjectsDelegate
    ///
    /// - Parameters:
    ///   - frame: frame
    ///   - captureMetadataOutputObjectsDelegate: AVCaptureMetadataOutputObjectsDelegate
    public init(frame: CGRect = UIScreen.main.bounds, captureMetadataOutputObjectsDelegate: AVCaptureMetadataOutputObjectsDelegate) {
        super.init(frame: frame)
        self.captureMetadataOutputObjectsDelegate = captureMetadataOutputObjectsDelegate
    }
    
    /// Init with callback closure
    ///
    /// - Parameters:
    ///   - frame: frame
    ///   - scanCompletion: callback closure, must use [unowned self]
    public init(frame: CGRect = UIScreen.main.bounds, scanCompletion: @escaping (_ message: String?, _ error: String?)->() ) {
        super.init(frame: frame)
        self.captureMetadataOutputObjectsDelegate = self
        self.scanCompleteBlock = scanCompletion
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer?.frame = self.bounds
        if isScanning || isFreezing, let videoPreviewLayer = videoPreviewLayer {
            q.async {
                self.updatePreviewLayerOrientation(videoPreviewLayer)
                self.setupMetadataOutput()
            }
        }
    }
    
    deinit {
        stopReading()
    }
    
    public override func removeFromSuperview() {
        stopReading()
        super.removeFromSuperview()
    }
    
    /// Start reading with camera
    ///
    /// - Parameter completion: completion handler
    public func startReading(completion: ((_ error: Error?)->())?) {
        if isFreezing && !isScanning {
            resumeReading()
            completion?(nil)
        }
        
        self.captureSession = AVCaptureSession()
        guard let captureSession = self.captureSession else {
            return
        }
        
        q.async {
            do {
                captureSession.beginConfiguration()
                let captureDevice = AVCaptureDevice.default(for: .video)!
                let input = try AVCaptureDeviceInput(device: captureDevice)
                captureSession.addInput(input)
                let previewLayer = self.setupPreviewLayer(session: captureSession)
                self.setupMetadataOutput()
                captureSession.commitConfiguration()
                captureSession.startRunning()
                
                DispatchQueue.main.async {
                    self.videoPreviewLayer = previewLayer
                    self.isScanning = true
                    completion?(nil)
                }
            } catch {
                captureSession.commitConfiguration()
                completion?(error)
            }
        }
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
        self.updatePreviewLayerOrientation(previewLayer)
        return previewLayer
    }
    
    func setupMetadataOutput() {
        let output = self.captureMetadataOutput
        if let captureSession = self.captureSession, captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        var availableCodeTypes = [AVMetadataObject.ObjectType]()
        codeTypes.forEach({
            if output.availableMetadataObjectTypes.contains($0) {
                availableCodeTypes.append($0)
            }
            output.metadataObjectTypes = availableCodeTypes
        })
        
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
        
        var code: String?
        var error: String?
        
        defer {
            DispatchQueue.main.async {
                self.scanCompleteBlock?(code, error)
            }
        }
        
        guard metadataObjects.count > 0 else {
            error = "Invalid Code"
            return
        }
        
        guard let obj = metadataObjects.first else {
            error = "Invalid Code"
            return
        }
        
        guard codeTypes.contains(obj.type) else {
            error = "Wrong code type or invalid code"
            return
        }
        
        if stopAfterRead {
            performSelector(onMainThread: #selector(stopReading), with: nil, waitUntilDone: false)
        } else {
            performSelector(onMainThread: #selector(freezeReading), with: nil, waitUntilDone: false)
        }
        
        if #available(iOS 10.0, *), UIDevice.current.hasHapticFeedback {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            generator.prepare()
        } else {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
        
        if let readableObj = obj as? AVMetadataMachineReadableCodeObject {
            guard let str = readableObj.stringValue else {
                error = "Invalid Code"
                return
            }
            code = str
        } else {
            error = "Wrong code type or invalid code"
        }
    }
}

