//
//  ScheduleCalendarViewController.swift
//  MHacks
//
//  Created by Russell Ladd on 10/4/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class ScheduleCalendarViewController: UICollectionViewController, CalendarLayoutDelegate {
    
    // MARK: Event
    
    var eventOrganizer: EventOrganizer? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.registerNib(UINib(nibName: "ScheduleDayHeader", bundle: nil), forSupplementaryViewOfKind: CalendarLayout.SupplementaryViewKind.Header.rawValue, withReuseIdentifier: "DayHeader")
        collectionView.registerNib(UINib(nibName: "ScheduleHourSeparator", bundle: nil), forSupplementaryViewOfKind: CalendarLayout.SupplementaryViewKind.Separator.rawValue, withReuseIdentifier: "HourSeparator")
        
        let layout = collectionView.collectionViewLayout as CalendarLayout
        layout.cellInsets = UIEdgeInsets(top: 1.0, left: 57.0, bottom: 1.0, right: 1.0)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Event.fetchEvents { result in
            
            switch result {
            case .Success(let events):
                self.eventOrganizer = EventOrganizer(events: events)
            case .Error(let error):
                ()
                // FIXME: Handle error
            }
        }
    }
    
    // MARK: Collection view data source
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return eventOrganizer?.numberOfDays() ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventOrganizer!.numberOfEventsInDay(section)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EventCell", forIndexPath: indexPath) as ScheduleEventCell
        
        let event = eventOrganizer!.eventAtIndex(indexPath.item, inDay: indexPath.section)
        
        cell.color = collectionView.tintColor
        cell.textLabel.text = event.name
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        switch CalendarLayout.SupplementaryViewKind(rawValue: kind)! {
            
        case .Header:
            let dayHeader = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "DayHeader", forIndexPath: indexPath) as ScheduleDayHeader
            dayHeader.label.text = eventOrganizer!.titleForDay(indexPath.section)
            return dayHeader
            
        case .Separator:
            let hourSeparator = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "HourSeparator", forIndexPath: indexPath) as ScheduleHourSeparator
            hourSeparator.label.text = eventOrganizer!.titleForHour(indexPath.item, inDay: indexPath.section)
            return hourSeparator
        }
    }
    
    // MARK: Calendar layout delegate
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, numberOfRowsInSection section: Int) -> Int {
        return eventOrganizer!.numberOfHoursInDay(section)
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, startRowForItemAtIndexPath indexPath: NSIndexPath) -> Double {
        return eventOrganizer!.partialHoursForEventAtIndex(indexPath.item, inDay: indexPath.section).start
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, endRowForItemAtIndexPath indexPath: NSIndexPath) -> Double {
        return eventOrganizer!.partialHoursForEventAtIndex(indexPath.item, inDay: indexPath.section).end
    }
    
    // MARK: Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "Show Event" {
            
            let indexPath = collectionView.indexPathsForSelectedItems()!.first! as NSIndexPath
            
            let viewController = segue.destinationViewController as EventViewController
            viewController.event = eventOrganizer!.eventAtIndex(indexPath.item, inDay: indexPath.section)
        }
    }
}
