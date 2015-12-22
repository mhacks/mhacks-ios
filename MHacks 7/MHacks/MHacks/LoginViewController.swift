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
			// TODO: Figure out if already logged in and if so call `didLogin()`
			didLogin()
			return
		}
	}
	func didLogin()
	{
		performSegueWithIdentifier("loginSegue", sender: nil)
	}
	func showError(error: NSError)
	{
		// TODO: Show error on UIAlertController
	}
	func incorrectPassword()
	{
		// TODO: Shake password field for wrong input
	}
	@IBAction func loginWithoutCredentials(sender: UIButton)
	{
		// TODO: Set the authenticator with the default values somehow.
		didLogin()
	}
	@IBAction func login(sender: UIButton)
	{
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
				self.didLogin()
			case .NetworkingError(let error):
				self.showError(error)
			case .UnknownError:
				self.incorrectPassword()
			}
		}
	}
}

