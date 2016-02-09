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
	
	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)
		guard !APIManager.sharedManager.isLoggedIn
		else
		{
			self.dismissViewControllerAnimated(true, completion: nil)
			return
		}
	}
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		usernameField.resignFirstResponder()
		passwordField.resignFirstResponder()
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
	
	@IBAction func login(sender: UIBarButtonItem? = nil)
	{
		resignFirstResponder()
		guard let username = usernameField.text, let password = passwordField.text where !username.isEmpty && !password.isEmpty
		else
		{
			incorrectPassword()
			return
		}
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
				self.dismissViewControllerAnimated(true, completion: nil)
			case .NetworkingError(let error):
				NSNotificationCenter.defaultCenter().postNotificationName(APIManager.connectionFailedNotification, object: error)
			case .UnknownError:
				self.incorrectPassword()
			}
		}
	}
    
    @IBAction func cancelLogin (sender: UIBarButtonItem)
	{
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension LoginViewController : UITextFieldDelegate
{
	func textFieldShouldReturn(textField: UITextField) -> Bool
	{
		if textField === usernameField
		{
			textField.resignFirstResponder()
			passwordField.becomeFirstResponder()
		}
		else
		{
			passwordField.resignFirstResponder()
			login()
		}
		return true
	}
}