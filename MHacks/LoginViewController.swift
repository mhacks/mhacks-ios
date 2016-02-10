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
	@IBOutlet var tableView: UITableView!
	var usernameField: UITextField!
	{
		didSet {
			usernameField?.returnKeyType = .Next
			usernameField?.delegate = self
		}
	}
	var passwordField: UITextField!
	{
		didSet {
			passwordField?.returnKeyType = .Done
			passwordField?.delegate = self
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
	}
	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardShown:", name: UIKeyboardDidShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardHidden:", name: UIKeyboardDidHideNotification, object: nil)
		
		guard !APIManager.sharedManager.isLoggedIn
		else
		{
			self.dismissViewControllerAnimated(true, completion: nil)
			return
		}
	}
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self)
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
	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator)
	{
		self.view.frame.size = size
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
extension LoginViewController: UITableViewDelegate, UITableViewDataSource
{
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		guard indexPath.row != 0
		else
		{
			return tableView.dequeueReusableCellWithIdentifier("logoCell")!
		}
		let cell = tableView.dequeueReusableCellWithIdentifier("textFieldCell") as! TextFieldCell
		if indexPath.row == 1
		{
			cell.textField.placeholder = "Username"
			cell.textField.keyboardType = .EmailAddress
			cell.textField.autocorrectionType = .No
			usernameField = cell.textField
		}
		else
		{
			cell.textField.placeholder = "Password"
			cell.textField.secureTextEntry = true
			cell.textField.keyboardType = .Default
			passwordField = cell.textField
		}
		return cell
	}
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
	{
		if indexPath.row == 0
		{
			return 200.0
		}
		else
		{
			return tableView.rowHeight
		}
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
	func keyboardShown(notification: NSNotification)
	{
		guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
		else
		{
			return
		}
		var contentInsets = tableView.contentInset
		contentInsets.bottom = keyboardSize.height
		tableView.contentInset = contentInsets
		tableView.scrollIndicatorInsets = contentInsets
		guard let field = usernameField.isFirstResponder() ? usernameField : passwordField.isFirstResponder() ? passwordField : nil
		else
		{
			return
		}
		var rect = self.view.frame
		rect.size.height -= keyboardSize.height
		if (!rect.contains(field.frame))
		{
			tableView.scrollRectToVisible(field.frame, animated: true)
		}
	}
	func keyboardHidden(notification: NSNotification)
	{
		var contentInsets = tableView.contentInset
		contentInsets.bottom = 0.0
		tableView.contentInset = contentInsets
		tableView.scrollIndicatorInsets = contentInsets
	}
}