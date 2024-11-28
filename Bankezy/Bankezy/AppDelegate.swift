//
//  AppDelegate.swift
//  Bankezy
//
//  Created by Andy on 24/11/2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = GetStartedViewController()
        window?.makeKeyAndVisible()
        return true
    }

}

