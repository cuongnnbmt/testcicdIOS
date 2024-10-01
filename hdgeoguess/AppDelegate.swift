//
//  AppDelegate.swift
//  hdgeoguess
//
//  Created by macOS on 20/02/2023.
//

import UIKit
import GoogleMaps
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()

        GMSServices.provideAPIKey("AIzaSyDYcWVk163vcF_S6Zz3zB0hqlwGOIaiUDg")

        InAppMNG.completeTransactions { (_) in
            
        }

        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = HDIntroViewController()
        window?.makeKeyAndVisible()

        return true
    }
    
}

