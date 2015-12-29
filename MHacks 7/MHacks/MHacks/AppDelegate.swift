//
//  AppDelegate.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/14/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		
		application.registerForRemoteNotifications()
		let settings = UIUserNotificationSettings(forTypes: [.Sound, .Alert], categories: nil)
		application.registerUserNotificationSettings(settings)

		NSNotificationCenter.defaultCenter().addObserver(self, selector: "connectionError:", name: APIManager.connectionFailedNotification, object: nil)
		
		return true
	}
	func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
		
		// TODO: Send to provider on login
		NSUserDefaults.standardUserDefaults().setObject(deviceToken, forKey: remoteNotificationDataKey)
	}
	func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
		NSNotificationCenter.defaultCenter().postNotificationName(APIManager.connectionFailedNotification, object: error)
	}
	func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
		// TODO: Use notification 
	}
	
	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	var statusWindow : UIWindow?
	
	func connectionError(notification: NSNotification)
	{
		guard statusWindow == nil
		else
		{
			// There already exists an error message
			// so we discard this one. Maybe we could queue the errors up?
			return
		}
		dispatch_async(dispatch_get_main_queue(), {
			self.statusWindow = UIWindow(frame: UIApplication.sharedApplication().statusBarFrame)
			self.statusWindow!.windowLevel = UIWindowLevelStatusBar + 1 // Display over status bar
			let label = UILabel(frame: self.statusWindow!.bounds)
			label.textAlignment = .Center
			label.backgroundColor = UIColor.redColor()
			label.textColor = UIColor.whiteColor()
			label.font = UIFont.boldSystemFontOfSize(12)
			label.text = (notification.object as? NSError)?.localizedDescription.sentenceCapitalizedString ?? "Network Error"
			self.statusWindow!.addSubview(label)
			self.statusWindow!.makeKeyAndVisible()
			self.statusWindow!.frame.origin.y -= self.statusWindow!.frame.height
			// FIXME: Make animation better?
//			label.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI) * 0.5, 1, 0, 0)
			UIView.animateWithDuration(0.5, animations: {
//				label.layer.transform = CATransform3DIdentity
				self.statusWindow!.frame.origin.y += self.statusWindow!.frame.height
				}, completion: { _ in
					let delayInSeconds = 3.0 // Hide after time
					let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
					dispatch_after(popTime, dispatch_get_main_queue(), {
						UIView.animateWithDuration(0.5, animations: {
//							label.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI) * 0.5, -1, 0, 0)
							self.statusWindow!.frame.origin.y -= self.statusWindow!.frame.height
							}, completion: { _ in
								self.statusWindow!.hidden = true
								self.statusWindow = nil
								self.window?.makeKeyAndVisible()
						})
					})
			})
		})
	}
	
}

