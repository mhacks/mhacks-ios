//
//  AppDelegate.swift
//  MHacks
//
//  Created by Russell Ladd on 9/24/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: Window
    
    var window: UIWindow?
    
    // MARK: Launch
    
    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        Parse.setApplicationId(Keys.sharedKeys.parseApplicationID, clientKey: Keys.sharedKeys.parseClientKey)
        
        return true
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        application.registerForRemoteNotifications()
        
        let settings = UIUserNotificationSettings(forTypes: .Sound | .Alert, categories: nil)
        application.registerUserNotificationSettings(settings)
        
        return true
    }
    
    // MARK: Life cycle
    
    func applicationDidBecomeActive(application: UIApplication) {
        
        application.cancelAllLocalNotifications()
    }
    
    // MARK: Remote notifications
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveEventually()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        println("Remote notification!\n\(userInfo)")
        
        // Maybe tell a view controller to fetch and then call this
        completionHandler(.NewData)
    }
    
    // MARK: User notifications
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
        // Gets called redundantly every time the app launches
    }
}

