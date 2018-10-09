//
//  ScanerView.swift
//  MHacks
//
//  Created by Russell Ladd on 9/24/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit
import AVFoundation

protocol ScannerViewDelegate: class {
    
    func scannerView(scannerView: ScannerView, didScanIdentifier identifier: String)
}

final class ScannerView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    
    // MARK: Delegate
    
    weak var delegate: ScannerViewDelegate?
    
    // MARK: Layer
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    // MARK: Capture
    
    let captureSession = AVCaptureSession()
    
    let supportedBarCodes = [AVMetadataObject.ObjectType.qr, AVMetadataObject.ObjectType.pdf417, AVMetadataObject.ObjectType.aztec]
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        videoPreviewLayer.videoGravity = AVLayerVideoGravity(rawValue: convertFromAVLayerVideoGravity(AVLayerVideoGravity.resizeAspectFill))
        
        do {
            
            let captureDevice = AVCaptureDevice.default(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)))
            
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            
            // Initialize the captureSession object.
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            // Detect all the supported bar codes
            captureMetadataOutput.metadataObjectTypes = supportedBarCodes
            
            // Start video capture
            captureSession.startRunning()
			
			videoPreviewLayer.session = captureSession

        } catch {
			// If any error occurs, simply print it out and don't continue any more.
			NotificationCenter.default.post(name: APIManager.FailureNotification, object: error.localizedDescription)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject, supportedBarCodes.contains(metadataObject.type) {
            delegate?.scannerView(scannerView: self, didScanIdentifier: metadataObject.stringValue!)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMetadataObjectObjectType(_ input: AVMetadataObject.ObjectType) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVLayerVideoGravity(_ input: AVLayerVideoGravity) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMediaType(_ input: AVMediaType) -> String {
	return input.rawValue
}
