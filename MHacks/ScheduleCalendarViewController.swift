//
//  ScheduleCalendarViewController.swift
//  MHacks
//
//  Created by Russell Ladd on 10/4/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class ScheduleCalendarViewController: UIViewController, CalendarLayoutDelegate, UICollectionViewDataSource {
	
    // MARK: View
    
    @IBOutlet private var collectionView: UICollectionView!
	@IBOutlet private var calendarLayout: CalendarLayout!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.registerNib(UINib(nibName: "ScheduleDayHeader", bundle: nil), forSupplementaryViewOfKind: CalendarLayout.SupplementaryViewKind.Header.rawValue, withReuseIdentifier: "DayHeader")
        collectionView.registerNib(UINib(nibName: "ScheduleHourSeparator", bundle: nil), forSupplementaryViewOfKind: CalendarLayout.SupplementaryViewKind.Separator.rawValue, withReuseIdentifier: "HourSeparator")
		collectionView.registerNib(UINib(nibName: "ScheduleNowIndicator", bundle: nil), forSupplementaryViewOfKind: CalendarLayout.SupplementaryViewKind.NowIndicator.rawValue, withReuseIdentifier: "NowIndicator")
		collectionView.registerNib(UINib(nibName: "ScheduleNowLabel", bundle: nil), forSupplementaryViewOfKind: CalendarLayout.SupplementaryViewKind.NowLabel.rawValue, withReuseIdentifier: "NowLabel")
		
        let layout = collectionView.collectionViewLayout as! CalendarLayout
        layout.rowInsets = UIEdgeInsets(top: 0.0, left: 62.0, bottom: 0.0, right: 0.0)
		
		APIManager.sharedManager.updateEvents()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
		
		APIManager.sharedManager.updateEvents()
		NSNotificationCenter.defaultCenter().listenFor(.EventsUpdated, observer: self, selector: #selector(ScheduleCalendarViewController.eventsUpdated(_:)))
		
		if let indexPath = collectionView.indexPathsForSelectedItems()?.first {
			
			transitionCoordinator()?.animateAlongsideTransition({ context in
				self.collectionView.deselectItemAtIndexPath(indexPath, animated: animated)
			}, completion: { context in
				if context.isCancelled() {
					self.collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
				}
			})
		}
		
		beginUpdatingNowIndicatorPosition()
    }
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		
		NSNotificationCenter.defaultCenter().removeObserver(self)
		
		stopUpdatingNowIndicatorPosition()
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		updateNowIndicator()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		scrollToNowIfNeeded()
	}
	
	// MARK: Model
	
	func eventsUpdated(notification: NSNotification) {
		
		dispatch_async(dispatch_get_main_queue()) {
			
			if self.isViewLoaded() {
				self.collectionView.reloadData()
				self.updateNowIndicator()
				self.scrollToNowIfNeeded()
			}
		}
	}
	
	// MARK: Now indicator
	
	var timer: NSTimer?
	
	func beginUpdatingNowIndicatorPosition() {
		
		let nextSecond = NSCalendar.sharedCalendar.nextDateAfterDate(NSDate(), matchingUnit: .Second, value: 0, options: .MatchNextTime)!
		
		let timer = NSTimer(fireDate: nextSecond, interval: 1.0, target: self, selector: #selector(ScheduleCalendarViewController.timerFire(_:)), userInfo: nil, repeats: true)
		
		NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSDefaultRunLoopMode)
		
		self.timer = timer
	}
	
	func timerFire(timer: NSTimer) {
		
		updateNowIndicator()
	}
	
	func stopUpdatingNowIndicatorPosition() {
		
		timer?.invalidate()
		timer = nil
	}
	
	func updateNowIndicator() {
		
		// For debugging - change to just NSDate() for release
		let components = NSCalendar.sharedCalendar.components([.Hour, .Minute, .Second], fromDate: NSDate())
		components.year = 2016
		components.month = 2
		components.day = 20
		
		let date = NSCalendar.sharedCalendar.dateFromComponents(components)!
		
		if let (day, partialHour) = APIManager.sharedManager.eventsOrganizer.dayAndPartialHourForDate(date) {
			calendarLayout.nowIndicatorPosition = (day, partialHour)
		} else {
			calendarLayout.nowIndicatorPosition = nil
		}
		
		if let nowLabel = collectionView.supplementaryViewForElementKind(CalendarLayout.SupplementaryViewKind.NowLabel.rawValue, atIndexPath: NSIndexPath(forItem: 0, inSection: 0)) as? ScheduleNowLabel {
			nowLabel.label.text = Hour.minuteFormatter.stringFromDate(NSDate())
		}
	}
	
	var shouldScrollToNow = true
	
	func scrollToNowIfNeeded() {
		
		guard shouldScrollToNow else {
			return
		}
	
		updateNowIndicator()
		collectionView.layoutIfNeeded()
	
		if canScrollToNow {

			scrollToNow()
	
			shouldScrollToNow = false
		}
	}
	
	var canScrollToNow: Bool {
		return collectionView.numberOfSections() != 0
	}
	
	func scrollToNow() {
		
		guard canScrollToNow else {
			return
		}
		
		let midY = collectionView.layoutAttributesForSupplementaryElementOfKind(CalendarLayout.SupplementaryViewKind.NowIndicator.rawValue, atIndexPath: NSIndexPath(forItem: 0, inSection: 0))!.frame.midY
		
		let visibleHeight = UIEdgeInsetsInsetRect(collectionView.bounds, collectionView.contentInset).height
		
		let y = midY - (visibleHeight / 2.0)
		
		let contentRect = CGRect(origin: CGPointZero, size: collectionView.contentSize)
		
		let rect = CGRect(x: 0.0, y: y, width: collectionView.bounds.width, height: visibleHeight).intersect(contentRect)
			
		collectionView.scrollRectToVisible(rect, animated: false)
	}
	
    // MARK: Collection view data source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return APIManager.sharedManager.eventsOrganizer.days.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return APIManager.sharedManager.eventsOrganizer.numberOfEventsInDay(section)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EventCell", forIndexPath: indexPath) as! ScheduleEventCell
        
        let event = APIManager.sharedManager.eventsOrganizer.eventAtIndex(indexPath.item, inDay: indexPath.section)
		cell.color = event.category.color
        cell.textLabel.text = event.name
        cell.detailTextLabel.text = event.locationsDescription
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        switch CalendarLayout.SupplementaryViewKind(rawValue: kind)! {
            
        case .Header:
            let dayHeader = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "DayHeader", forIndexPath: indexPath) as! ScheduleDayHeader
            dayHeader.textLabel.text = APIManager.sharedManager.eventsOrganizer.days[indexPath.section].weekdayTitle
            dayHeader.detailTextLabel.text = APIManager.sharedManager.eventsOrganizer.days[indexPath.section].dateTitle
            return dayHeader
            
        case .Separator:
            let hourSeparator = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "HourSeparator", forIndexPath: indexPath) as! ScheduleHourSeparator
            hourSeparator.label.text = APIManager.sharedManager.eventsOrganizer.days[indexPath.section].hours[indexPath.item].title
            return hourSeparator
			
		case .NowIndicator:
			return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "NowIndicator", forIndexPath: indexPath) as! ScheduleNowIndicator
			
		case .NowLabel:
			let nowLabel = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "NowLabel", forIndexPath: indexPath) as! ScheduleNowLabel
			nowLabel.label.text = Hour.minuteFormatter.stringFromDate(NSDate())
			return nowLabel
        }
    }
	
    // MARK: Calendar layout delegate
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, numberOfRowsInSection section: Int) -> Int {
        return APIManager.sharedManager.eventsOrganizer.days[section].hours.count
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, startRowForItemAtIndexPath indexPath: NSIndexPath) -> Double {
        return APIManager.sharedManager.eventsOrganizer.partialHoursForEventAtIndex(indexPath.item, inDay: indexPath.section).start
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, endRowForItemAtIndexPath indexPath: NSIndexPath) -> Double {
        return APIManager.sharedManager.eventsOrganizer.partialHoursForEventAtIndex(indexPath.item, inDay: indexPath.section).end
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, numberOfColumnsForItemAtIndexPath indexPath: NSIndexPath) -> Int {
        return APIManager.sharedManager.eventsOrganizer.numberOfColumnsForEventAtIndex(indexPath.item, inDay: indexPath.section)
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, columnForItemAtIndexPath indexPath: NSIndexPath) -> Int {
        return APIManager.sharedManager.eventsOrganizer.columnForEventAtIndex(indexPath.item, inDay: indexPath.section)
    }
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		showDetailsForEvent(APIManager.sharedManager.eventsOrganizer.eventAtIndex(indexPath.row, inDay: indexPath.section))
	}
	
    // MARK: Segues
	
	func showDetailsForEvent(event: Event) {
		
		let eventViewController = storyboard!.instantiateViewControllerWithIdentifier("EventViewController") as! EventViewController
		eventViewController.event = event
		showViewController(eventViewController, sender: nil)
	}
}
