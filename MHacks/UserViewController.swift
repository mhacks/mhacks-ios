//
//  UserViewController.swift
//  MHacks
//
//  Created by Russell Ladd on 9/11/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit
import PassKit
import CoreImage

final class UserViewController: UIViewController, LoginViewControllerDelegate, PKAddPassesViewControllerDelegate, ScannerViewControllerDelegate {
    
    // MARK: Views
    
    let signInView = UIStackView()
    let ticketView = UIStackView()
    
    let signInTitleLabel = UILabel()
    let signInDescriptionLabel = UILabel()
    let signInButton = UIButton(type: .system)
    
    let ticketBackgroundView = GradientTintView()
    
    let nameTitleLabel = UILabel()
    let nameLabel = UILabel()
    
    let schoolTitleLabel = UILabel()
    let schoolLabel = UILabel()
    
    let scannableCodeView = UIImageView()
    
    let addPassButton = PKAddPassButton(style: .black)
    
    let userInfo = APIManager.UserInfo(userID: "1234567890", email: "grladd@umich.edu", name: "Russell Ladd", school: "University of Michigan")
    
    let signOutBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Sign Out", comment: "Sign out button title"), style: .plain, target: nil, action: nil)
    let scanBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Scan", comment: "Scan button title"), style: .plain, target: nil, action: nil)
    
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup sign in view
        
        signInTitleLabel.text = NSLocalizedString("My Ticket", comment: "Sign in title")
        signInTitleLabel.textColor = UIColor.gray
        signInTitleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        
        signInDescriptionLabel.textColor = UIColor.lightGray
        signInDescriptionLabel.text = NSLocalizedString("Tickets are only available to registered hackers.", comment: "Sign in description")
        signInDescriptionLabel.numberOfLines = 0
        signInDescriptionLabel.textAlignment = .center
        
        signInButton.setTitle(NSLocalizedString("Sign In", comment: "Sign in button title"), for: .normal)
        signInButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        
        signInView.translatesAutoresizingMaskIntoConstraints = false
        signInView.axis = .vertical
        signInView.spacing = 8.0
        signInView.alignment = .center
        
        signInView.addArrangedSubview(signInTitleLabel)
        signInView.addArrangedSubview(signInDescriptionLabel)
        signInView.addArrangedSubview(signInButton)
        
        // Setup ticket view
        
        signOutBarButtonItem.target = self
        signOutBarButtonItem.action = #selector(signOut)
        
        scanBarButtonItem.target = self
        scanBarButtonItem.action = #selector(scan)
        
        ticketBackgroundView.layer.cornerRadius = 15.0
        
        scannableCodeView.translatesAutoresizingMaskIntoConstraints = false
        scannableCodeView.clipsToBounds = true
        scannableCodeView.layer.cornerRadius = 8.0
        
        nameTitleLabel.text = "HACKER"
        nameTitleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        nameTitleLabel.textColor = UIColor(white: 0.0, alpha: 0.6)
        
        schoolTitleLabel.text = "SCHOOL"
        schoolTitleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        schoolTitleLabel.textColor = UIColor(white: 0.0, alpha: 0.6)
        
        nameLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        nameLabel.textColor = UIColor.white
        
        schoolLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        schoolLabel.textColor = UIColor.white
        
        let schoolView = UIStackView(arrangedSubviews: [nameTitleLabel, nameLabel])
        schoolView.axis = .vertical
        schoolView.alignment = .leading
        
        let emailView = UIStackView(arrangedSubviews: [schoolTitleLabel, schoolLabel])
        emailView.axis = .vertical
        emailView.alignment = .leading
        
        let fieldsView = UIStackView(arrangedSubviews: [schoolView, emailView])
        fieldsView.axis = .vertical
        fieldsView.spacing = 20.0
        
        let ticketItemsView = UIStackView(arrangedSubviews: [fieldsView, scannableCodeView])
        ticketItemsView.translatesAutoresizingMaskIntoConstraints = false
        ticketItemsView.axis = .vertical
        ticketItemsView.alignment = .center
        ticketItemsView.distribution = .equalSpacing
        
        ticketBackgroundView.addSubview(ticketItemsView)
        
        ticketView.translatesAutoresizingMaskIntoConstraints = false
        ticketView.axis = .vertical
        ticketView.spacing = 15.0
        
        ticketView.addArrangedSubview(ticketBackgroundView)
        ticketView.addArrangedSubview(addPassButton)
		
		addPassButton.addTarget(self, action: #selector(addPass(_:)), for: .touchUpInside)
		
        // Setup view
        
        let contentLayoutGuide = UILayoutGuide()
        view.addLayoutGuide(contentLayoutGuide)
        
        view.addSubview(signInView)
        view.addSubview(ticketView)
        
        NSLayoutConstraint.activate([
            contentLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15.0),
            contentLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15.0),
            contentLayoutGuide.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            contentLayoutGuide.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -15.0),
            signInView.centerXAnchor.constraint(equalTo: contentLayoutGuide.centerXAnchor),
            signInView.centerYAnchor.constraint(equalTo: contentLayoutGuide.centerYAnchor),
            signInView.widthAnchor.constraint(equalTo: contentLayoutGuide.widthAnchor, multiplier: 0.75),
            ticketView.leadingAnchor.constraint(equalTo: contentLayoutGuide.leadingAnchor),
            ticketView.trailingAnchor.constraint(equalTo: contentLayoutGuide.trailingAnchor),
            ticketView.topAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
            ticketView.bottomAnchor.constraint(equalTo: contentLayoutGuide.bottomAnchor),
            fieldsView.widthAnchor.constraint(equalTo: ticketItemsView.widthAnchor),
            ticketItemsView.leadingAnchor.constraint(equalTo: ticketBackgroundView.leadingAnchor, constant: 15.0),
            ticketItemsView.trailingAnchor.constraint(equalTo: ticketBackgroundView.trailingAnchor, constant: -15.0),
            ticketItemsView.topAnchor.constraint(equalTo: ticketBackgroundView.topAnchor, constant: 15.0),
            ticketItemsView.bottomAnchor.constraint(equalTo: ticketBackgroundView.bottomAnchor, constant: -15.0),
        ])
        
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(signInDidChange), name: APIManager.LoginStateChangedNotification, object: nil)
        
        updateViews()
        
        APIManager.shared.updateUserProfile()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: APIManager.LoginStateChangedNotification, object: nil)
    }
    
    // MARK: Update views
    
    func updateViews() {
        
        if case .LoggedIn(let user) = APIManager.shared.userState {
            
            navigationItem.leftBarButtonItem = signOutBarButtonItem
            navigationItem.title = "My Ticket"
            
            signInView.isHidden = true
            ticketView.isHidden = false
            
            nameLabel.text = user.name
            schoolLabel.text = user.school ?? "Unknown"
            
        } else {
            
            navigationItem.leftBarButtonItem = nil
            navigationItem.title = nil
            
            signInView.isHidden = false
            ticketView.isHidden = true
        }
        
        if APIManager.shared.canScanUserCode() {
            navigationItem.rightBarButtonItem = scanBarButtonItem
        } else {
            navigationItem.rightBarButtonItem = nil
        }
        
        let userIDData = userInfo.userID.data(using: .isoLatin1)!
        
        let qrCodeGenerator = CIFilter(name: "CIQRCodeGenerator")!
        qrCodeGenerator.setValue(userIDData, forKey: "inputMessage")
        qrCodeGenerator.setValue("H", forKey: "inputCorrectionLevel")
        
        let scaleFilter = CIFilter(name: "CIAffineTransform")!
        scaleFilter.setValue(qrCodeGenerator.outputImage, forKey: "inputImage")
        scaleFilter.setValue(NSValue(cgAffineTransform: CGAffineTransform(scaleX: 8.0, y: 8.0)), forKey: "inputTransform")
        
        scannableCodeView.image = UIImage(ciImage: scaleFilter.outputImage!)
    }
    
    // MARK: Actions
    
    func signIn() {
        
        let loginViewController = LoginViewController()
        loginViewController.delegate = self
        
        let loginNavigationController = UINavigationController(rootViewController: loginViewController)
        
        present(loginNavigationController, animated: true, completion: nil)
    }
    
    func signOut() {
        
        APIManager.shared.logout()
    }
    
    func scan() {
        
        let scannerViewController = ScannerViewController(nibName: nil, bundle: nil)
        scannerViewController.delegate = self
        
        let scannerNavigationController = UINavigationController(rootViewController: scannerViewController)
        scannerNavigationController.isToolbarHidden = false
        
        present(scannerNavigationController, animated: true, completion: nil)
    }
    
    func signInDidChange() {
        
        updateViews()
    }
	
	func addPass(_ sender: PKAddPassButton) {
        
        view.isUserInteractionEnabled = false
        
		APIManager.shared.fetchPass { pass in
            
            self.view.isUserInteractionEnabled = true
            
			guard let pass = pass else {
				// Request failed
				return
			}
            
			let passesViewController = PKAddPassesViewController(pass: pass)
			passesViewController.delegate = self
			self.present(passesViewController, animated: true, completion: nil)
		}
	}
	
    // MARK: Login view controller delegate
    
    func loginViewControllerDidCancel(loginViewController: LoginViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func loginViewControllerDidLogin(loginViewController: LoginViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Add passed view controller delegate
	
	func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
		dismiss(animated: true, completion: nil)
	}
    
    // MARK: Scanner view controller delegate
    
    func scannerViewControllerDidCancel(scannerViewController: ScannerViewController) {
        dismiss(animated: true, completion: nil)
    }
}
