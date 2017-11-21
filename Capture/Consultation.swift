//
//  Consultation.swift
//  Capture
//
//  Created by Jin on 31/08/16.
//  Copyright © 2016 oDocs Tech. All rights reserved.
//

import UIKit
import ObjectMapper

class Consultation: Mappable {
    var name: String? {
        didSet { self.save() }
    }
    var patientNo: String? {
        didSet { self.save() }
    }
    var dateStarted: Date? {
        didSet { self.save() }
    }
    var assets = [Asset]() {
        didSet { self.save() }
    }
    var isFinished = false {
        didSet { self.save() }
    }
    var progress: Int = 0 {
        didSet { self.save() }
    }

    var isSaving = false
    
    func deleteAssets() {
        for asset in assets {
            if (try? FileManager.default.removeItem(at: assetFilePath(withFilename: asset.filename))) == nil {
                print("Delete failed for asset")
            }
        }
    }
    
    init() {
        
    }
    
    func save() {
        let keychain = KeychainSwift()
        
        guard self.isSaving == false else {
            return
        }
        
        self.isSaving = true
        if let json = toJSONString() {
            keychain.set(json, forKey: "currentConsultation")
        }
        self.isSaving = false
    }
    
    static func fetch() -> Consultation? {
        let keychain = KeychainSwift()
        if let json = keychain.get("currentConsultation") {
            return Consultation(JSONString: json)
        } else {
            return nil
        }
    }
    
    // MARK: Mappable
    
    required init?(map: Map) {
        if map.JSON["dateStarted"] == nil, map.JSON["isFinished"] as! Bool == true {
            return nil
        }
    }
    
    func mapping(map: Map) {
        if map.mappingType == .toJSON {
            
        }
        name        <- map["celsius"]
        patientNo   <- map["fahrenheit"]
        dateStarted <- (map["dateStarted"], DateTransform())
        progress    <- map["progress"]
        assets      <- map["assets"]
        isFinished  <- map["isFinished"]
    }
}
