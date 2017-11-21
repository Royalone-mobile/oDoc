//
//  ViewController.swift
//  Capture
//
//  Created by Jin on 30/08/16.
//  Copyright © 2016 oDocs Tech. All rights reserved.
//

import UIKit

class CameraController: UIViewController {
    let camera = Camera()
    let cameraView = UIView()
    let nextButton = UIButton()
    let flipButton = UIButton()
    let helpButton = UIButton(type: UIButtonType.infoLight)
    let recordingIndicator = UIView()
    let torchLabel = UILabel()
    let torchValueLabel = UILabel()
    let zoomLabel = UILabel()
    let zoomValueLabel = UILabel()
    
    var consultation: Consultation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        self.view.addGestureRecognizer(tapGR)
        
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        self.view.addGestureRecognizer(longPressGR)
        
        tapGR.require(toFail: longPressGR)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft(_:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight(_:)))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let verticalPan = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        verticalPan.require(toFail: swipeLeft)
        verticalPan.require(toFail: swipeRight)
        verticalPan.require(toFail: longPressGR)
        self.view.addGestureRecognizer(verticalPan)
        
        self.camera.start()
        
        self.cameraView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.cameraView)
        self.cameraView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.cameraView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.cameraView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.cameraView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        self.nextButton.setTitle("Next", for: UIControlState())
        self.nextButton.addTarget(self, action: #selector(goToImages(_:)), for: .touchUpInside)
        self.nextButton.translatesAutoresizingMaskIntoConstraints = false
        self.nextButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.view.addSubview(self.nextButton)
        self.nextButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.nextButton.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true

        self.flipButton.setTitle("Flip", for: UIControlState())
        self.flipButton.addTarget(self, action: #selector(flipVertical(_:)), for: .touchUpInside)
        self.flipButton.translatesAutoresizingMaskIntoConstraints = false
        self.flipButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.view.addSubview(self.flipButton)
        self.flipButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.flipButton.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        self.recordingIndicator.backgroundColor = .red
        self.recordingIndicator.frame = CGRect(origin: .zero, size: CGSize(width: 40, height: 40))
        self.recordingIndicator.layer.cornerRadius = 20
        self.recordingIndicator.layer.masksToBounds = true
        
        for label in [torchLabel, torchValueLabel, zoomLabel, zoomValueLabel] {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = .white
        }
        
        self.torchLabel.text = "Torch"
        self.view.addSubview(self.torchLabel)
        self.torchLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        self.torchLabel.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 20).isActive = true
        self.torchLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10).isActive = true
        
        self.torchValueLabel.text = Camera.TorchIntensity.off.stringValue
        self.view.addSubview(self.torchValueLabel)
        self.torchValueLabel.topAnchor.constraint(equalTo: self.torchLabel.bottomAnchor).isActive = true
        self.torchValueLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10).isActive = true
        
        self.zoomLabel.text = "Zoom"
        self.view.addSubview(self.zoomLabel)
        self.zoomLabel.setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .horizontal)
        self.zoomLabel.topAnchor.constraint(equalTo: self.torchValueLabel.bottomAnchor, constant: 20).isActive = true
        self.zoomLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10).isActive = true
        
        self.zoomValueLabel.text = "1x"
        self.view.addSubview(self.zoomValueLabel)
        self.zoomValueLabel.topAnchor.constraint(equalTo: self.zoomLabel.bottomAnchor).isActive = true
        self.zoomValueLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10).isActive = true
        
        self.helpButton.tintColor = .white
        self.helpButton.addTarget(self, action: #selector(presentTutorial(_:)), for: .touchUpInside)
        self.helpButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.helpButton)
        self.helpButton.topAnchor.constraint(equalTo: self.zoomValueLabel.bottomAnchor, constant: 20).isActive = true
        self.helpButton.leftAnchor.constraint(equalTo: self.torchLabel.leftAnchor).isActive = true
        self.helpButton.rightAnchor.constraint(greaterThanOrEqualTo: self.torchLabel.rightAnchor).isActive = true
        self.helpButton.rightAnchor.constraint(greaterThanOrEqualTo: self.zoomLabel.rightAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.standard.bool(forKey: "hasSeenIntro") == false {
            let introController = IntroController(state: .intro)
            introController.modalPresentationStyle = .overCurrentContext
            self.present(introController, animated: false, completion: nil)
        }
        
        self.camera.previewLayer.frame = self.view.bounds
        self.cameraView.layer.addSublayer(self.camera.previewLayer)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let consultation = self.consultation {
            consultation.progress = 0
            
            if consultation.isFinished {
                self.consultation = nil
            }
        }
        
        guard self.consultation == nil else {
            return
        }
        
        guard let savedConsultation = Consultation.fetch() else {
            self.consultation = Consultation()
            return
        }
        
        let alert = UIAlertController(title: "Resume Consultation?",
                                      message: "It looks like you closed the app without exporting your photos. Would you like to resume this consultation?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Resume", style: .default, handler: { _ in
            self.consultation = savedConsultation
            
            guard savedConsultation.progress > 0 else {
                return
            }
            
            var controllers = self.navigationController!.viewControllers
            
            controllers.append(ImagesController(consultation: savedConsultation))

            if savedConsultation.progress > 1 {
                controllers.append(PatientController(consultation: savedConsultation))
            }
            
            self.navigationController?.setViewControllers(controllers, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { _ in
            savedConsultation.deleteAssets()
            self.consultation = Consultation()
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    func didTap(_ tapGR: UITapGestureRecognizer) {
        let filename = "\(UUID().uuidString).jpg"
        let fileURL = assetFilePath(withFilename: filename)
        self.camera.captureStill(fileURL) { (success) in
            if (success) {
                self.consultation?.assets.append(Asset(type: .photo, filename: filename))
                
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
        }
    }
    
    func didLongPress(_ longPressGR: UILongPressGestureRecognizer) {
        let locationInView = longPressGR.location(in: self.view)
        switch longPressGR.state {
        case .began:
            let filename = "\(UUID().uuidString).mov"
            let fileURL = assetFilePath(withFilename: filename)
            self.camera.startRecording(fileURL)
            self.consultation?.assets.append(Asset(type: .video, filename: filename))
            
            self.view.addSubview(self.recordingIndicator)
            self.recordingIndicator.center = locationInView.applying(CGAffineTransform(translationX: 0, y: -60))
            
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           options: [.autoreverse, .repeat],
                           animations: { self.recordingIndicator.alpha = 0.5 },
                           completion: nil)
        case .changed:
            self.recordingIndicator.center = locationInView.applying(CGAffineTransform(translationX: 0, y: -60))
        case .ended:
            self.camera.stopRecording()
            self.recordingIndicator.removeFromSuperview()
            self.recordingIndicator.alpha = 1.0
        default:
            break
        }
    }
    
    func didSwipeLeft(_ swipeLeftGR: UISwipeGestureRecognizer) {
        let torchIntensity = self.camera.torchIntensity;
        self.camera.torchIntensity = torchIntensity.decrement()
        
        self.torchValueLabel.text = self.camera.torchIntensity.stringValue
    }
    
    func didSwipeRight(_ swipeRightGR: UISwipeGestureRecognizer) {
        let torchIntensity = self.camera.torchIntensity;
        self.camera.torchIntensity = torchIntensity.increment()
        
        self.torchValueLabel.text = self.camera.torchIntensity.stringValue
    }
    
    func flipVertical(_ button: UIButton) {
        self.camera.isInverted = !self.camera.isInverted
    }
    
    var startingZoomLevel: CGFloat = 1.0
    func didPan(_ panGR: UIPanGestureRecognizer) {
        let translation = panGR.translation(in: self.view)
        switch panGR.state {
        case .began:
            self.startingZoomLevel = self.camera.zoomLevel
        case .changed:
            self.camera.zoomLevel = self.startingZoomLevel + 5 - 5 * exp(translation.y/self.view.frame.height)
            
            self.zoomValueLabel.text = self.camera.zoomLevelPercent
        default:
            break
        }
    }
    
    func goToImages(_ button: UIButton) {
        let imagesController = ImagesController(consultation: self.consultation!)
        self.navigationController?.pushViewController(imagesController, animated: true)
    }
    
    func presentTutorial(_ button: UIButton) {
        let introController = IntroController(state: .camera)
        introController.modalPresentationStyle = .overCurrentContext
        self.present(introController, animated: true, completion: nil)
    }
}

