//
//  VideoSelectionController.swift
//  Capture
//
//  Created by Jin on 6/09/16.
//  Copyright © 2016 oDocs Tech. All rights reserved.
//

import UIKit
import AVFoundation

class VideoSelectionController: UIViewController {
    let videoAsset: Asset
    let consultation: Consultation
    
    var newAssets = [Asset]()
    let imageGenerator: AVAssetImageGenerator
    
    init(videoAsset: Asset, consultation: Consultation) {
        self.videoAsset = videoAsset
        self.consultation = consultation
        
        let asset = AVURLAsset(url: assetFilePath(withFilename: videoAsset.filename), options: .none)

        self.imageGenerator = AVAssetImageGenerator(asset: asset)
        self.imageGenerator.appliesPreferredTrackTransform = true
        self.imageGenerator.requestedTimeToleranceAfter = kCMTimeZero
        self.imageGenerator.requestedTimeToleranceBefore = kCMTimeZero
        
        super.init(nibName: nil, bundle: nil)
        
        self.setupAsset(asset)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let playerView: PlayerView = {
        let playerView = PlayerView()
        playerView.translatesAutoresizingMaskIntoConstraints = false
        return playerView
    }()
    
    let progressSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0.0
        slider.maximumValue = 1.0
        slider.isContinuous = true
        return slider
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cancel", for: .normal)
        return button
    }()
    
    let doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Done", for: .normal)
        return button
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Save Photo", for: .normal)
        return button
    }()

    var saveIndicators = [UIView]()
    func placeSaveIndicator() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .green
        
        self.view.insertSubview(view, belowSubview: self.progressSlider)
        view.widthAnchor.constraint(equalToConstant: 2).isActive = true
        view.heightAnchor.constraint(equalToConstant: 8).isActive = true
        view.centerYAnchor.constraint(equalTo: self.progressSlider.centerYAnchor).isActive = true
        let progressBounds = self.progressSlider.bounds
        let trackRect = self.progressSlider.trackRect(forBounds: progressBounds)
        let thumbRect = self.progressSlider.thumbRect(forBounds: progressBounds, trackRect: trackRect, value: self.progressSlider.value)
        view.centerXAnchor.constraint(equalTo: self.progressSlider.leftAnchor, constant: thumbRect.midX).isActive = true
        
        self.saveIndicators.append(view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.playerView)
        self.playerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.playerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.playerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.playerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true

        self.view.addSubview(self.progressSlider)
        self.progressSlider.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        self.progressSlider.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        self.progressSlider.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20).isActive = true
        
        self.progressSlider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        
        self.view.addSubview(self.saveButton)
        self.saveButton.bottomAnchor.constraint(equalTo: self.progressSlider.topAnchor, constant: -20).isActive = true
        self.saveButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true

        self.saveButton.addTarget(self, action: #selector(saveTapped(_:)), for: .touchUpInside)
        
        self.view.addSubview(self.doneButton)
        self.doneButton.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 10).isActive = true
        self.doneButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true

        self.doneButton.addTarget(self, action: #selector(doneTapped(_:)), for: .touchUpInside)
        
        self.view.addSubview(self.cancelButton)
        self.cancelButton.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 10).isActive = true
        self.cancelButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        
        self.cancelButton.addTarget(self, action: #selector(cancelTapped(_:)), for: .touchUpInside)
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    fileprivate func setupAsset(_ asset: AVAsset) {
        self.playerView.player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
    }
    
    func saveTapped(_ button: UIButton) {
        let time = NSValue(time: self.playerView.player.currentTime())
        self.imageGenerator.generateCGImagesAsynchronously(forTimes: [time]) { (_, cgImage, _, result, _) in
            if let validCgImage = cgImage, result == .succeeded {
                // TODO: use CGImageDestination
                let filename = "\(UUID().uuidString).jpg"
                let fileURL = assetFilePath(withFilename: filename)
                let image = UIImage(cgImage: validCgImage)
                let imageData = UIImagePNGRepresentation(image)
                try? imageData?.write(to: fileURL, options: [])
                
                self.newAssets.append(Asset(type: .photo, filename: filename))
                
                DispatchQueue.main.async {
                    self.placeSaveIndicator()
                    
                    let flashView = UIView(frame: self.view.window!.bounds)
                    flashView.backgroundColor = .white
                    flashView.alpha = 0.8
                    flashView.isUserInteractionEnabled = false
                    self.view.window!.addSubview(flashView)
                    
                    UIView.animate(withDuration: 0.1,
                                   delay: 0,
                                   options: [.allowUserInteraction, .curveEaseIn],
                                   animations: { flashView.alpha = 0.0 },
                                   completion: { (_) in flashView.removeFromSuperview() })
                }
            } else {
                assertionFailure("save failed")
            }
        }
    }
    
    func doneTapped(_ button: UIButton) {
        if let videoIndex = self.consultation.assets.index(of: self.videoAsset) {
            self.consultation.assets.insert(contentsOf: self.newAssets, at: videoIndex + 1)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelTapped(_ button: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sliderChanged(_ slider: UISlider) {
        if let videoLength = self.playerView.player.currentItem?.asset.duration {
            let progress = CMTimeValue((Float(videoLength.value) * slider.value).rounded())
            let seekTime =  CMTime(value: progress, timescale: videoLength.timescale)
            self.seekSmoothlyToTime(newChaseTime: seekTime)
        }
    }
    
    var isSeekInProgress = false
    var chaseTime = kCMTimeZero
    
    func seekSmoothlyToTime(newChaseTime:CMTime)
    {
        if CMTimeCompare(newChaseTime, chaseTime) != 0
        {
            chaseTime = newChaseTime;
            
            if !self.isSeekInProgress
            {
                self.trySeekToChaseTime()
            }
        }
    }
    
    func trySeekToChaseTime()
    {
        if self.playerView.player.currentItem?.status == .unknown
        {
            // wait until item becomes ready (KVO player.currentItem.status)
        }
        else if self.playerView.player.currentItem?.status == .readyToPlay
        {
            self.actuallySeekToTime()
        }
    }
    
    func actuallySeekToTime()
    {
        self.isSeekInProgress = true
        let seekTimeInProgress = chaseTime
        self.playerView.player.seek(to: seekTimeInProgress, toleranceBefore: kCMTimeZero,
                          toleranceAfter: kCMTimeZero, completionHandler:
            { (isFinished:Bool) -> Void in
                
                if CMTimeCompare(seekTimeInProgress, self.chaseTime) == 0
                {
                    self.isSeekInProgress = false
                }
                else
                {
                    self.trySeekToChaseTime()
                }
        })
    }
    
    
    // MARK: - PlayerView
    
    internal class PlayerView: UIView {
        
        var player: AVPlayer {
            get {
                return (self.layer as! AVPlayerLayer).player!
            }
            set {
                if (self.layer as! AVPlayerLayer).player != newValue {
                    (self.layer as! AVPlayerLayer).player = newValue
                }
            }
        }
        
        var playerLayer: AVPlayerLayer {
            get {
                return self.layer as! AVPlayerLayer
            }
        }
        
        var fillMode: String {
            get {
                return (self.layer as! AVPlayerLayer).videoGravity
            }
            set {
                (self.layer as! AVPlayerLayer).videoGravity = newValue
            }
        }
        
        override class var layerClass : AnyClass {
            return AVPlayerLayer.self
        }
        
        // MARK: - object lifecycle
        
        convenience init() {
            self.init(frame: CGRect.zero)
            self.playerLayer.backgroundColor = UIColor.black.cgColor
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.playerLayer.backgroundColor = UIColor.black.cgColor
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
    }
}
