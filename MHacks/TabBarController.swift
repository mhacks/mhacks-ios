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
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		if launchTo != nil
		{
			willLaunchTo()
		}
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "willLaunchTo:", name: launchToNotification, object: nil)
	}
	func willLaunchTo(_: NSNotification? = nil)
	{
		guard let launcher = launchTo
		else
		{
			return
		}
		switch launcher
		{
		case .Announcement:
			selectedIndex = 3
			launchTo = nil
		case .Event(_):
			if selectedIndex == 0
			{
				(viewControllers?.first as? UINavigationController)?.popToRootViewControllerAnimated(true)
				(viewControllers?.first as? UINavigationController)?.topViewController?.viewWillAppear(true)
			}
			else
			{
				selectedIndex = 0
			}
		}
	}
}
