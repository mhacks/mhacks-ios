//
//  CountdownView.swift
//  MHacks
//
//  Created by Ben Oztalay on 10/13/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class CountdownView: UIView {

    // MARK: Outlets
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: State
    
    var countdownItems: [PFObject]?
    var secondTimer: NSTimer?
    
    // MARK: Init
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let viewsLoaded = NSBundle.mainBundle().loadNibNamed("CountdownView", owner: self, options: nil)
        if viewsLoaded.count > 0 {
            self.addSubview(viewsLoaded[0] as UIView)
        }
    }
    
    override func awakeFromNib() {
        let countdownItemsQuery = PFQuery(className: "CountdownItem")
        countdownItemsQuery.findObjectsInBackgroundWithBlock { objects, error in
            if let error = error {
                println(error)
                return
            }
            
            self.countdownItems = objects as? [PFObject]
            self.countdownItems?.sort() {
                let firstTime = $0["time"] as NSDate
                let secondTime = $1["time"] as NSDate
                return firstTime.compare(secondTime) == NSComparisonResult.OrderedAscending
            }
            
            self.secondTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateTimer:"), userInfo: nil, repeats: true)
            self.secondTimer?.fire()
        }
    }
    
    // MARK: Updating the labels
    
    func updateTimer(timer: NSTimer) {
        if let countdownItems = self.countdownItems {
            let currentDate = NSDate()
            var nextCountdownItem = countdownItems[0]
            
            for countdownItem in countdownItems[1..<countdownItems.count] {
                let nextCountdownItemTime = nextCountdownItem["time"] as NSDate
                let countdownItemTime = countdownItem["time"] as NSDate
                if currentDate.compare(nextCountdownItemTime) == NSComparisonResult.OrderedDescending &&
                    currentDate.compare(countdownItemTime) == NSComparisonResult.OrderedAscending {
                    nextCountdownItem = countdownItem
                }
            }
            
            var secondsUntilNextItem = Int(floor(nextCountdownItem["time"].timeIntervalSinceDate(currentDate)))
            self.updateTimerLabelWithSecondsUntil(secondsUntilNextItem)
            
            self.titleLabel.text = nextCountdownItem["title"] as? String
        }
    }
    
    func updateTimerLabelWithSecondsUntil(secondsUntilNextItem: Int) {
        var secondsUntil = secondsUntilNextItem
        
        var daysUntilString = ""
        let daysUntil = secondsUntil / (60 * 60 * 24)
        if daysUntil > 4 {
            secondsUntil -= daysUntil * (60 * 60 * 24)
            daysUntilString = "\(daysUntil) days"
        }
        
        let hoursUntil = secondsUntil / (60 * 60)
        secondsUntil -= hoursUntil * (60 * 60)
        let minutesUntil = secondsUntil / 60
        secondsUntil -= minutesUntil * 60
        
        let hoursZeroString = (hoursUntil < 10) ? "0" : ""
        let minutesZeroString = (minutesUntil < 10) ? "0" : ""
        let secondsZeroString = (secondsUntil < 10) ? "0" : ""
        
        self.timeLabel.text = "\(daysUntilString) \(hoursZeroString)\(hoursUntil):\(minutesZeroString)\(minutesUntil):\(secondsZeroString)\(secondsUntil)"
    }
}
