//
//  AppDelegate.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/14/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import UIKit
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {

	var window: UIWindow?
	
	var tabBarController: UITabBarController!
	
	var scheduleNavigationController: UINavigationController!
	var scheduleViewController: ScheduleCalendarViewController!
	
	var countdownViewController: CountdownViewController!
	
	var announcementsNavigationController: UINavigationController!
	
	// MARK: Application life cycle
	
	func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
		
		tabBarController = window!.rootViewController as! UITabBarController
		tabBarController.delegate = self
		
		scheduleNavigationController = tabBarController.viewControllers![0] as! UINavigationController
		scheduleViewController = scheduleNavigationController.viewControllers[0] as! ScheduleCalendarViewController
		
		countdownViewController = tabBarController.viewControllers![2] as! CountdownViewController
		
		announcementsNavigationController = tabBarController.viewControllers![3] as! UINavigationController
		
		return true
	}

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		GMSServices.provideAPIKey("AIzaSyDZwjHS79q4iV2_ZWWYvcNDRYzhdYKGoFQ")
		application.registerForRemoteNotifications()
		let settings = UIUserNotificationSettings(forTypes: [.Sound, .Alert], categories: nil)
		application.registerUserNotificationSettings(settings)
		
		NSNotificationCenter.defaultCenter().listenFor(.Failure, observer: self, selector: #selector(AppDelegate.error(_:)))
		
		switch launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] {
			
		case let notification as UILocalNotification:
			if let eventID = notification.userInfo?["id"] as? String {
				showEventWithID(eventID)
			}
			
		case _ as [String: AnyObject]:
			selectViewController(announcementsNavigationController)
			
		default:
			selectViewController(countdownViewController)
		}
		
		return true
	}
	
	func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
		
		if let _ = defaults.objectForKey(remoteNotificationTokenKey) as? String
		{
			return
		}
		let deviceTokenString = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>")).stringByReplacingOccurrencesOfString(" ", withString: "")
		APIManager.sharedManager.updateAPNSToken(deviceTokenString, completion: nil)
	}
	
	func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
		NSNotificationCenter.defaultCenter().post(.Failure, object: error.localizedDescription)
	}
	
	func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
		APIManager.sharedManager.updateAnnouncements()
		completionHandler(.NewData)
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		APIManager.sharedManager.archive()
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		APIManager.sharedManager.archive()
	}

	func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
		
		guard url.absoluteString.hasPrefix("mhacks://") else {
			return false
		}
		
		let eventID = url.absoluteString.stringByReplacingOccurrencesOfString("mhacks://", withString: "")
		
		switch eventID {
		case "announcements":
			selectViewController(announcementsNavigationController)
		default:
			showEventWithID(eventID)
		}
		
		return true
	}
	
	// MARK: Show event
	
	func showEventWithID(eventID: String) {
		
		selectViewController(scheduleNavigationController)
		
		let displayEvent = { () -> Bool in
			if let (day, index) = APIManager.sharedManager.eventsOrganizer.findDayAndIndexForEventWithID(eventID) {
				self.scheduleViewController.showDetailsForEvent(APIManager.sharedManager.eventsOrganizer.eventAtIndex(index, inDay: day))
				return true
			}
			return false
		}
		
		guard !displayEvent() else {
			return
		}
		
		APIManager.sharedManager.updateEvents { succeeded in
			guard displayEvent() else {
				NSNotificationCenter.defaultCenter().post(.Failure, object: "Could not find the associated event")
				return
			}
		}
	}
	
	// MARK: Tab bar controller delegate
	
	func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
		
		updateTabBarAppearance()
	}
	
	func selectViewController(viewController: UIViewController) {
		
		tabBarController.selectedViewController = viewController
		updateTabBarAppearance()
	}
	
	func updateTabBarAppearance() {
		
		let minimalist = (tabBarController.selectedViewController == countdownViewController)
		
		tabBarController.tabBar.backgroundImage = minimalist ? UIImage() : nil
		tabBarController.tabBar.shadowImage = minimalist ? UIImage() : nil
	}
	
	// MARK: Status window
	
	var statusWindow : UIWindow?
	var label : UILabel?
	
	private func makeLabel(text: String?) {
		self.label = UILabel(frame: self.statusWindow?.bounds ?? CGRectZero)
		self.label?.textAlignment = .Center
		self.label?.backgroundColor = UIColor.redColor()
		self.label?.textColor = UIColor.whiteColor()
		self.label?.font = UIFont.boldSystemFontOfSize(12)
		self.label?.text = text ?? "Unknown Error"
	}
	
	func error(notification: NSNotification) {
		guard statusWindow == nil && label == nil
		else
		{
			label!.text = (notification.object as? String)?.sentenceCapitalizedString ?? label!.text
			// There already exists an error message
			// so we discard this one. Maybe we could queue the errors up and have timeouts of some sort?
			// FIXME: Hack to prevent multiple errors from colliding with each other
			return
		}
		dispatch_async(dispatch_get_main_queue(), {
			self.statusWindow = UIWindow(frame: UIApplication.sharedApplication().statusBarFrame)
			self.statusWindow?.windowLevel = UIWindowLevelStatusBar + 1 // Display over status bar
			
			self.makeLabel(notification.object as? String)
			
			self.statusWindow?.addSubview(self.label!)
			self.statusWindow?.makeKeyAndVisible()
			self.statusWindow?.frame.origin.y -= self.statusWindow?.frame.height ?? 0.0

			UIView.animateWithDuration(0.5, animations: {
				self.statusWindow?.frame.origin.y += self.statusWindow?.frame.height ?? 0.0
				}, completion: { _ in
					let delayInSeconds = 3.0 // Hide after time
					let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
					dispatch_after(popTime, dispatch_get_main_queue(), {
						UIView.animateWithDuration(0.5, animations: {
							self.statusWindow?.frame.origin.y -= self.statusWindow?.frame.height ?? 0.0
							}, completion: { _ in
								self.statusWindow = nil
								self.label = nil
								self.window?.makeKeyAndVisible()
						})
					})
			})
		})
	}
}
