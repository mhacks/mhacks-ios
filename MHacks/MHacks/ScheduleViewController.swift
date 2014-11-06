//
//  ScheduleViewController.swift
//  MHacks
//
//  Created by Russell Ladd on 9/30/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class ScheduleViewController: UITableViewController {
    
    // MARK: - Model
    
    let eventOrganizer = EventOrganizer(events: [])
    
    // MARK: - Formatters
    
    let eventIntervalFormatter: NSDateIntervalFormatter = {
        
        let formatter = NSDateIntervalFormatter()
        
        formatter.dateTemplate = "h:mm a"
        
        return formatter
    }()
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return eventOrganizer.numberOfDays()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventOrganizer.numberOfEventsInDay(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Event Cell", forIndexPath: indexPath) as UITableViewCell
        
        let event = eventOrganizer.eventAtIndex(indexPath.row, inDay: indexPath.section)
        
        let interval = eventIntervalFormatter.stringFromDate(event.startDate, toDate: event.endDate)
        
        let darkGrayAttributes = [NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        let subtitle = NSMutableAttributedString(string: interval, attributes: darkGrayAttributes)
        
        let grayAttributes = [NSForegroundColorAttributeName: UIColor.grayColor()]
        subtitle.appendAttributedString(NSAttributedString(string: " – " + event.locationsDescription, attributes: grayAttributes))
        
        cell.textLabel.text = event.name
        cell.detailTextLabel!.attributedText = subtitle
        
        return cell;
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return eventOrganizer.titleForDay(section)
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showEvent" {
            
            let controller = segue.destinationViewController as EventViewController
            
            let indexPath = tableView.indexPathForSelectedRow()!
            
            let selectedEvent = eventOrganizer.eventAtIndex(indexPath.row, inDay: indexPath.section)
            
            controller.event = selectedEvent
        }
    }
}
