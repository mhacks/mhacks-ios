//
//  LoginViewController.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/14/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController
{

	@IBOutlet var usernameField: UITextField!
	@IBOutlet var passwordField: UITextField!
		
	override func viewDidLoad()
	{
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}
	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)
		guard !APIManager.sharedManager.isLoggedIn
		else
		{
			didLogin()
			return
		}
	}
	func didLogin()
	{
		dispatch_async(dispatch_get_main_queue(), {
			self.dismissViewControllerAnimated(true, completion: nil)
		})
	}
	private func shakePasswordField(iterations: Int, direction: Int, currentTimes: Int, size: CGFloat, interval: NSTimeInterval) {
		UIView.animateWithDuration(interval, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 10, options: [], animations: {() in
			self.passwordField.transform = CGAffineTransformMakeTranslation(size * CGFloat(direction), 0)
			}, completion: {(finished) in
				if (currentTimes >= iterations)
				{
					UIView.animateWithDuration(interval, animations: {() in
						self.passwordField.transform = CGAffineTransformIdentity
					})
					return
				}
				self.shakePasswordField(iterations - 1, direction: -direction, currentTimes: currentTimes + 1, size: size, interval: interval)
		})

	}
	
	func incorrectPassword()
	{
		dispatch_async(dispatch_get_main_queue(), {
			self.passwordField.text = ""
			self.shakePasswordField(7, direction: 1, currentTimes: 0, size: 10, interval: 0.1)
		})
	}
	
	@IBAction func login(sender: UIButton)
	{
		resignFirstResponder()
		guard let username = usernameField.text, let password = passwordField.text where !username.isEmpty && !password.isEmpty
		else
		{
			incorrectPassword()
			return
		}
		let remoteNotificationData = NSUserDefaults.standardUserDefaults().dataForKey(remoteNotificationDataKey)
		// TODO: Use remote notification data to login
		print(remoteNotificationData)
		APIManager.sharedManager.loginWithUsername(username, password: password) {
			switch $0
			{
			case .Value(let loggedIn):
				guard loggedIn
				else
				{
					self.incorrectPassword()
					return
				}
				self.didLogin()
			case .NetworkingError(let error):
				NSNotificationCenter.defaultCenter().postNotificationName(APIManager.connectionFailedNotification, object: error)
			case .UnknownError:
				self.incorrectPassword()
			}
		}
	}
    
    @IBAction func cancelLogin (sender: UINavigationItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

