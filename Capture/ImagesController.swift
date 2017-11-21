//
//  ImagesController.swift
//  Capture
//
//  Created by Jin on 31/08/16.
//  Copyright © 2016 oDocs Tech. All rights reserved.
//

import UIKit
import AVFoundation

class ImagesController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    class ImageCell: UICollectionViewCell {
        static let identifier = "imageCell"
        let imageView = UIImageView()
        let tickView = UIImageView()
        let videoView = UIImageView()

        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.imageView.clipsToBounds = true
            self.imageView.contentMode = .scaleAspectFill
            self.imageView.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(self.imageView)
            self.imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
            self.imageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
            self.imageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
            self.imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
            
            self.tickView.translatesAutoresizingMaskIntoConstraints = false
            self.tickView.image = #imageLiteral(resourceName: "tick-stroke")
            self.contentView.addSubview(self.tickView)
            self.tickView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
            self.tickView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
            
            self.videoView.image = #imageLiteral(resourceName: "movie").withRenderingMode(.alwaysTemplate)
            self.videoView.tintColor = .white
            self.videoView.translatesAutoresizingMaskIntoConstraints = false
            self.videoView.isHidden = true
            self.contentView.addSubview(self.videoView)
            self.videoView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
            self.videoView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override var isSelected: Bool {
            willSet {
                self.tickView.image = newValue ? #imageLiteral(resourceName: "tick-solid") : #imageLiteral(resourceName: "tick-stroke")
            }
        }
        
        var isMovie: Bool = false {
            willSet {
                self.videoView.isHidden = !newValue
                self.tickView.isHidden = newValue
            }
        }
    }
    
    fileprivate let consultation: Consultation
    
    init(consultation: Consultation) {
        self.consultation = consultation
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: ColumnBasedCollectionLayout())
    
    var collectionViewLayout: ColumnBasedCollectionLayout {
        get {
            return self.collectionView.collectionViewLayout as! ColumnBasedCollectionLayout
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Choose Images"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(next(_:)))
        
        self.collectionViewLayout.minimumLineSpacing = 20
        self.collectionViewLayout.minimumInteritemSpacing = 20
        self.collectionViewLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
        
        self.collectionView.backgroundColor = .white
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        
        self.collectionView.allowsMultipleSelection = true
        self.view.addSubview(self.collectionView)
        self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        
        self.collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserDefaults.standard.bool(forKey: "hasSeenImagesIntro") == false {
            let introController = IntroController(state: .images)
            introController.modalPresentationStyle = .overCurrentContext
            self.present(introController, animated: animated, completion: nil)
        }
        
        self.collectionView.reloadData()
        
        self.consultation.progress = 1
        
        for (i, asset) in self.consultation.assets.enumerated() {
            if asset.selected {
                let indexPath = IndexPath(item: i, section: 0)
                self.collectionView.selectItem(at: indexPath,
                                               animated: false,
                                               scrollPosition: UICollectionViewScrollPosition())
            }
        }
    }
    
    func next(_ item: UIBarButtonItem) {
        self.navigationController?.pushViewController(PatientController(consultation: self.consultation), animated: true)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.consultation.assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
        
        let asset = self.consultation.assets[indexPath.row]
        if asset.type == .photo {
            let filePath = assetFilePath(withFilename: asset.filename).path
            let image = UIImage(contentsOfFile: filePath)
            imageCell.imageView.image = image
            imageCell.isMovie = false
        } else {
            do {
                let asset = AVURLAsset(url: assetFilePath(withFilename: asset.filename) as URL, options: nil)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
                let image = UIImage(cgImage: cgImage)
                imageCell.imageView.image = image
            } catch let error as NSError {
                print("Error generating thumbnail: \(error)")
            }
            imageCell.isMovie = true
        }
        
        return imageCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var asset = self.consultation.assets[indexPath.row]
        if (asset.type == .video) {
            let videoController = VideoSelectionController(videoAsset: asset, consultation: self.consultation)
            self.navigationController?.present(videoController, animated: true, completion: nil)
        } else {
            asset.selected = true
            self.consultation.assets[indexPath.row] = asset
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        self.consultation.assets[(indexPath as NSIndexPath).row].selected = false
    }
}
