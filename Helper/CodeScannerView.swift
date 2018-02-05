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
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private weak var captureMetadataOutputObjectsDelegate: AVCaptureMetadataOutputObjectsDelegate!
    private var scanCompleteBlock: ((_ message: String, _ error: String?)->())!
    private var scanRect: CGRect!
    public private(set) var isScanning = false
    public var codeTypes: [AVMetadataObject.ObjectType] = [.qr]
    
    // false will freeze instead of stop scanner
    // call `resumeReading` if freeze, call `stopReading` if stop
    public var stopAfterRead = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //Use own AVCaptureMetadataOutputObjectsDelegate delegate
    public init(frame: CGRect = UIScreen.main.bounds, scanRect: CGRect = UIScreen.main.bounds, captureMetadataOutputObjectsDelegate: AVCaptureMetadataOutputObjectsDelegate) {
        super.init(frame: frame)
        self.captureMetadataOutputObjectsDelegate = captureMetadataOutputObjectsDelegate
        self.scanRect = scanRect
    }
    
    //Use view's AVCaptureMetadataOutputObjectsDelegate with completion closure
    public init(frame: CGRect = UIScreen.main.bounds, scanRect: CGRect = UIScreen.main.bounds, scanCompletion: @escaping (_ message: String, _ error: String?)->() ) {
        super.init(frame: frame)
        self.captureMetadataOutputObjectsDelegate = self
        self.scanCompleteBlock = scanCompletion
        self.scanRect = scanRect
    }
    
    deinit {
        stopReading()
    }
    
    public override func removeFromSuperview() {
        stopReading()
        super.removeFromSuperview()
    }
    
    public func startReading() throws {
        let captureDevice = AVCaptureDevice.default(for: .video)!
        
        let input = try AVCaptureDeviceInput(device: captureDevice)
        captureSession = AVCaptureSession()
        
        guard let captureSession = captureSession else {
            return
        }
        
        captureSession.addInput(input)
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        let q = DispatchQueue(label: "CodeScannerViewQueue")
        captureMetadataOutput.setMetadataObjectsDelegate(captureMetadataOutputObjectsDelegate, queue: q)
        captureMetadataOutput.metadataObjectTypes = codeTypes
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = self.layer.bounds
        self.layer.addSublayer(videoPreviewLayer)
        isScanning = true
        captureSession.startRunning()
        captureMetadataOutput.rectOfInterest = videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: scanRect)
    }
    
    @objc public func stopReading() {
        guard let captureSession = captureSession else {
            return
        }
        
        captureSession.stopRunning()
        self.captureSession = nil
        isScanning = false
        videoPreviewLayer.removeFromSuperlayer()
    }
    
    @objc public func freezeReading() {
        videoPreviewLayer.connection?.isEnabled = false
        isScanning = false
    }
    
    public func resumeReading() {
        videoPreviewLayer.connection?.isEnabled = true
        isScanning = true
    }
}

extension CodeScannerView: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        guard isScanning else { return }
        
        guard metadataObjects.count > 0 else {
            self.scanCompleteBlock("", "Invalid Code")
            return
        }
        
        guard let obj = metadataObjects.first else {
            self.scanCompleteBlock("", "Invalid Code")
            return
        }
        
        guard codeTypes.contains(obj.type) else {
            self.scanCompleteBlock("", "Wrong code type or invalid code")
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
                    self.scanCompleteBlock("", "Invalid Code")
                    return
                }
                self.scanCompleteBlock(str, nil)
            } else {
                self.scanCompleteBlock("", "Wrong code type or invalid code")
            }
        }
    }
}
