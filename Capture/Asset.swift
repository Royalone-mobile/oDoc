//
//  Asset.swift
//  Capture
//
//  Created by Jin on 1/09/16.
//  Copyright © 2016 oDocs Tech. All rights reserved.
//

import UIKit
import ObjectMapper

func == (left: Asset, right: Asset) -> Bool {
    return left.filename == right.filename
}

struct Asset: Equatable, Mappable {
    enum AssetType: Int {
        case photo
        case video
    }
    
    var type: AssetType = .photo
    var filename: String = ""
    var selected: Bool = true
    
    init(type: AssetType, filename: String) {
        self.type = type
        self.filename = filename
        
        switch type {
        case .photo:
            self.selected = true
        case .video:
            self.selected = false
        }
    }
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        type        <- (map["type"], TransformOf<AssetType, Int>(fromJSON: { AssetType(rawValue: $0!) }, toJSON: { $0?.rawValue }))
        filename    <- map["filename"]
        selected    <- map["selected"]
    }
}
