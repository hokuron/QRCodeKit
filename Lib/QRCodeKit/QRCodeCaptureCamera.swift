//
//  QRCodeCaptureCamera.swift
//  QRCodeKit
//
//  Created by hokuron on 2015/03/20.
//  Copyright © 2015年 Takuma Shimizu. All rights reserved.
//

import AVFoundation

public protocol QRCodeCaptureCameraDelegate: class {
    func qrCodeCaptureCamera(captureCamera: QRCodeCaptureCamera, didCaptureQRCodeMetadataObjects QRCodeMetadataObjects: [AVMetadataMachineReadableCodeObject])
}

public class QRCodeCaptureCamera {
   
    public private(set) weak var delegate: QRCodeCaptureCameraDelegate?
    
    /// Whether to deliver the same capture results to the delegate. The default value is `false`.
    public var allowsSameValueCapturing: Bool {
        didSet {
            captureMetadataOutputObjectsDelegate.allowsSameValueCapturing = allowsSameValueCapturing
        }
    }
    
    public internal(set) lazy var previewLayer: AVCaptureVideoPreviewLayer! = AVCaptureVideoPreviewLayer(session: self.captureSession)
    
    public private(set) var captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    
    public let sessionQueue: dispatch_queue_t = dispatch_queue_create("com.hokuron.QRCodeKit.QRCodeCaptureCamera.sessionQueue", DISPATCH_QUEUE_SERIAL)
    public private(set) var captureSession = AVCaptureSession()

    let metadataQueue: dispatch_queue_t = dispatch_queue_create("com.hokuron.QRCodeKit.QRCodeCaptureCamera.metadataQueue", DISPATCH_QUEUE_SERIAL)
    lazy var metadataOutput: AVCaptureMetadataOutput = {
        let metadata = AVCaptureMetadataOutput()
        metadata.setMetadataObjectsDelegate(self.captureMetadataOutputObjectsDelegate, queue: self.metadataQueue)
        return metadata
    }()

    lazy var captureMetadataOutputObjectsDelegate: CaptureMetadataOutputObjectsDelegate = {
        let _delegate = CaptureMetadataOutputObjectsDelegate(allowsSameValueCapturing: self.allowsSameValueCapturing) { _, metadataObjects, _ in
            let metadataQRCodeObjects = metadataObjects.filter { $0.type == AVMetadataObjectTypeQRCode }
            dispatch_async(dispatch_get_main_queue()) {
                self.delegate?.qrCodeCaptureCamera(self, didCaptureQRCodeMetadataObjects: metadataQRCodeObjects)
            }
        }
        return _delegate
    }()
    
/// - Parameters:
///     - delegate: The delegate object to deliver when new QR code metadata objects become available.
///     - allowsSameValueCapturing: The boolean value indicating whether to deliver the same capture results to the delegate. The default value is `false`.
///
/// - Throws: `AVError`
    public init(delegate: QRCodeCaptureCameraDelegate, allowsSameValueCapturing: Bool = false) throws {
        self.delegate = delegate
        self.allowsSameValueCapturing = allowsSameValueCapturing
        try changeCaptureSession(captureSession)
    }
    
    /// Session starts running and resets focus and exposure.
    /// In addition, delivery to the delegate of the capture results will be enabled again.
    public func startSessionRunning() {
        captureMetadataOutputObjectsDelegate.activateCapturing()
        dispatch_async(sessionQueue) {
            self.captureSession.startRunning()
        }
        resetFocusAndExposure()
    }
    
    public func stopSessionRunning() {
        dispatch_async(sessionQueue) {
            self.captureSession.stopRunning()
        }
    }
    
    public func resetFocusAndExposure() {
        // TODO: Split into AVCaptureDevice+FocusAndExposure extension
        
        guard case .Some = try? captureDevice.lockForConfiguration() else { return print("A configuration lock cannot be acquired.") }
        
        let centerPoint = CGPoint(x: 0.5, y: 0.5)
        
        if captureDevice.focusPointOfInterestSupported && captureDevice.isFocusModeSupported(.ContinuousAutoFocus) {
            captureDevice.focusPointOfInterest = centerPoint
            captureDevice.focusMode = .ContinuousAutoFocus
        }
        
        if captureDevice.exposurePointOfInterestSupported && captureDevice.isExposureModeSupported(.ContinuousAutoExposure) {
            captureDevice.exposurePointOfInterest = centerPoint
            captureDevice.exposureMode = .ContinuousAutoExposure
        }
        
        captureDevice.unlockForConfiguration()
    }
    
    /// Add capture input and output to the passed `captureSession`. And change session of `previewLayer` to the passed `captureSession`.
    /// - Parameter captureSession: The new `AVCaptureSession`
    /// - Throws: `AVError`
    public func changeCaptureSession(captureSession: AVCaptureSession) throws {
        try changeCaptureDevice(captureDevice)
        
        dispatch_async(sessionQueue) {
            let metadataOutput = self.metadataOutput
            
            captureSession.beginConfiguration()
            
            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)
                metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            }
            
            if captureSession.canSetSessionPreset(AVCaptureSessionPresetPhoto) {
                captureSession.sessionPreset = AVCaptureSessionPresetPhoto
            }
            
            captureSession.commitConfiguration()
        }
        
        previewLayer.session = captureSession
        self.captureSession = captureSession
    }
    
    /// Change capture input for capture session
    /// - Parameter captureDevice: The new desired `AVCaptureDevice`
    /// - Throws: `AVError`
    public func changeCaptureDevice(captureDevice: AVCaptureDevice) throws {
        let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
        
        let captureSession = self.captureSession
        
        dispatch_async(sessionQueue) {
            captureSession.beginConfiguration()
            
            (captureSession.inputs.filter { $0 is AVCaptureInput } as! [AVCaptureInput]).forEach { captureSession.removeInput($0) }
            
            if captureSession.canAddInput(deviceInput) {
                captureSession.addInput(deviceInput)
            }
            
            captureSession.commitConfiguration()
        }
        
        self.captureDevice = captureDevice
    }
    
}


// MARK: - Capture metadata output objects delegate

extension QRCodeCaptureCamera {
    class CaptureMetadataOutputObjectsDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        
        var allowsSameValueCapturing: Bool
        let captureHandler: (AVCaptureOutput, [AVMetadataMachineReadableCodeObject], AVCaptureConnection) -> Void
        
        var latestCapturedMetadataObjects: [CaptureMetadataQRCodeObject] = []
        
        init(allowsSameValueCapturing: Bool, captureHandler: (AVCaptureOutput, [AVMetadataMachineReadableCodeObject], AVCaptureConnection) -> Void) {
            self.allowsSameValueCapturing = allowsSameValueCapturing
            self.captureHandler = captureHandler
        }
        
        func activateCapturing() {
            latestCapturedMetadataObjects = []
        }
        
        func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
            guard let metadataMachineReadableCodeObjects = metadataObjects as? [AVMetadataMachineReadableCodeObject] else { return }
            
            let captureMetadataQRCodeObjects = metadataMachineReadableCodeObjects.map { CaptureMetadataQRCodeObject(metadataObject: $0) }
            
            guard !allowsSameValueCapturing else { return captureHandler(captureOutput, metadataMachineReadableCodeObjects, connection) }
            
            guard latestCapturedMetadataObjects != captureMetadataQRCodeObjects else { return }
            
            latestCapturedMetadataObjects = captureMetadataQRCodeObjects
            captureHandler(captureOutput, metadataMachineReadableCodeObjects, connection)
        }
        
    }
}

