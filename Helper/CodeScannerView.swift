//
//  File.swift
//  TVNExtensions
//
//  Created by Tien Nhat Vu on 11/30/17.
//

import Foundation
import AVFoundation
import UIKit

extension AVAuthorizationStatus: Error, LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .denied:
            return "Please enable Camera access in Settings to use"
        case .restricted:
            return "Your permission to use Camera is restricted"
        default:
            return nil
        }
    }
}

public enum CodeScannerViewError: Error, LocalizedError {
    case invalidCode
    case wrongCodeTypeOrInvalid
    
    public var errorDescription: String? {
        switch self {
        case .invalidCode:
            return "Invalid Code"
        case .wrongCodeTypeOrInvalid:
            return "Wrong code type or invalid code"
        }
    }
}

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
    
    weak var captureMetadataOutputObjectsDelegate: AVCaptureMetadataOutputObjectsDelegate?
    private var captureSession: AVCaptureSession?
    internal var scanCompleteBlock: ((_ message: String?, _ error: CodeScannerViewError?)->())?
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
        self.captureMetadataOutputObjectsDelegate = self
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
    public init(frame: CGRect = UIScreen.main.bounds, scanCompletion: @escaping (_ message: String?, _ error: CodeScannerViewError?)->() ) {
        super.init(frame: frame)
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
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .restricted, .denied:
            completion?(status)
            return
        case .notDetermined, .authorized:
            break
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
        var error: CodeScannerViewError?
        
        defer {
            DispatchQueue.main.async {
                self.scanCompleteBlock?(code, error)
            }
        }
        
        guard metadataObjects.count > 0 else {
            error = .invalidCode
            return
        }
        
        guard let obj = metadataObjects.first else {
            error = .invalidCode
            return
        }
        
        guard codeTypes.contains(obj.type) else {
            error = .wrongCodeTypeOrInvalid
            return
        }
        
        if stopAfterRead {
            performSelector(onMainThread: #selector(stopReading), with: nil, waitUntilDone: false)
        } else {
            performSelector(onMainThread: #selector(freezeReading), with: nil, waitUntilDone: false)
        }
        
        if #available(iOS 10.0, *), UIDevice.current.hasHapticFeedback {
            DispatchQueue.main.async {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                generator.prepare()
            }
        } else {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
        
        if let readableObj = obj as? AVMetadataMachineReadableCodeObject {
            guard let str = readableObj.stringValue else {
                error = .invalidCode
                return
            }
            code = str
        } else {
            error = .wrongCodeTypeOrInvalid
        }
    }
}

extension CodeScannerView {
    
    /// Check the permission for camera usage, if .notDetermined - request access, if .authorized, return nil, otherwise return an alertController to open the Settings page for the app.
    ///
    /// - Parameters:
    ///   - mediaType: AVMediaType
    ///   - cancelHandler: cancelHandler for the alertController, can use to dismiss the viewController
    /// - Returns: nullable UIAlertController
    public class func checkPermissionToGetOpenSettingsAlert(for mediaType: AVMediaType = .video, cancelHandler: ((UIAlertAction)->())?) -> UIAlertController? {
        var status = AVCaptureDevice.authorizationStatus(for: mediaType)
        switch status {
        case .restricted, .denied:
            return getAlertForSettings(cancelHandler: cancelHandler)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                status = granted ? .authorized : .denied
            }
            break
        default:
            break
        }
        return status == .denied ? getAlertForSettings(cancelHandler: cancelHandler) : nil
    }
    
    class func getAlertForSettings(cancelHandler: ((UIAlertAction)->())?) -> UIAlertController {
        let appName = UIApplication.appName()
        let alert = UIAlertController(title: "Unable to access camera", message: "Go to iOS \"Settings\" -> \"\(appName)\" to allow \(appName) to access your camera.", preferredStyle: .alert, cancelTitle: "Cancel", cancelHandler: cancelHandler)
        let okAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.openURL(settingsURL)
            }
        }
        alert.addAction(okAction)
        return alert
    }
}
