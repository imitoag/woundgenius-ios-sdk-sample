//
//  AppDelegate.swift
//  Sample
//
//  Created by Eugene Naloiko on 19.12.2022.
//  Copyright (c) 2022 by imito AG, Zurich, Switzerland
//

import UIKit

#if SAMPLE3D
import netfox
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    /// Holds the currently allowed mask, defaulting to all but upside down.
    static var orientationLock: UIInterfaceOrientationMask = {
        if UIDevice.current.isPad {
            return .all
        } else {
            return .portrait
        }
    }()

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

        NotificationCenter.default.addObserver(self, selector: #selector(portraitOnlyWoundGenius), name: Notification.Name("PortraitOnlyWoundGenius"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(allOrientationWoundGenius), name: Notification.Name("AllOrientationWoundGenius"), object: nil)

        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

extension AppDelegate {
    @objc func portraitOnlyWoundGenius() {
        AppDelegate.orientationLock = .portrait
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
    
    @objc func allOrientationWoundGenius() {
        // allow all except upside-down
        AppDelegate.orientationLock = .all
        UIDevice.current.setValue(UIInterfaceOrientation.unknown.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
}
