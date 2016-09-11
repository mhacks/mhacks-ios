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
    
    @IBOutlet fileprivate var collectionView: UICollectionView!
	@IBOutlet fileprivate var calendarLayout: CalendarLayout!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: "ScheduleDayHeader", bundle: nil), forSupplementaryViewOfKind: CalendarLayout.SupplementaryViewKind.Header.rawValue, withReuseIdentifier: "DayHeader")
        collectionView.register(UINib(nibName: "ScheduleHourSeparator", bundle: nil), forSupplementaryViewOfKind: CalendarLayout.SupplementaryViewKind.Separator.rawValue, withReuseIdentifier: "HourSeparator")
		collectionView.register(UINib(nibName: "ScheduleNowIndicator", bundle: nil), forSupplementaryViewOfKind: CalendarLayout.SupplementaryViewKind.NowIndicator.rawValue, withReuseIdentifier: "NowIndicator")
		collectionView.register(UINib(nibName: "ScheduleNowLabel", bundle: nil), forSupplementaryViewOfKind: CalendarLayout.SupplementaryViewKind.NowLabel.rawValue, withReuseIdentifier: "NowLabel")
		
        let layout = collectionView.collectionViewLayout as! CalendarLayout
        layout.rowInsets = UIEdgeInsets(top: 0.0, left: 62.0, bottom: 0.0, right: 0.0)
		
		APIManager.shared.updateEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		
		NotificationCenter.default.addObserver(self, selector: #selector(ScheduleCalendarViewController.eventsUpdated(_:)), name: APIManager.EventsUpdatedNotification, object: nil)
		APIManager.shared.updateEvents()
		
		if let indexPath = collectionView.indexPathsForSelectedItems?.first {
			
			transitionCoordinator?.animate(alongsideTransition: { context in
				self.collectionView.deselectItem(at: indexPath, animated: animated)
			}, completion: { context in
				if context.isCancelled {
					self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
				}
			})
		}
		
		beginUpdatingNowIndicatorPosition()
    }
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		NotificationCenter.default.removeObserver(self)
		
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
	
	func eventsUpdated(_ notification: Notification) {
		
		DispatchQueue.main.async {
			
			if self.isViewLoaded {
				self.collectionView.reloadData()
				self.updateNowIndicator()
				self.scrollToNowIfNeeded()
			}
		}
	}
	
	// MARK: Now indicator
	
	var timer: Timer?
	
	func beginUpdatingNowIndicatorPosition() {
		
		let nextSecond = (Calendar.shared as NSCalendar).nextDate(after: Date(), matching: .second, value: 0, options: .matchNextTime)!
		
		let timer = Timer(fireAt: nextSecond, interval: 1.0, target: self, selector: #selector(ScheduleCalendarViewController.timerFire(_:)), userInfo: nil, repeats: true)
		
		RunLoop.main.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
		
		self.timer = timer
	}
	
	func timerFire(_ timer: Timer) {
		
		updateNowIndicator()
	}
	
	func stopUpdatingNowIndicatorPosition() {
		
		timer?.invalidate()
		timer = nil
	}
	
	func updateNowIndicator() {
		#if DEBUG
			var components = (Calendar.shared as NSCalendar).components([.hour, .minute, .second], from: Date())
			components.year = 2016
			components.month = 10
			components.day = 8
			let date = Calendar.shared.date(from: components)!
		#else
			let date = Date()
		#endif
		
		
		if let (day, partialHour) = APIManager.shared.eventsOrganizer.dayAndPartialHourForDate(date) {
			calendarLayout.nowIndicatorPosition = (day, partialHour)
		} else {
			calendarLayout.nowIndicatorPosition = nil
		}
		
		if let nowLabel = collectionView.supplementaryView(forElementKind: CalendarLayout.SupplementaryViewKind.NowLabel.rawValue, at: IndexPath(item: 0, section: 0)) as? ScheduleNowLabel {
			nowLabel.label.text = Hour.minuteFormatter.string(from: Date())
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
		return collectionView.numberOfSections != 0
	}
	
	func scrollToNow() {
		
		guard canScrollToNow else {
			return
		}
		
		let midY = collectionView.layoutAttributesForSupplementaryElement(ofKind: CalendarLayout.SupplementaryViewKind.NowIndicator.rawValue, at: IndexPath(item: 0, section: 0))!.frame.midY
		
		let visibleHeight = UIEdgeInsetsInsetRect(collectionView.bounds, collectionView.contentInset).height
		
		let y = midY - (visibleHeight / 2.0)
		
		let contentRect = CGRect(origin: CGPoint.zero, size: collectionView.contentSize)
		
		let rect = CGRect(x: 0.0, y: y, width: collectionView.bounds.width, height: visibleHeight).intersection(contentRect)
			
		collectionView.scrollRectToVisible(rect, animated: false)
	}
	
    // MARK: Collection view data source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return APIManager.shared.eventsOrganizer.days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return APIManager.shared.eventsOrganizer.numberOfEventsInDay(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCell", for: indexPath) as! ScheduleEventCell
        
        let event = APIManager.shared.eventsOrganizer.eventAtIndex((indexPath as NSIndexPath).item, inDay: (indexPath as NSIndexPath).section)
		cell.color = event.category.color
        cell.textLabel.text = event.name
        cell.detailTextLabel.text = event.locationsDescription
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch CalendarLayout.SupplementaryViewKind(rawValue: kind)! {
            
        case .Header:
            let dayHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DayHeader", for: indexPath) as! ScheduleDayHeader
            dayHeader.textLabel.text = APIManager.shared.eventsOrganizer.days[(indexPath as NSIndexPath).section].weekdayTitle
            dayHeader.detailTextLabel.text = APIManager.shared.eventsOrganizer.days[(indexPath as NSIndexPath).section].dateTitle
            return dayHeader
            
        case .Separator:
            let hourSeparator = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HourSeparator", for: indexPath) as! ScheduleHourSeparator
            hourSeparator.label.text = APIManager.shared.eventsOrganizer.days[(indexPath as NSIndexPath).section].hours[(indexPath as NSIndexPath).item].title
            return hourSeparator
			
		case .NowIndicator:
			return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "NowIndicator", for: indexPath) as! ScheduleNowIndicator
			
		case .NowLabel:
			let nowLabel = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "NowLabel", for: indexPath) as! ScheduleNowLabel
			nowLabel.label.text = Hour.minuteFormatter.string(from: Date())
			return nowLabel
        }
    }
	
    // MARK: Calendar layout delegate
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, numberOfRowsInSection section: Int) -> Int {
        return APIManager.shared.eventsOrganizer.days[section].hours.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, startRowForItemAtIndexPath indexPath: IndexPath) -> Double {
        return APIManager.shared.eventsOrganizer.partialHoursForEventAtIndex((indexPath as NSIndexPath).item, inDay: (indexPath as NSIndexPath).section).lowerBound
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, endRowForItemAtIndexPath indexPath: IndexPath) -> Double {
        return APIManager.shared.eventsOrganizer.partialHoursForEventAtIndex((indexPath as NSIndexPath).item, inDay: (indexPath as NSIndexPath).section).upperBound
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, numberOfColumnsForItemAtIndexPath indexPath: IndexPath) -> Int {
        return APIManager.shared.eventsOrganizer.numberOfColumnsForEventAtIndex((indexPath as NSIndexPath).item, inDay: (indexPath as NSIndexPath).section)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, columnForItemAtIndexPath indexPath: IndexPath) -> Int {
        return APIManager.shared.eventsOrganizer.columnForEventAtIndex((indexPath as NSIndexPath).item, inDay: (indexPath as NSIndexPath).section)
    }
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		showDetailsForEvent(APIManager.shared.eventsOrganizer.eventAtIndex((indexPath as NSIndexPath).row, inDay: (indexPath as NSIndexPath).section))
	}
	
    // MARK: Segues
	
	func showDetailsForEvent(_ event: Event) {
		
		let eventViewController = storyboard!.instantiateViewController(withIdentifier: "EventViewController") as! EventViewController
		eventViewController.event = event
		show(eventViewController, sender: nil)
	}
}
