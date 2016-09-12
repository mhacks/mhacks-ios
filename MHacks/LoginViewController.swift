//
//  LoginViewController.swift
//  MHacks
//
//  Created by Manav Gabhawala on 12/14/15.
//  Copyright © 2015 MHacks. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate: class {
	
	func loginViewControllerDidCancel(loginViewController: LoginViewController)
	func loginViewControllerDidLogin(loginViewController: LoginViewController)
}

final class LoginViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
	
	let tableView = UITableView(frame: CGRect.zero, style: .grouped)
	
	let usernameCell = TextFieldCell(style: .default, reuseIdentifier: nil)
	let passwordCell = TextFieldCell(style: .default, reuseIdentifier: nil)
	
	let signInBarButtonItem = UIBarButtonItem(title: "Sign In", style: .plain, target: nil, action: nil)
	
	weak var delegate: LoginViewControllerDelegate?
	
	override func loadView() {
		
		// View
		
		view = tableView
		
		// Table view
		
		tableView.dataSource = self
		tableView.delegate = self
		tableView.allowsSelection = false
		
		// Bar button items
		
		navigationItem.title = "MHacks"
		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
		navigationItem.rightBarButtonItem = signInBarButtonItem
		
		signInBarButtonItem.target = self
		signInBarButtonItem.action = #selector(login)
		
		// Cells
		
		usernameCell.label.text = "Username"
		
		usernameCell.textField.placeholder = "hacker@school.edu"
		usernameCell.textField.keyboardType = .emailAddress
		usernameCell.textField.autocorrectionType = .no
		usernameCell.textField.autocapitalizationType = .none
		usernameCell.textField.returnKeyType = .next
		usernameCell.textField.delegate = self
		
		passwordCell.label.text = "Password"
		
		passwordCell.textField.placeholder = "required"
		passwordCell.textField.isSecureTextEntry = true
		passwordCell.textField.returnKeyType = .done
		passwordCell.textField.delegate = self
	}
	
	private var firstAppearance = true
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if firstAppearance {
			usernameCell.textField.becomeFirstResponder()
			firstAppearance = false
		}
	}
	
	/*fileprivate func shakePasswordField(_ iterations: Int, direction: Int, currentTimes: Int, size: CGFloat, interval: TimeInterval) {
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
	}*/
	
	func incorrectPassword() {
		DispatchQueue.main.async(execute: {
			self.passwordCell.textField.text = nil
			//self.shakePasswordField(7, direction: 1, currentTimes: 0, size: 10, interval: 0.1)
		})
	}
	
	// MARK: Actions
	
	func login(_ sender: UIBarButtonItem? = nil) {
		
		guard let username = usernameCell.textField.text, let password = passwordCell.textField.text, !username.isEmpty && !password.isEmpty else {
			return
		}
		
		APIManager.shared.loginWithUsername(username, password: password) { response in
			
			DispatchQueue.main.async {
				
				switch response {
					
				case .value(let loggedIn):
					
					if loggedIn {
						self.delegate?.loginViewControllerDidLogin(loginViewController: self)
					} else {
						self.incorrectPassword()
					}
					
				case .error(let errorMessage):
					NotificationCenter.default.post(name: APIManager.FailureNotification, object: errorMessage)
				}
			}
		}
	}
	
    func cancel() {
		view.endEditing(true)
		delegate?.loginViewControllerDidCancel(loginViewController: self)
    }
	
	// MARK: Table view data source
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 2
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		switch indexPath.row {
			
		case 0:
			return usernameCell
			
		case 1:
			return passwordCell
			
		default: fatalError()
		}
	}
	
	// MARK: Table view delegate
	
	func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		return "Sign in if you are a registered hacker."
	}
	
	// MARK: Text field delegate
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool
	{
		switch textField {
			
		case usernameCell.textField:
			passwordCell.textField.becomeFirstResponder()
			
		case passwordCell.textField:
			textField.resignFirstResponder()
			login()
			
		default: fatalError()
		}
		
		return true
	}
}
