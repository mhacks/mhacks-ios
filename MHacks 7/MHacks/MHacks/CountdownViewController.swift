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
	
	// Ideally this is atomic (or better yet a semaphore), but usually we will only use it on the main queue which is serial so its not a problem
	private var updatingCountdown = false
	
	var countdown: Countdown = Countdown() {
		didSet {
			updateCountdownViews()
		}
	}

	var timer: NSTimer!
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		countdownLabel.font = Countdown.font
		updateCountdown()
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		startTimer()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		updateCountdown()
	}
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		stopTimer()
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
	
	func updateCountdown() {
		
		guard !updatingCountdown
		else
		{
			return
		}
		updatingCountdown = true
		APIManager.sharedManager.taskWithRoute("/v1/countdown", completion: { (result: Either<Countdown>) in
			defer { self.updatingCountdown = false }
			switch result
			{
			case .Value(let counter):
				self.countdown = counter
			case .NetworkingError(_):
				fallthrough
			case .UnknownError:
				// TODO: Use cache instead of object fetched from network.
				break // Remove break, only added so that the compiler stays happy.
			}
		})
	}
	
	// MARK: - UI Update
	func updateCountdownViews() {
		
		progressIndicator.progress = countdown.progress
		countdownLabel.text = countdown.timeRemainingDescription
		
		startLabel.text = countdown.startDateDescription
		endLabel.text = countdown.endDateDescription
	}
}

