//
//  CountdownViewController.swift
//  MHacks
//
//  Created by Russell Ladd on 11/12/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class CountdownViewController: UIViewController {
    
    // MARK: Model
    
    var countdown: Countdown? {
        didSet {
            updateCountdownLabel()
        }
    }
    
    var timer: NSTimer!
    
    func startTimer() {
        
        let nextSecond = NSCalendar.currentCalendar().nextDateAfterDate(NSDate(), matchingUnit: .CalendarUnitNanosecond, value: 0, options: .MatchNextTime)!
        
        timer = NSTimer(fireDate: nextSecond, interval: 1.0, target: self, selector: "timerFire:", userInfo: nil, repeats: true)
        
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
    }
    
    func timerFire(timer: NSTimer) {
        updateCountdownLabel()
    }
    
    func stopTimer() {
        timer.invalidate()
        timer = nil
    }
    
    // MARK: View
    
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countdown = Countdown.currentCountdown()
        
        updateCountdownLabel()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        startTimer()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Countdown.fetchCountdown { countdown in
            self.countdown = countdown
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopTimer()
    }
    
    func updateCountdownLabel() {
        countdownLabel.text = countdown?.localizedTimeRemaining ?? "36:00:00"
    }
}
