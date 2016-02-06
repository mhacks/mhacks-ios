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
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		window?.backgroundColor = UIColor(red: 255.0 / 255.0, green: 230.0 / 255.0, blue: 65.0 / 255.0, alpha: 1.0)
		// Override point for customization after application launch.
		GMSServices.provideAPIKey("AIzaSyDZwjHS79q4iV2_ZWWYvcNDRYzhdYKGoFQ")
		application.registerForRemoteNotifications()
		let settings = UIUserNotificationSettings(forTypes: [.Sound, .Alert], categories: nil)
		application.registerUserNotificationSettings(settings)

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "connectionError:", name: APIManager.connectionFailedNotification, object: nil)
		
		return true
	}
	func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
		let sentAPNSToken = NSUserDefaults.standardUserDefaults().boolForKey(remoteNotificationSentKey)
		if !sentAPNSToken
		{
			let deviceTokenString = deviceToken.description.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "<>")).stringByReplacingOccurrencesOfString(" ", withString: "")
			NSUserDefaults.standardUserDefaults().setObject(deviceTokenString, forKey: remoteNotificationDataKey)
			APIManager.sharedManager.updateAPNSToken(deviceTokenString, completion: { pushed in
				guard pushed
				else
				{
					return
				}
				NSUserDefaults.standardUserDefaults().setBool(true, forKey: remoteNotificationSentKey)
			})
		}
	}
	
	func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
		NSNotificationCenter.defaultCenter().postNotificationName(APIManager.connectionFailedNotification, object: error)
	}
	func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
		APIManager.sharedManager.updateAnnouncements()
		completionHandler(.NewData)
	}
	
	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		APIManager.sharedManager.archive()
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		APIManager.sharedManager.archive()
	}

	var statusWindow : UIWindow?
	var label : UILabel?
	
	func makeLabel(error: NSError?)
	{
		self.label = UILabel(frame: self.statusWindow?.bounds ?? CGRectZero)
		self.label?.textAlignment = .Center
		self.label?.backgroundColor = UIColor.redColor()
		self.label?.textColor = UIColor.whiteColor()
		self.label?.font = UIFont.boldSystemFontOfSize(12)
		self.label?.text = error?.localizedDescription.sentenceCapitalizedString ?? "Unknown Error"
	}
	
	func connectionError(notification: NSNotification)
	{
		guard statusWindow == nil && label == nil
		else
		{
			label!.text = (notification.object as? NSError)?.localizedDescription.sentenceCapitalizedString ?? label!.text
			// There already exists an error message
			// so we discard this one. Maybe we could queue the errors up?
			return
		}
		dispatch_async(dispatch_get_main_queue(), {
			self.statusWindow = UIWindow(frame: UIApplication.sharedApplication().statusBarFrame)
			self.statusWindow?.windowLevel = UIWindowLevelStatusBar + 1 // Display over status bar
			
			self.makeLabel(notification.object as? NSError)
			
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

