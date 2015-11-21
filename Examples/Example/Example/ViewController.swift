//
//  ViewController.swift
//  Example
//
//  Created by hokuron on 2015/11/04.
//  Copyright © 2015年 Takuma Shimizu. All rights reserved.
//

import UIKit
import QRCodeKit
import class AVFoundation.AVMetadataMachineReadableCodeObject

final class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let captureViewController = segue.destinationViewController as? QRCodeCaptureViewController {
            captureViewController.delegate = self
        }
    }

}


extension ViewController: QRCodeCaptureCameraDelegate {
    func qrCodeCaptureCamera(captureCamera: QRCodeCaptureCamera, didCaptureQRCodeMetadataObjects QRCodeMetadataObjects: [AVMetadataMachineReadableCodeObject]) {
        guard let qrCodeObject = QRCodeMetadataObjects.last else { return }
        
        let resultViewController = storyboard!.instantiateViewControllerWithIdentifier("ResultViewController") as! ResultViewController
        resultViewController.qrCodeObject = qrCodeObject
        navigationController?.pushViewController(resultViewController, animated: true)
    }
}

