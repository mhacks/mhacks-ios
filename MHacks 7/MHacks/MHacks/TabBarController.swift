//
//  TabBarController.swift
//  MHacks
//
//  Created by Manav Gabhawala on 2/1/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController
{
	override func viewDidLoad() {
		super.viewDidLoad()
		selectedIndex = 2 // Set to countdown
	}
	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)
		guard APIManager.sharedManager.isLoggedIn
		else
		{
			performSegueWithIdentifier("loginSegue", sender: nil)
			return
		}
	}
}
