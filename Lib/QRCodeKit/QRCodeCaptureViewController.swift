//
//  QRCodeCaptureViewController.swift
//  QRCodeKit
//
//  Created by hokuron on 2015/11/03.
//  Copyright © 2015年 Takuma Shimizu. All rights reserved.
//

import UIKit
import AVFoundation

public class QRCodeCaptureViewController: UIViewController {
    
    public weak var delegate: QRCodeCaptureCameraDelegate? {
        didSet {
            guard let delegate = delegate else { return }
            
            do {
                camera = try QRCodeCaptureCamera.init(delegate: delegate)
            } catch {
                assertionFailure("Failed to initialize camera. error=\(error)")
            }
        }
    }
    
    public var camera: QRCodeCaptureCamera?
    
    
    deinit {
        camera?.stopSessionRunning()
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupPreviewLayer()
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        camera?.startSessionRunning()
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let interfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        camera?.previewLayer.connection.videoOrientation = AVCaptureVideoOrientation(interfaceOrientation)
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        camera?.stopSessionRunning()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        camera?.previewLayer.frame = view.layer.bounds
    }
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        let deviceOrientation = UIDevice.currentDevice().orientation
        guard let videoOrientation = AVCaptureVideoOrientation(deviceOrientation) else { return }
        camera?.previewLayer.connection.videoOrientation = videoOrientation
    }
    
    func setupPreviewLayer() {
        guard let previewLayer = camera?.previewLayer else { return }
        
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        view.layer.addSublayer(previewLayer)
    }
    
}


public extension AVCaptureVideoOrientation {
    
    public init(_ interface: UIInterfaceOrientation) {
        switch interface {
        case .PortraitUpsideDown: self = .PortraitUpsideDown
        case .LandscapeLeft: self = .LandscapeLeft
        case .LandscapeRight: self = .LandscapeRight
        default: self = .Portrait
        }
    }
    
    public init?(_ device: UIDeviceOrientation) {
        switch device {
        case .Portrait: self = .Portrait
        case .PortraitUpsideDown: self = .PortraitUpsideDown
        case .LandscapeLeft: self = .LandscapeRight
        case .LandscapeRight: self = .LandscapeLeft
        default: return nil
        }
    }
    
}
