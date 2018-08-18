//
//  AppDelegate.swift
//  getFilter
//
//  Created by Farzad Nazifi on 6/12/18.
//  Copyright © 2018 Farzad Nazifi. All rights reserved.
//

import UIKit
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RootNavigationViewController()
        window?.makeKeyAndVisible()
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: true]
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "3401f037-aad4-4c24-889c-a56e752dec20",
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.none;
        
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NSLog("ZAPA")
        do {
            let gf = try GetFilter(readOnly: false)
            gf.sync().done { () in
                completionHandler(.newData)
                }.catch { (err) in }
        } catch {
            completionHandler(.failed)
        }
    }
}
