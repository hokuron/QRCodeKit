//
//  CaptureMetadataOutputObjectType.swift
//  QRCodeKit
//
//  Created by hokuron on 2015/11/14.
//  Copyright © 2015年 Takuma Shimizu. All rights reserved.
//

import AVFoundation

protocol CaptureMetadataOutputObjectType: Equatable {
    typealias MetadataObject: AVMetadataObject
    
    var metadataObject: MetadataObject { get }
}

protocol CaptureMetadataQRCodeObjectType: CaptureMetadataOutputObjectType {
    typealias MetadataObject = AVMetadataMachineReadableCodeObject
}

public struct CaptureMetadataQRCodeObject: CaptureMetadataQRCodeObjectType {
    var metadataObject: AVMetadataMachineReadableCodeObject
}

public func == (lhs: CaptureMetadataQRCodeObject, rhs: CaptureMetadataQRCodeObject) -> Bool {
    return lhs.metadataObject.stringValue == rhs.metadataObject.stringValue
}
