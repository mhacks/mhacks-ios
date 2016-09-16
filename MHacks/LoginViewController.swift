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
	
	// MARK: Delegate
	
	weak var delegate: LoginViewControllerDelegate?
	
	// MARK: Views
	
	let tableView = UITableView(frame: CGRect.zero, style: .grouped)
	
	let usernameCell = TextFieldCell(style: .default, reuseIdentifier: nil)
	let passwordCell = TextFieldCell(style: .default, reuseIdentifier: nil)
	
	let signInBarButtonItem = UIBarButtonItem(title: "Sign In", style: .plain, target: nil, action: nil)
	let signingInBarButtonItem = UIBarButtonItem(customView: UIActivityIndicatorView(activityIndicatorStyle: .gray))
	
	// MARK: View life cycle
	
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
		
		updateSignInBarButtonEnabled()
		
		// Cells
		
		usernameCell.label.text = "Username"
		
		usernameCell.textField.placeholder = "hacker@school.edu"
		usernameCell.textField.keyboardType = .emailAddress
		usernameCell.textField.autocorrectionType = .no
		usernameCell.textField.autocapitalizationType = .none
		usernameCell.textField.returnKeyType = .next
		usernameCell.textField.delegate = self
		usernameCell.textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
		
		passwordCell.label.text = "Password"
		
		passwordCell.textField.placeholder = "required"
		passwordCell.textField.isSecureTextEntry = true
		passwordCell.textField.returnKeyType = .done
		passwordCell.textField.delegate = self
		passwordCell.textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
	}
	
	private var firstAppearance = true
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if firstAppearance {
			
			SecRequestSharedWebCredential(nil, nil) { array, error in
				
				DispatchQueue.main.async {
					
					if let array = array as? [[String: String]], let data = array.first {
						
						self.usernameCell.textField.text = data[kSecAttrAccount as String]!
						self.passwordCell.textField.text = data[kSecSharedPassword as String]!
						
						self.login()
						
					} else {
						
						self.usernameCell.textField.becomeFirstResponder()
					}
				}
			}
			
			firstAppearance = false
		}
	}
	
	// MARK: State
	
	enum State {
		case interactive
		case signingIn
		case signedIn
	}
	
	var state = State.interactive {
		didSet {
			
			let isInteractive = state == .interactive
			
			usernameCell.textField.isEnabled = isInteractive
			passwordCell.textField.isEnabled = isInteractive
			
			let activityIndicator = signingInBarButtonItem.customView as! UIActivityIndicatorView
			
			if state == .signingIn {
				activityIndicator.startAnimating()
			} else {
				activityIndicator.stopAnimating()
			}
			
			switch state {
			case .interactive:
				navigationItem.rightBarButtonItem = signInBarButtonItem
			case .signingIn:
				navigationItem.rightBarButtonItem = signingInBarButtonItem
			case .signedIn:
				navigationItem.rightBarButtonItem = nil
			}
		}
	}
	
	func updateSignInBarButtonEnabled() {
		
		if let username = usernameCell.textField.text, let password = passwordCell.textField.text, !username.isEmpty && !password.isEmpty {
			signInBarButtonItem.isEnabled = true
		} else {
			signInBarButtonItem.isEnabled = false
		}
	}
	
	// MARK: Actions
	
	func login(_ sender: UIBarButtonItem? = nil) {
		
		state = .signingIn
		
		let username = usernameCell.textField.text!
		let password = passwordCell.textField.text!
		
		APIManager.shared.loginWithUsername(username, password: password) { response in
			
			DispatchQueue.main.async {
				
				switch response {
				
				case .value(let loggedIn):
					
					if loggedIn {
						
						self.state = .signedIn
						self.delegate?.loginViewControllerDidLogin(loginViewController: self)
						
					} else {
						
						self.state = .interactive
						
						self.passwordCell.textField.placeholder = "incorrect password"
						self.passwordCell.textField.text = nil
						self.passwordCell.textField.becomeFirstResponder()
					}
					
				case .error(let errorMessage):
					
					self.state = .interactive
					
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
	
	func textFieldEditingChanged() {
		
		updateSignInBarButtonEnabled()
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		
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
