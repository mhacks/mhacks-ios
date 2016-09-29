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
    
    let supportedBarCodes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeAztecCode]
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        do {
            
            let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
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
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject, supportedBarCodes.contains(metadataObject.type) {
            delegate?.scannerView(scannerView: self, didScanIdentifier: metadataObject.stringValue)
        }
    }
}
