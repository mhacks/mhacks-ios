//
//  CountdownViewController.swift
//  MHacks
//
//  Created by Russell Ladd on 11/12/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class CountdownViewController: UIViewController {

	@IBOutlet weak var progressIndicator: CircularProgressIndicator!
	@IBOutlet weak var countdownLabel: UILabel!
	@IBOutlet weak var startLabel: UILabel!
	@IBOutlet weak var endLabel: UILabel!
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		countdownLabel.font = Countdown.font
		APIManager.sharedManager.updateCountdown()
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		beginUpdatingCountdownViews()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		NSNotificationCenter.defaultCenter().listenFor(.CountdownUpdated, observer: self, selector: #selector(CountdownViewController.updateCountdownViews(_:)))
		APIManager.sharedManager.updateCountdown()
	}
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		stopUpdatingCountdownViews()
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}

	// MARK: - Model Update
	
	var timer: NSTimer?
	
	func beginUpdatingCountdownViews() {
		
		updateCountdownViews()
		
		let nextSecond = NSCalendar.sharedCalendar.nextDateAfterDate(NSDate(), matchingUnit: .Nanosecond, value: 0, options: .MatchNextTime)!
		
		let timer = NSTimer(fireDate: nextSecond, interval: 1.0, target: self, selector: #selector(CountdownViewController.timerFire(_:)), userInfo: nil, repeats: true)
		
		NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
		
		self.timer = timer
	}
	
	func timerFire(timer: NSTimer) {
		updateCountdownViews()
	}
	
	func stopUpdatingCountdownViews() {
		timer?.invalidate()
		timer = nil
	}
	
	// MARK: - UI Update
	func updateCountdownViews(_: NSNotification? = nil) {
		dispatch_async(dispatch_get_main_queue(), {
			self.progressIndicator.progress = APIManager.sharedManager.countdown.progress
			self.countdownLabel.text = APIManager.sharedManager.countdown.timeRemainingDescription
			
			self.startLabel.text = APIManager.sharedManager.countdown.startDateDescription
			self.endLabel.text = APIManager.sharedManager.countdown.endDateDescription
		})
	}
}

