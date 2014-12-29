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
    
    enum Tab: Int {
        case Schedule = 0
        case Countdown = 1
        case Announcements = 2
        case Sponsors = 3
        case Maps = 4
    }
    
    var tabBarController: UITabBarController!
    
    var scheduleNavigationController: UINavigationController!
    var scheduleViewController: ScheduleCalendarViewController!
    
    var announcementsNavigationController: UINavigationController!
    var announcementsViewController: AnnouncementsViewController!
    
    // MARK: Launch
    
    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        Parse.setApplicationId(Keys.sharedKeys.parseApplicationID, clientKey: Keys.sharedKeys.parseClientKey)
        
        return true
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        // View controllers
        
        tabBarController = window!.rootViewController as UITabBarController
        
        scheduleNavigationController = tabBarController.viewControllers![Tab.Schedule.rawValue] as UINavigationController
        scheduleViewController = scheduleNavigationController.viewControllers.first as ScheduleCalendarViewController
        
        announcementsNavigationController = tabBarController.viewControllers![Tab.Announcements.rawValue] as UINavigationController
        announcementsViewController = announcementsNavigationController.viewControllers.first as AnnouncementsViewController
        
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
    
    enum NotificationKey: String {
        case EventID = "eventID"
        case AnnouncementID = "announcementID"
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveEventually()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        if let message = userInfo["aps"]?["alert"] as? String {
            
            switch application.applicationState {
                
            case .Active:
                
                var actions: [UIAlertAction] = []
                
                if let eventID = userInfo[NotificationKey.EventID.rawValue] as? String {
                    
                    let actionTitle = NSLocalizedString("View", comment: "Alert action")
                    
                    let action = UIAlertAction(title: actionTitle, style: .Default, handler: { action in
                        self.showEventWithID(eventID)
                    })
                    
                    actions += [action]
                }
                
                showAlertControllerWithMessage(message, actions: actions)
                
            default:
                
                if let eventID = userInfo[NotificationKey.EventID.rawValue] as? String {
                    showEventWithID(eventID)
                }
                
                if let announcementID = userInfo[NotificationKey.AnnouncementID.rawValue] as? String {
                    showAnnouncementWithID(announcementID)
                }
            }
        }
        
        completionHandler(.NewData)
    }
    
    func showAlertControllerWithMessage(message: String, actions: [UIAlertAction]) {
        
        let title = NSLocalizedString("Alert", comment: "Alert title")
        
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .Alert)
        
        for action in actions {
            alertController.addAction(action)
        }
        
        let dismissActionTitle = NSLocalizedString("Dismiss", comment: "Notification alert dismiss action title")
        
        alertController.addAction(UIAlertAction(title: dismissActionTitle, style: .Cancel, handler: { action in
            // Do nothing
        }))
        
        // FIXME: Test if this works
        tabBarController.showViewController(alertController, sender: nil)
        
        //tabBarController.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showEventWithID(ID: String) {
        
        scheduleViewController.fetchResultsManager.fetch {
            
            self.tabBarController.selectedIndex = Tab.Schedule.rawValue
            self.scheduleNavigationController.popToRootViewControllerAnimated(false)
            self.scheduleViewController.showDetailsForEventWithID(ID)
        }
    }
    
    func showAnnouncementWithID(ID: String) {
        
        announcementsViewController.fetchResultsManager.fetch {
            
            self.tabBarController.selectedIndex = Tab.Announcements.rawValue
        }
    }
    
    // MARK: User notifications
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
        // Gets called redundantly every time the app launches
    }
}

