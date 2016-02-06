//
//  InitialViewController.swift
//  MHacks
//
//  Created by Manav Gabhawala on 2/6/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController
{
	@IBOutlet var webView: UIWebView!
	var timer: NSTimer?
	override func viewDidLoad()
	{
		super.viewDidLoad()
		guard let htmlFile = NSBundle.mainBundle().pathForResource("animation", ofType: "html"), let fileContents = try? String(contentsOfFile: htmlFile)
		else
		{
			return
		}
		webView.loadHTMLString(fileContents, baseURL: nil)
	}
	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)
		timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "finishedAnimation:", userInfo: nil, repeats: false)
	}
	func finishedAnimation(timer: NSTimer)
	{
		performSegueWithIdentifier("startApp", sender: nil)
	}
}