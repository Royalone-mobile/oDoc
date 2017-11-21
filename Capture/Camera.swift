//
//  Camera.swift
//  Capture
//
//  Created by Jin on 30/08/16.
//  Copyright © 2016 oDocs Tech. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class Camera: NSObject, AVCaptureFileOutputRecordingDelegate {
    fileprivate let session = AVCaptureSession()
    fileprivate let stillOutput = AVCaptureStillImageOutput()
    fileprivate let videoOutput = AVCaptureMovieFileOutput()
    fileprivate let connection = AVCaptureConnection()
    fileprivate let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)!
    let previewLayer = AVCaptureVideoPreviewLayer()
    
    override init() {
        self.session.sessionPreset = AVCaptureSessionPresetHigh
        
        let input = try! AVCaptureDeviceInput(device: self.device )
        guard self.session.canAddInput(input) else { return }
        self.session.addInput(input)

        self.stillOutput.outputSettings = [ AVVideoCodecKey: AVVideoCodecJPEG ]
        guard self.session.canAddOutput(self.stillOutput) else { return }
        self.session.addOutput(self.stillOutput)

        guard self.session.canAddOutput(self.videoOutput) else { return }
        self.session.addOutput(self.videoOutput)
        
        self.previewLayer.session = self.session
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.previewLayer.cornerRadius = 8.0
    }
    
    func start() {
        if self.session.inputs.count > 0 {
            self.session.startRunning()
        }
    }
    
    func startRecording(_ url: URL) {
        self.videoOutput.startRecording(toOutputFileURL: url, recordingDelegate: self)
    }
    
    func stopRecording() {
        self.videoOutput.stopRecording()
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
//        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
//            PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(outputFileURL)
//        }) { saved, error in
//            if saved {
//                print("YAY")
//            }
//        }
    }
    
    func captureStill(_ url: URL, completion: @escaping (_ success: Bool) -> Void) {
        let connection = self.stillOutput.connection(withMediaType: AVMediaTypeVideo)
        connection?.videoOrientation = .portrait
        self.stillOutput.captureStillImageAsynchronously(from: connection) { (sampleBuffer, error) in
            guard sampleBuffer != nil && error == nil else { completion(false); return }
            
            completion(true)
            let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
            try? imageData?.write(to: url, options: [])
        }
    }
    
    enum TorchIntensity {
        case off
        case low
        case medium
        case high
        
        func floatValue() -> Float {
            switch self {
            case .off:
                return 0.0
            case .low:
                return 0.3
            case .medium:
                return 0.6
            case .high:
                return AVCaptureMaxAvailableTorchLevel
            }
        }
        
        func increment() -> TorchIntensity {
            switch self {
            case .off:
                return .low
            case .low:
                return .medium
            case .medium, .high:
                return .high
            }
        }
        
        func decrement() -> TorchIntensity {
            switch self {
            case .off, .low:
                return .off
            case .medium:
                return .low
            case .high:
                return .medium
            }
        }

        var stringValue: String {
            switch self {
            case .off:
                return "Off"
            case .low:
                return "Low"
            case .medium:
                return "Medium"
            case .high:
                return "High"
            }

        }
    }
    
    var torchIntensity: TorchIntensity = .off {
        didSet {
            if self.device.hasTorch {
                _ = try? self.device.lockForConfiguration()
                
                if self.torchIntensity == .off {
                    self.device.torchMode = .off
                } else {
                    _ = try? self.device.setTorchModeOnWithLevel(self.torchIntensity.floatValue())
                }
                
                self.device.unlockForConfiguration()
            }
        }
    }
    
    var zoomLevel: CGFloat = 1.0 {
        didSet {
            var error: NSError!
            do{
                try device.lockForConfiguration()
                defer {device.unlockForConfiguration()}
                
                self.device.videoZoomFactor = max(1.0, min(self.zoomLevel, self.device.activeFormat.videoMaxZoomFactor));
                self.zoomLevel = self.device.videoZoomFactor
            }
            catch error as NSError {
                NSLog("Unable to set videoZoom: %@", error.localizedDescription);
            }
            catch _{
                
            }
        }
    }
    
    var zoomLevelPercent: String {
        get {
            return "\(Int(round(self.zoomLevel)))x"
        }
    }
    
    var isInverted: Bool = false {
        didSet {
            if self.isInverted {
                self.previewLayer.setAffineTransform(CGAffineTransform(scaleX: 1.0, y: -1.0))
            } else {
                self.previewLayer.setAffineTransform(.identity)
            }
        }
    }
}
