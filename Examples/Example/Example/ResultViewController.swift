//
//  ResultViewController.swift
//  Example
//
//  Created by hokuron on 2015/11/04.
//  Copyright © 2015年 Takuma Shimizu. All rights reserved.
//

import UIKit
import class AVFoundation.AVMetadataMachineReadableCodeObject

final class ResultViewController: UIViewController {

    @IBOutlet
    private weak var label: UILabel!
    
    var qrCodeObject: AVMetadataMachineReadableCodeObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = qrCodeObject?.stringValue
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
