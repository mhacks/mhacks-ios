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

	func connectionError(notification: NSNotification)
	{
		var statusWindow : UIWindow! = UIWindow(frame: UIApplication.sharedApplication().statusBarFrame)
		statusWindow.windowLevel = UIWindowLevelStatusBar + 1 // Display over status bar
		let label = UILabel(frame: statusWindow.bounds)
		label.textAlignment = .Center
		label.backgroundColor = UIColor.clearColor()
		label.textColor = UIColor.blackColor()
		label.font = UIFont.boldSystemFontOfSize(13)
		label.text = (notification.object as? NSError)?.localizedDescription ?? "Network Error"
		statusWindow.addSubview(label)
		statusWindow.makeKeyAndVisible()
		label.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI) * 0.5, 1, 0, 0)
		UIView.animateWithDuration(0.7, animations: {
			label.layer.transform = CATransform3DIdentity
			}, completion: { finished in
				let delayInSeconds = 5.0 // Hide after time
				let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
				dispatch_after(popTime, dispatch_get_main_queue(), {
					UIView.animateWithDuration(0.5, animations: {
						label.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI) * 0.5, -1, 0, 0)
						}, completion: { finished in
							statusWindow = nil
							self.window?.makeKeyAndVisible()
					})
				})
		})
	}
	
}

