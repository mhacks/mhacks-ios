//
//  Announcement.swift
//  MHacks
//
//  Created by Russell Ladd on 11/18/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation

struct Announcement: Equatable {
    
    let ID: String
    let title: String
    let date: NSDate
    let message: String
    
    static private let todayDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        return formatter;
    }()
    
    static private let otherDayDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.doesRelativeDateFormatting = true;
        return formatter;
    }()
    
    var localizedDate: String {
        let formatter = NSCalendar.currentCalendar().isDateInToday(date) ? Announcement.todayDateFormatter : Announcement.otherDayDateFormatter
        return formatter.stringFromDate(date)
    }
}

extension Announcement: Fetchable {
    
    init?(object: PFObject) {
        
        let title = object["title"] as? String
        let date = object["date"] as? NSDate
        let message = object["message"] as? String
        
        if (title == nil || date == nil || message == nil) {
            return nil
        }
        
        self.ID = object.objectId
        self.title = title!
        self.date = date!
        self.message = message!
    }
}

func ==(lhs: Announcement, rhs: Announcement) -> Bool {
    
    return (lhs.ID == rhs.ID &&
        lhs.title == rhs.title &&
        lhs.date == rhs.date &&
        lhs.message == rhs.message)
}
