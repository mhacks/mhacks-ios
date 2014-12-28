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
    
    // MARK: View controllers
    
    var tabBarController: UITabBarController!
    
    var scheduleNavigationController: UINavigationController!
    var scheduleViewController: ScheduleCalendarViewController!
    
    // MARK: Launch
    
    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        Parse.setApplicationId(Keys.sharedKeys.parseApplicationID, clientKey: Keys.sharedKeys.parseClientKey)
        
        return true
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        // View controllers
        
        tabBarController = window!.rootViewController as UITabBarController
        
        scheduleNavigationController = tabBarController.viewControllers![0] as UINavigationController
        scheduleViewController = scheduleNavigationController.viewControllers[0] as ScheduleCalendarViewController
        
        // Remote notifications
        
        application.registerForRemoteNotifications()
        
        // User notifications
        
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
        println("State: \(application.applicationState.rawValue)")
        
        if let message = userInfo["aps"]?["alert"] as? String {
            
            switch application.applicationState {
                
            case .Active:
                
                var actions: [UIAlertAction] = []
                
                if let eventID = userInfo["eventID"] as? String {
                    
                    let actionTitle = NSLocalizedString("View", comment: "Alert action")
                    
                    let action = UIAlertAction(title: actionTitle, style: .Default, handler: { action in
                        self.showDetailsForEventWithID(eventID)
                    })
                    
                    actions += [action]
                }
                
                showAlertControllerWithMessage(message, actions: actions)
                
            default:
                
                if let eventID = userInfo["eventID"] as? String {
                    showDetailsForEventWithID(eventID)
                }
            }
        }
        
        completionHandler(.NewData)
    }
    
    func showAlertControllerWithMessage(message: String, actions: [UIAlertAction]) {
        
        let title = NSLocalizedString("Alert", comment: "Alert title")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        
        let dismissActionTitle = NSLocalizedString("Dismiss", comment: "Notification alert dismiss action title")
        
        alertController.addAction(UIAlertAction(title: dismissActionTitle, style: .Cancel, handler: { action in
            // Do nothing
        }))
        
        tabBarController.showViewController(alertController, sender: nil)
        
        //tabBarController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showDetailsForEventWithID(ID: String) {
        
        tabBarController.selectedIndex = 0
        scheduleNavigationController.popToRootViewControllerAnimated(false)
        scheduleViewController.showDetailsForEventWithID(ID)
    }
    
    // MARK: User notifications
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
        // Gets called redundantly every time the app launches
    }
}

