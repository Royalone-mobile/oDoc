//
//  IntroController.swift
//  Capture
//
//  Created by Jin on 1/09/16.
//  Copyright © 2016 oDocs Tech. All rights reserved.
//

import UIKit

class IntroController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    enum State {
        case intro
        case camera
        case images
    }
    
    class EmailPage: UIView {
        let logoImageView: UIImageView = {
            let imageView = UIImageView(image: #imageLiteral(resourceName: "logo"))
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
        
        let titleLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "oDocs Eye Care"
            label.textColor = .white
            label.textAlignment = .center
            return label
        }()
        
        let emailField: UITextField = {
            let field = UITextField()
            field.translatesAutoresizingMaskIntoConstraints = false
            field.attributedPlaceholder = NSAttributedString(string: "Email Address",
                                                             attributes: [NSForegroundColorAttributeName: UIColor.white])
            field.textAlignment = .center
            field.tintColor = .white
            field.textColor = .white
            field.keyboardType = .emailAddress
            field.keyboardAppearance = .dark
            field.autocorrectionType = .no
            field.autocapitalizationType = .none
            field.spellCheckingType = .no
            field.returnKeyType = .done
            return field
        }()
        
        let doneButton: UIButton = {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Done", for: UIControlState())
            return button
        }()
        
        init() {
            super.init(frame: CGRect.zero)
            
            self.translatesAutoresizingMaskIntoConstraints = false
            
            self.addSubview(self.emailField)
            self.emailField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
            self.emailField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
            self.emailField.bottomAnchor.constraint(equalTo: self.centerYAnchor, constant: -10).isActive = true
            
            self.addSubview(self.doneButton)
            self.doneButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
            self.doneButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
            self.doneButton.topAnchor.constraint(equalTo: self.centerYAnchor, constant: 10).isActive = true
            
            self.addSubview(self.titleLabel)
            self.titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
            self.titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
            self.titleLabel.bottomAnchor.constraint(equalTo: self.emailField.topAnchor, constant: -60).isActive = true
            
            self.addSubview(self.logoImageView)
            self.logoImageView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 20).isActive = true
            self.logoImageView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -20).isActive = true
            self.logoImageView.bottomAnchor.constraint(equalTo: self.titleLabel.topAnchor, constant: -60).isActive = true
            self.logoImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class TextPage: UIView {
        let textLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = .white
            label.textAlignment = .center
            label.numberOfLines = 0
            return label
        }()
        
        init(_ text: NSAttributedString) {
            super.init(frame: CGRect.zero)
            
            self.translatesAutoresizingMaskIntoConstraints = false
            
            self.textLabel.attributedText = text
            
            self.addSubview(self.textLabel)
            self.textLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 40).isActive = true
            self.textLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -40).isActive = true
            self.textLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            self.textLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class OverlayPage: UIView {
        let doneButton: UIButton = {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Done", for: UIControlState())
            return button
        }()
        
        init() {
            super.init(frame: CGRect.zero)
            
            self.translatesAutoresizingMaskIntoConstraints = false
            
            self.addSubview(self.doneButton)
            self.doneButton.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            self.doneButton.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            self.doneButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    var state: State
    var pages: [UIView]
    
    init(state: State) {
        self.state = state
        
        self.pages = [UIView]()

        super.init(nibName: nil, bundle: nil)
        
        if state == .intro {
            self.pages.append(EmailPage())
        }
        
        if state == .camera || state == .intro {
            self.pages.append(TextPage(NSAttributedString(string: "Welcome to the oDocs Eye Care App.\n\nThe following is a short tutorial to help you capture images with our equipment.")))
            self.pages.append(TextPage(NSAttributedString(string: "Please remember that this app is to be used in conjunction with the oDocs viso family. For optimal performance, please attach and adapter to your phone.")))
            self.pages.append(TextPage(NSAttributedString(string: "The app controls are as follows:\n\nZoom Swipe up and down\nLight Swipe left and right\nPhoto Tap screen\nVideo Tap and hold screen")))
        } else {
            self.pages.append(TextPage(NSAttributedString(string: "Great! You’ve taken your first images.\nThe following tutorial will quickly explain how to save your captured images.")))
            self.pages.append(TextPage(NSAttributedString(string: "Images to be saved are indicated by a green square on the bottom right corner. You can deselect images by simply tapping them.")))
            self.pages.append(TextPage(NSAttributedString(string: "Tap on your video to enter an image selection screen. You can scrub through your recording in the bottom of the screen. Select the appropriate image screens then tap ‘Save Photo’ to add this to your image collection. Once you are finished click ‘Done’ in the top right corner.")))
            self.pages.append(TextPage(NSAttributedString(string: "Tap ‘Next’ on the top right to enter the patient detail screen. Fill the appropriate fields and then send your images by tapping on the ‘Share’ button.")))
        }
        
        self.pages.append(OverlayPage())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let blurView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isPagingEnabled = true
        return view
    }()
    
    let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .clear
        
        self.view.addSubview(self.blurView)
        self.blurView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.blurView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.blurView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.blurView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        self.view.addSubview(self.pageControl)
        self.pageControl.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20).isActive = true
        self.pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.delegate = self
        self.view.addSubview(self.scrollView)
        self.scrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        if self.state == .intro {
            self.scrollView.isScrollEnabled = false
        }

        var lastPage: UIView?
        for (index, page) in self.pages.enumerated() {
            if let emailPage = page as? EmailPage , index == 0 && self.state == .intro {
                emailPage.doneButton.addTarget(self, action: #selector(didTapDoneOnEmailPage(_:)), for: .touchUpInside)
                emailPage.emailField.delegate = self
            } else if let overlayPage = page as? OverlayPage {
                overlayPage.doneButton.addTarget(self, action: #selector(didTapDoneOnOverlayPage(_:)), for: .touchUpInside)
            }
            
            self.scrollView.addSubview(page)
            page.topAnchor.constraint(equalTo: self.scrollView.topAnchor).isActive = true
            page.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor).isActive = true
            page.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor).isActive = true

            if let validatedLastPage = lastPage {
                page.leftAnchor.constraint(equalTo: validatedLastPage.rightAnchor).isActive = true
            } else {
                page.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor).isActive = true
            }
            lastPage = page
        }
        
        self.pageControl.numberOfPages = self.pages.count
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        var size = self.scrollView.frame.size
        size.width *= CGFloat(self.pages.count)
        self.scrollView.contentSize = size
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = Int(floor(scrollView.contentOffset.x/scrollView.frame.width))
        self.pageControl.currentPage = index
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.completeEmailPage()
        textField.resignFirstResponder()
        return true
    }
    
    func didTapDoneOnEmailPage(_ button: UIButton) {
        self.completeEmailPage()
        button.superview?.endEditing(true)
    }
    
    func completeEmailPage() {
        let size = self.scrollView.frame.size
        UIView.animate(withDuration: 0.3,
                       animations: { self.scrollView.contentOffset = CGPoint(x: size.width, y: 0) },
                       completion: { (_) in self.scrollView.contentInset = UIEdgeInsetsMake(0, -size.width, 0, 0); self.scrollView.isScrollEnabled = true })
    }
    
    func didTapDoneOnOverlayPage(_ button: UIButton) {
        self.finish()
    }
    
    func finish() {
        if self.state == .intro {
            UserDefaults.standard.set(true, forKey: "hasSeenIntro")
        } else if self.state == .images {
            UserDefaults.standard.set(true, forKey: "hasSeenImagesIntro")
        }
        self.dismiss(animated: true, completion: nil)
    }
}
