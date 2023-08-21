//
//  AppDelegate.swift
//  Sample
//
//  Created by Eugene Naloiko on 19.12.2022.
//  Copyright (c) 2022 by imito AG, Zurich, Switzerland
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        /*
         Set the custom appearance of Navigation Bar. To replace the system blue option. Use your branding navigation bar color.
         For sample purposes on restart of the app - the .primaryButtonColor is applied.
         */
        switch UserDefaults.standard.integer(forKey: SettingKey.primaryButtonColor.rawValue) {
        case 1:
            UINavigationBar.appearance().tintColor = .blue
        case 2:
            UINavigationBar.appearance().tintColor = .green
        default:
            UINavigationBar.appearance().tintColor = UIColor(red: 226/255.0, green: 53/255.0, blue: 42/255.0, alpha: 1)
        }
        
        return true
    }
}

