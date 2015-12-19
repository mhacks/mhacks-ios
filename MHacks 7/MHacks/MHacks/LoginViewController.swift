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
		// TODO: Figure out if already logged in and if so call `didLogin()`
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
		// TODO: Shake password field.
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
		APIManager.sharedManager.taskWithRoute("/v1/sessions/create", parameters: ["username": username, "password": password], requireAccessToken: false, completion: { (result: Either<Authenticator>) in
			switch result
			{
			case .Value(let user):
				APIManager.sharedManager.authenticator = user
				self.didLogin()
			case .NetworkingError(let error):
				self.showError(error)
			case .UnknownError:
				self.incorrectPassword()
			}
		})
	}
}

