//
//  AppDelegate.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/14/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {

	var window: UIWindow?
	
	var tabBarController: UITabBarController!
	
	var scheduleNavigationController: UINavigationController!
	var scheduleViewController: ScheduleCalendarViewController!
	
	var countdownViewController: CountdownViewController!
	
	var announcementsNavigationController: UINavigationController!
	
	var userNavigationController: UINavigationController!
	var userViewController: UserViewController!
	
	// MARK: Application life cycle
	func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]?) -> Bool {
		
		window!.tintColor = MHacksColor.purple
		
		tabBarController = window!.rootViewController as! UITabBarController
		tabBarController.delegate = self
		
		scheduleNavigationController = tabBarController.viewControllers![0] as! UINavigationController
		scheduleViewController = scheduleNavigationController.viewControllers[0] as! ScheduleCalendarViewController
		
		countdownViewController = tabBarController.viewControllers![2] as! CountdownViewController
		
		announcementsNavigationController = tabBarController.viewControllers![3] as! UINavigationController
		
		userNavigationController = tabBarController.viewControllers![4] as! UINavigationController
		userViewController = userNavigationController.viewControllers[0] as! UserViewController
		
		userNavigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
		userNavigationController.navigationBar.shadowImage = UIImage()
		
		return true
	}

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		application.registerForRemoteNotifications()
		let settings = UIUserNotificationSettings(types: [.sound, .alert], categories: nil)
		application.registerUserNotificationSettings(settings)
		
		NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.error(_:)), name: APIManager.FailureNotification, object: nil)
		
		switch launchOptions?[UIApplicationLaunchOptionsKey.localNotification] {
			
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
	
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
		let deviceTokenString = deviceToken.reduce("", {
			$0 + String(format: "%02x", $1)
		})
		if defaults.object(forKey: remoteNotificationPreferencesKey) == nil
		{
			defaults.set(63, forKey: remoteNotificationPreferencesKey)
		}
		defaults.set(deviceTokenString, forKey: remoteNotificationTokenKey)
		APIManager.shared.updateAPNSToken()
	}
	
	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
		NotificationCenter.default.post(name: APIManager.FailureNotification, object: error.localizedDescription)
	}

	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		APIManager.shared.updateAnnouncements({ completed in
			if completed {
				completionHandler(.newData)
			} else {
				completionHandler(.failed)
			}
		})
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		APIManager.shared.archive()
	}

	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		guard url.absoluteString.hasPrefix("mhacks://")
		else {
			return false
		}
		
		let eventID = url.absoluteString.replacingOccurrences(of: "mhacks://", with: "")
		
		switch eventID {
		case "announcements":
			selectViewController(announcementsNavigationController)
		default:
			showEventWithID(eventID)
		}
		
		return true
	}
	
	// MARK: Show event
	
	func showEventWithID(_ eventID: String) {
		
		selectViewController(scheduleNavigationController)
		
		let displayEvent = { () -> Bool in
			
			guard let event = APIManager.shared.events[eventID] else {
				return false
			}
			
			self.scheduleViewController.showDetailsForEvent(event)
			
			return true
		}
		
		guard !displayEvent() else {
			return
		}
		
		APIManager.shared.updateEvents { succeeded in
			guard displayEvent() else {
				NotificationCenter.default.post(name: APIManager.FailureNotification, object: "Could not find the associated event")
				return
			}
		}
	}
	
	// MARK: Tab bar controller delegate
	
	func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
		updateTabBarAppearance()
	}
	
	func selectViewController(_ viewController: UIViewController) {
		tabBarController.selectedViewController = viewController
		updateTabBarAppearance()
	}
	
	func updateTabBarAppearance() {
		
		let minimalist = (tabBarController.selectedViewController == countdownViewController || tabBarController.selectedViewController == userNavigationController)
		
		tabBarController.tabBar.backgroundImage = minimalist ? UIImage() : nil
		tabBarController.tabBar.shadowImage = minimalist ? UIImage() : nil
	}
	
	// MARK: Status window
	
	var statusWindow : UIWindow?
	var label : UILabel?
	var lastErrorMessage: String?
	
	fileprivate func makeLabel(_ text: String?) {
		self.label = UILabel(frame: self.statusWindow?.bounds ?? CGRect.zero)
		self.label?.textAlignment = .center
		self.label?.backgroundColor = MHacksColor.red
		self.label?.textColor = UIColor.white
		self.label?.font = UIFont.boldSystemFont(ofSize: 12)
		self.label?.text = text ?? "Unknown Error"
	}
	
	func error(_ notification: Notification) {
		DispatchQueue.main.async(execute: {
			guard self.statusWindow == nil && self.label == nil
			else
			{
				self.label?.text = (notification.object as? String)?.sentenceCapitalizedString ?? self.label?.text
				// There already exists an error message so we discard this one.
				return
			}
			
			self.statusWindow = UIWindow(frame: UIApplication.shared.statusBarFrame)
			self.statusWindow?.windowLevel = UIWindowLevelStatusBar + 1 // Display over status bar
			
			guard let errorMessage = (notification.object as? String)?.sentenceCapitalizedString, errorMessage != self.lastErrorMessage
			else {
				// Don't show the same error repeatedly, this will annoy the user, especially if they keep seeing, internet connection not available.
				return
			}
			self.lastErrorMessage = errorMessage
			self.makeLabel(self.lastErrorMessage)
			
			self.statusWindow?.addSubview(self.label!)
			self.statusWindow?.makeKeyAndVisible()
			self.statusWindow?.frame.origin.y -= self.statusWindow?.frame.height ?? 0.0

			UIView.animate(withDuration: 0.5, animations: {
				self.statusWindow?.frame.origin.y += self.statusWindow?.frame.height ?? 0.0
				}, completion: { _ in
					let delayInSeconds = 3.0 // Hide after time
					let popTime = DispatchTime.now() + Double(Int64(delayInSeconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
					DispatchQueue.main.asyncAfter(deadline: popTime, execute: {
						UIView.animate(withDuration: 0.5, animations: {
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
