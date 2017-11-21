//
//  DirectoryHelpers.swift
//  Capture
//
//  Created by Jin Budelmann on 13/10/16.
//  Copyright © 2016 oDocs Tech. All rights reserved.
//

import Foundation

func assetDirectory() -> URL {
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let documentsDirURL = URL(fileURLWithPath: path, isDirectory: true)
    
    let assetDirURL = documentsDirURL.appendingPathComponent("assets", isDirectory: true)
    
    do {
        try FileManager.default.createDirectory(at: assetDirURL, withIntermediateDirectories: true, attributes: nil)
    } catch {
        print(error)
    }
    
    return assetDirURL
}


func assetFilePath(withFilename filename: String) -> URL {
    return assetDirectory().appendingPathComponent(filename)
}
