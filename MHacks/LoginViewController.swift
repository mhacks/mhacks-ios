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
			usernameField?.returnKeyType = .next
			usernameField?.delegate = self
		}
	}
	var passwordField: UITextField!
	{
		didSet {
			passwordField?.returnKeyType = .done
			passwordField?.delegate = self
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
	}
	override func viewDidAppear(_ animated: Bool)
	{
		super.viewDidAppear(animated)
		
		NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardShown(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardHidden(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
		
		guard !APIManager.shared.userState.loggedIn
		else
		{
			self.dismiss(animated: true, completion: nil)
			return
		}
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self)
		usernameField.resignFirstResponder()
		passwordField.resignFirstResponder()
	}
	fileprivate func shakePasswordField(_ iterations: Int, direction: Int, currentTimes: Int, size: CGFloat, interval: TimeInterval) {
		UIView.animate(withDuration: interval, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 10, options: [], animations: {() in
			self.passwordField.transform = CGAffineTransform(translationX: size * CGFloat(direction), y: 0)
			}, completion: {(finished) in
				if (currentTimes >= iterations)
				{
					UIView.animate(withDuration: interval, animations: {() in
						self.passwordField.transform = CGAffineTransform.identity
					})
					return
				}
				self.shakePasswordField(iterations - 1, direction: -direction, currentTimes: currentTimes + 1, size: size, interval: interval)
		})
	}
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
	{
		self.view.frame.size = size
	}
	func incorrectPassword()
	{
		DispatchQueue.main.async(execute: {
			self.passwordField.text = ""
			self.shakePasswordField(7, direction: 1, currentTimes: 0, size: 10, interval: 0.1)
		})
	}
	
	@IBAction func login(_ sender: UIBarButtonItem? = nil)
	{
		resignFirstResponder()
		guard let username = usernameField.text, let password = passwordField.text , !username.isEmpty && !password.isEmpty
		else
		{
			incorrectPassword()
			return
		}
		APIManager.shared.loginWithUsername(username, password: password) {
			switch $0
			{
			case .value(let loggedIn):
				guard loggedIn
				else
				{
					self.incorrectPassword()
					return
				}
				self.dismiss(animated: true, completion: nil)
			case .error(let errorMessage):
				NotificationCenter.default.post(name: APIManager.FailureNotification, object: errorMessage)
			}
		}
	}
    
    @IBAction func cancelLogin (_ sender: UIBarButtonItem)
	{
        self.dismiss(animated: true, completion: nil)
    }
}
extension LoginViewController: UITableViewDelegate, UITableViewDataSource
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		guard (indexPath as NSIndexPath).row != 0
		else
		{
			return tableView.dequeueReusableCell(withIdentifier: "logoCell")!
		}
		let cell = tableView.dequeueReusableCell(withIdentifier: "textFieldCell") as! TextFieldCell
		if (indexPath as NSIndexPath).row == 1
		{
			cell.textField.placeholder = "Username"
			cell.textField.keyboardType = .emailAddress
			cell.textField.autocorrectionType = .no
			usernameField = cell.textField
		}
		else
		{
			cell.textField.placeholder = "Password"
			cell.textField.isSecureTextEntry = true
			cell.textField.keyboardType = .default
			passwordField = cell.textField
		}
		return cell
	}
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
		if (indexPath as NSIndexPath).row == 0
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
	func textFieldShouldReturn(_ textField: UITextField) -> Bool
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
	func keyboardShown(_ notification: Notification)
	{
		guard let keyboardSize = ((notification as NSNotification).userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
		else
		{
			return
		}
		var contentInsets = tableView.contentInset
		contentInsets.bottom = keyboardSize.height
		tableView.contentInset = contentInsets
		tableView.scrollIndicatorInsets = contentInsets
		guard let field = usernameField.isFirstResponder ? usernameField : passwordField.isFirstResponder ? passwordField : nil
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
	func keyboardHidden(_ notification: Notification)
	{
		var contentInsets = tableView.contentInset
		contentInsets.bottom = 0.0
		tableView.contentInset = contentInsets
		tableView.scrollIndicatorInsets = contentInsets
	}
}
