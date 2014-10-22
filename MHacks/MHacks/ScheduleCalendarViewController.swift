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
    
    var eventOrganizer = EventOrganizer(events: EventManager().events)
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.registerNib(UINib(nibName: "ScheduleDayHeader", bundle: nil), forSupplementaryViewOfKind: CalendarLayout.SupplementaryViewKind.Header.rawValue, withReuseIdentifier: "DayHeader")
        collectionView.registerNib(UINib(nibName: "ScheduleHourSeparator", bundle: nil), forSupplementaryViewOfKind: CalendarLayout.SupplementaryViewKind.Separator.rawValue, withReuseIdentifier: "HourSeparator")
    }
    
    // MARK: Collection view data source
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return eventOrganizer.numberOfDays()
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventOrganizer.numberOfEventsInDay(section)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EventCell", forIndexPath: indexPath) as ScheduleEventCell
        
        cell.color = collectionView.tintColor
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        switch CalendarLayout.SupplementaryViewKind(rawValue: kind)! {
            
        case .Header:
            let dayHeader = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "DayHeader", forIndexPath: indexPath) as ScheduleDayHeader
            dayHeader.label.text = eventOrganizer.titleForDay(indexPath.section)
            return dayHeader
            
        case .Separator:
            let hourSeparator = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "HourSeparator", forIndexPath: indexPath) as ScheduleHourSeparator
            hourSeparator.label.text = eventOrganizer.titleForHour(indexPath.item, inDay: indexPath.section)
            return hourSeparator
        }
    }
    
    // MARK: Calendar layout delegate
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, numberOfRowsInSection section: Int) -> Int {
        return eventOrganizer.numberOfHoursInDay(section)
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, startRowForItemAtIndexPath indexPath: NSIndexPath) -> Double {
        return eventOrganizer.startHourForEventAtIndex(indexPath.item, inDay: indexPath.section)
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, heightInRowsForItemAtIndexPath indexPath: NSIndexPath) -> Double {
        return eventOrganizer.durationInHoursForEventAtIndex(indexPath.item, inDay: indexPath.section)
    }
}
