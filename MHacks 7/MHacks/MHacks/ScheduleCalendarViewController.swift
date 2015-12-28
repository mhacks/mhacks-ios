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
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.registerNib(UINib(nibName: "ScheduleDayHeader", bundle: nil), forSupplementaryViewOfKind: CalendarLayout.SupplementaryViewKind.Header.rawValue, withReuseIdentifier: "DayHeader")
        collectionView.registerNib(UINib(nibName: "ScheduleHourSeparator", bundle: nil), forSupplementaryViewOfKind: CalendarLayout.SupplementaryViewKind.Separator.rawValue, withReuseIdentifier: "HourSeparator")
        
        let layout = collectionView.collectionViewLayout as! CalendarLayout
        layout.rowInsets = UIEdgeInsets(top: 0.0, left: 52.0, bottom: 0.0, right: 0.0)
		APIManager.sharedManager.updateEvents()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let indexPath = collectionView.indexPathsForSelectedItems()?.first
		else
		{
			return
		}
        transitionCoordinator()?.animateAlongsideTransition({ context in
            
            self.collectionView.deselectItemAtIndexPath(indexPath, animated: animated)
            
            }, completion: { context in
                
                if context.isCancelled() {
                    self.collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
                }
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        APIManager.sharedManager.updateEvents()
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventsUpdated:", name: APIManager.eventsUpdatedNotification, object: nil)
    }
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	func eventsUpdated(notification: NSNotification) {
		 collectionView?.reloadData()
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
        
		//        cell.color = event.category.color // TODO: Implement category at some point
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
    
    // MARK: Segues
    
    func showDetailsForEventWithID(ID: String) {
		
		
        if let (day, index) = APIManager.sharedManager.eventsOrganizer.findDayAndIndexForEventWithID(ID) {
            
            collectionView.selectItemAtIndexPath(NSIndexPath(forItem: index, inSection: day), animated: false, scrollPosition: .CenteredVertically)
            // FIXME: Implement in a better way 
			// Use navigation View controller push view controller
//            performSegueWithIdentifier("Show Event", sender: nil)
        }
    }    
}
