//
//  SettingsViewController.swift
//  MHacks
//
//  Created by Ameya Khare on 2/5/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    var lastStatus: Bool = false
    
    let adminTool = "Announcements Pending Approval"
    var sections:[[String]] = [["Emergency","Logistics","Food","Swag",
        "Sponsor","Other"]]
    var sectionNames = ["Push Notifications"]
    
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 && cell!.textLabel!.text == "Emergency" {
            let alert = UIAlertView(title: "Denied", message: "Emergency notifications must stay active during the entire hackathon", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        
        if cell?.accessoryType != UITableViewCellAccessoryType.Checkmark {
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell?.accessoryType = UITableViewCellAccessoryType.None
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionNames.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionNames[section]
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("notificationTypes")
        cell!.textLabel!.text = sections[indexPath.section][indexPath.row]
        
        return cell!
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return nil
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
