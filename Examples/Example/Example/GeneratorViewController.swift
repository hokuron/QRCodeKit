//
//  GeneratorViewController.swift
//  Example
//
//  Created by hokuron on 2015/11/16.
//  Copyright © 2015年 Takuma Shimizu. All rights reserved.
//

import UIKit
import class QRCodeKit.QRCodeGenerator

class GeneratorViewController: UIViewController {
    
    @IBOutlet
    private weak var textField: UITextField!
    
    @IBOutlet
    private weak var button: UIButton!
    
    @IBOutlet
    private weak var imageView: UIImageView! {
        didSet {
            imageView?.layer.magnificationFilter = kCAFilterNearest
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tapGenerateButton(button)
    }
    
    @IBAction
    private func tapGenerateButton(sender: UIButton) {
        guard let text = textField.text else { return }
        sender.enabled = false
        QRCodeGenerator.generateQRCodeAsynchronously(stringValue: text) { image in
            self.imageView.image = image
            sender.enabled = true
        }
    }

}
