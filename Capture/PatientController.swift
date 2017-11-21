//
//  PatientControllerViewController.swift
//  Capture
//
//  Created by Jin on 1/09/16.
//  Copyright © 2016 oDocs Tech. All rights reserved.
//

import UIKit

class PatientController: UIViewController, UITextFieldDelegate {
    
    fileprivate let consultation: Consultation
    
    init(consultation: Consultation) {
        self.consultation = consultation
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let patientNameField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Patient Name"
        return textField
    }()
    
    let patientNoField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Patient Number"
        return textField
    }()
    
    let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Share", for: UIControlState())
        return button
    }()
    
    let finishedButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Next Patient", for: UIControlState())
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.title = "Enter Patient Details"
        
        self.patientNameField.borderStyle = .roundedRect
        self.patientNameField.delegate = self
        self.view.addSubview(self.patientNameField)
        self.patientNameField.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 20).isActive = true
        self.patientNameField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        self.patientNameField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        
        self.patientNoField.borderStyle = .roundedRect
        self.patientNoField.delegate = self
        self.view.addSubview(self.patientNoField)
        self.patientNoField.topAnchor.constraint(equalTo: self.patientNameField.bottomAnchor, constant: 20).isActive = true
        self.patientNoField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        self.patientNoField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20).isActive = true
        
        let numberOfPhotos = self.consultation.assets.filter({ $0.selected }).count
        if numberOfPhotos == 1 {
            self.shareButton.setTitle("Share 1 photo", for: .normal)
        } else {
            self.shareButton.setTitle("Share \(numberOfPhotos) photos", for: .normal)
        }
        
        self.shareButton.addTarget(self, action: #selector(share(_:)), for: .touchUpInside)
        self.view.addSubview(self.shareButton)
        self.shareButton.topAnchor.constraint(equalTo: self.patientNoField.bottomAnchor, constant: 20).isActive = true
        self.shareButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        self.finishedButton.addTarget(self, action: #selector(finished(_:)), for: .touchUpInside)
        self.view.addSubview(self.finishedButton)
        self.finishedButton.topAnchor.constraint(equalTo: self.shareButton.bottomAnchor, constant: 10).isActive = true
        self.finishedButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.consultation.progress = 2
        
        self.patientNameField.text = self.consultation.name
        self.patientNoField.text = self.consultation.patientNo
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.patientNameField.becomeFirstResponder()
    }
    
    func share(_ button: UIButton) {
        var activityItems = self.consultation.assets.filter({ $0.selected }).map { assetFilePath(withFilename: $0.filename) as AnyObject }
        
        let components = [self.consultation.name, self.consultation.patientNo].flatMap { $0 }
        
        if components.count > 0 {
            activityItems.append(components.joined(separator: " - ") as AnyObject)
        }
        
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { (_, success: Bool, _, _) in
            if success {
                self.consultation.isFinished = true
            }
        }
        activityViewController.excludedActivityTypes = [.postToFacebook, .postToTwitter, .postToVimeo, .postToWeibo, .postToFlickr, .postToTencentWeibo, .assignToContact, .addToReadingList, .openInIBooks]
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func finished(_ button: UIButton) {
        // Save photos to albums
        
        self.consultation.isFinished = true
        self.consultation.deleteAssets()
        
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.patientNameField {
            self.patientNoField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText: NSString = textField.text as NSString? ?? ""
        let detailText = textFieldText.replacingCharacters(in: range, with: string)

        if textField == self.patientNameField {
            self.consultation.name = detailText
        } else {
            self.consultation.patientNo = detailText
        }
        
        return true
    }
}
