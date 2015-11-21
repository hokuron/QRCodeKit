//
//  QRCodeGenerator.swift
//  iBeaCam
//
//  Created by hokuron on 3/23/15.
//  Copyright (c) 2015 Takuma Shimizu. All rights reserved.
//

import UIKit

public enum QRCodeErrorCorrectionLevel: String {
    case L = "L"
    case M = "M"
    case Q = "Q"
    case H = "H"
}

public final class QRCodeGenerator: NSObject {
   
    public private(set) var image: UIImage?
    
    
    private override init() {
        fatalError("init() has not been implemented")
    }
    
    /// Generate synchronously
    public init(stringValue: String, correctionLevel: QRCodeErrorCorrectionLevel = .H) {
        super.init()
        self.image = generateWithValue(stringValue, correctionLevel: correctionLevel)
    }
    
    /// Generate asynchronously
    public class func generateQRCodeAsynchronously(stringValue stringValue: String, correctionLevel: QRCodeErrorCorrectionLevel = .H, completion: (UIImage?) -> Void) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) {
            let image = QRCodeGenerator(stringValue: stringValue, correctionLevel: correctionLevel).image
            dispatch_async(dispatch_get_main_queue()) {
                completion(image)
            }
        }
    }
    
    private func generateWithValue(value: String, correctionLevel: QRCodeErrorCorrectionLevel) -> UIImage? {
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { fatalError("CIQRCodeGenerator is not supported.") }
        filter.setDefaults()
        filter.setValue(value.dataUsingEncoding(NSUTF8StringEncoding), forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        let cgImage = CIContext(options: nil).createCGImage(filter.outputImage!, fromRect: filter.outputImage!.extent)
        let image = UIImage(CGImage: cgImage, scale: 0, orientation: .Up)
        return image
    }
    
}
