//
//  AppDelegate.swift
//  Capture
//
//  Created by Jin on 30/08/16.
//  Copyright © 2016 oDocs Tech. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
                
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = UINavigationController(rootViewController: CameraController())
        self.window?.makeKeyAndVisible()
        
        Fabric.with([Crashlytics.self])
        
        return true
    }

}

