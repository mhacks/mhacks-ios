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
    
    // MARK: Initialization
    
    override init() {
        super.init()
        
        // Parse
        
        Parse.enableLocalDatastore()
        Parse.setApplicationId(Keys.sharedKeys.parseApplicationID, clientKey: Keys.sharedKeys.parseClientKey)
    }
    
    // MARK: Window
    
    var window: UIWindow?
    
    // MARK: View controllers
    
    enum Tab: Int {
        case Schedule
        case Maps
        case Countdown
        case Announcements
        case Sponsors
    }
    
    var tabBarController: UITabBarController!
    
    var scheduleNavigationController: UINavigationController!
    var scheduleViewController: ScheduleCalendarViewController!
    
    var countdownNavigationController: UINavigationController!
    var countdownViewController: CountdownViewController!
    
    var announcementsNavigationController: UINavigationController!
    var announcementsViewController: AnnouncementsViewController!
    
    var sponsorsNavigationController: UINavigationController!
    var sponsorsViewController: SponsorsViewController!
    
    var mapNavigationController: UINavigationController!
    var mapViewController: MapViewController!
    
    // MARK: Launch
    
    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        // Tint color
        
        window!.tintColor = Color.purple
        
        // View controllers
        
        tabBarController = window!.rootViewController as! UITabBarController
        
        scheduleNavigationController = tabBarController.viewControllers![Tab.Schedule.rawValue] as! UINavigationController
        scheduleNavigationController.tabBarItem.selectedImage = UIImage(named: "Schedule Selected")
        scheduleViewController = scheduleNavigationController.viewControllers.first as! ScheduleCalendarViewController
        
        countdownNavigationController = tabBarController.viewControllers![Tab.Countdown.rawValue] as! UINavigationController
        countdownNavigationController.tabBarItem.selectedImage = UIImage(named: "Countdown Selected")
        countdownViewController = countdownNavigationController.viewControllers.first as! CountdownViewController
        
        announcementsNavigationController = tabBarController.viewControllers![Tab.Announcements.rawValue] as! UINavigationController
        announcementsNavigationController.tabBarItem.selectedImage = UIImage(named: "News Selected")
        announcementsViewController = announcementsNavigationController.viewControllers.first as! AnnouncementsViewController
        
        sponsorsNavigationController = tabBarController.viewControllers![Tab.Sponsors.rawValue] as! UINavigationController
        sponsorsNavigationController.tabBarItem.selectedImage = UIImage(named: "Sponsors Selected")
        sponsorsViewController = sponsorsNavigationController.viewControllers.first as! SponsorsViewController
        
        mapNavigationController = tabBarController.viewControllers![Tab.Maps.rawValue] as! UINavigationController
        mapNavigationController.tabBarItem.selectedImage = UIImage(named: "Maps Selected")
        mapViewController = mapNavigationController.viewControllers.first as! MapViewController
        
        return true
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        // Remote notifications
        
        application.registerForRemoteNotifications()
        
        // User notifications
        
        let settings = UIUserNotificationSettings(forTypes: .Sound | .Alert, categories: nil)
        application.registerUserNotificationSettings(settings)
        
        return true
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
                
                if let announcementID = userInfo[NotificationKey.AnnouncementID.rawValue] as? String {
                    
                    announcementsViewController.fetchResultsManager.fetch(.Remote)
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
        
        tabBarController.showViewController(alertController, sender: nil)
    }
    
    func showEventWithID(ID: String) {
        
        scheduleViewController.fetchResultsManager.fetch(.Remote) { error in
            
            self.tabBarController.selectedIndex = Tab.Schedule.rawValue
            self.scheduleNavigationController.popToRootViewControllerAnimated(false)
            self.scheduleViewController.showDetailsForEventWithID(ID)
        }
    }
    
    func showAnnouncementWithID(ID: String) {
        
        announcementsViewController.fetchResultsManager.fetch(.Remote) { error in
            
            self.tabBarController.selectedIndex = Tab.Announcements.rawValue
        }
    }
    
    // MARK: User notifications
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
        // Gets called redundantly every time the app launches
    }
}

