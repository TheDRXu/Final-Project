//
//  AppDelegate.swift
//  DemoFire
//
//  Created by Dwayne Reinaldy on 5/11/22.
//

import UIKit
import Firebase
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        return true
    }
}
