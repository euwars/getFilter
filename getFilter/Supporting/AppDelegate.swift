//
//  AppDelegate.swift
//  getFilter
//
//  Created by Farzad Nazifi on 6/12/18.
//  Copyright © 2018 Farzad Nazifi. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RootNavigationViewController()
        window?.makeKeyAndVisible()
        return true
    }
}
