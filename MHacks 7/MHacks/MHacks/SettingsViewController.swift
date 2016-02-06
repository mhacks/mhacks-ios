//
//  SettingsViewController.swift
//  MHacks
//
//  Created by Ameya Khare on 2/5/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    var lastStatus: Bool = false
    
    override func viewDidLoad () {
        lastStatus = APIManager.sharedManager.isLoggedIn
        
        if APIManager.sharedManager.isLoggedIn {
            self.navigationItem.rightBarButtonItem!.title = "Logout"
        } else {
            self.navigationItem.rightBarButtonItem!.title = "Login"
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if !lastStatus && APIManager.sharedManager.isLoggedIn {
         
            // TODO: add any stuff pending approval (if has privilege)
            // TODO: add any set preferences, activate appropriate cells
            
            print("I detected a login state change")
            self.navigationItem.rightBarButtonItem!.title = "Logout"
            lastStatus = true
        }
    }
    
    @IBAction func changeLoginStatus (sender: UIEvent) {
        if APIManager.sharedManager.isLoggedIn {
            APIManager.sharedManager.logout()
            // TODO: remove any stuff in pending approval
            // TODO: remove any set preferences, activate all cells
            print("I detected a logout state change")
            self.navigationItem.rightBarButtonItem!.title = "Login"
            lastStatus = false
        } else {
            performSegueWithIdentifier("changeLoginStatusSegue", sender: nil)
        }
    }
}
