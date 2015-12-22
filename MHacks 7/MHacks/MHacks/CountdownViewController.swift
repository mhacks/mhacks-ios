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
	
	var timer: NSTimer!
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		countdownLabel.font = Countdown.font
		APIManager.sharedManager.updateCountdown()
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		startTimer()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCountdownViews:", name: APIManager.countdownUpdateNotification, object: nil)
		APIManager.sharedManager.updateCountdown()
	}
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		stopTimer()
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}

	// MARK: - Model Update
	func startTimer() {
		
		let nextSecond = NSCalendar.currentCalendar().nextDateAfterDate(NSDate(), matchingUnit: .Nanosecond, value: 0, options: .MatchNextTime)!
		
		timer = NSTimer(fireDate: nextSecond, interval: 1.0, target: self, selector: "timerFire:", userInfo: nil, repeats: true)
		
		NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
	}
	
	func timerFire(timer: NSTimer) {
		updateCountdownViews()
	}
	
	func stopTimer() {
		timer.invalidate()
		timer = nil
	}
	
	// MARK: - UI Update
	func updateCountdownViews(_: NSNotification? = nil) {
		let countdown = APIManager.sharedManager.countdown
		
		progressIndicator.progress = countdown.progress
		countdownLabel.text = countdown.timeRemainingDescription
		
		startLabel.text = countdown.startDateDescription
		endLabel.text = countdown.endDateDescription
	}
}

