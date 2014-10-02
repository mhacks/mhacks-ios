//
//  ScheduleViewController.swift
//  MHacks
//
//  Created by Russell Ladd on 9/30/14.
//  Copyright (c) 2014 GRL5. All rights reserved.
//

import UIKit

class ScheduleViewController: UITableViewController {
    
    // MARK: - Model
    
    let eventManager = EventManager()
    
    // MARK: - Date interval formatter
    
    let dateIntervalFormatter: NSDateIntervalFormatter = {
        
        let formatter = NSDateIntervalFormatter()
        
        formatter.dateStyle = .NoStyle
        
        return formatter
    }()
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return eventManager.events.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Event Cell", forIndexPath: indexPath) as UITableViewCell
        
        let event = eventManager.events[indexPath.row]
        
        let interval = dateIntervalFormatter.stringFromDate(event.startDate, toDate: event.endDate)
        
        let darkGrayAttributes = [NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        let subtitle = NSMutableAttributedString(string: interval, attributes: darkGrayAttributes)
        
        let grayAttributes = [NSForegroundColorAttributeName: UIColor.grayColor()]
        subtitle.appendAttributedString(NSAttributedString(string: " – " + event.location, attributes: grayAttributes))
        
        cell.textLabel!.text = event.name
        cell.detailTextLabel!.attributedText = subtitle
        
        return cell;
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showEvent" {
            
            let controller = segue.destinationViewController as EventViewController
            
            let selectedEvent = eventManager.events[tableView.indexPathForSelectedRow()!.row]
            
            controller.event = selectedEvent
        }
    }
}
