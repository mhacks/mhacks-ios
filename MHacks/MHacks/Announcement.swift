//
//  Announcement.swift
//  MHacks
//
//  Created by Russell Ladd on 11/18/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation

struct Announcement {
    
    let title: String
    let date: NSDate
    let message: String
    
    init?(object: PFObject) {
        
        let title = object["title"] as? String
        let date = object["time"] as? NSDate
        let message = object["message"] as? String
        
        if (title == nil || date == nil || message == nil) {
            return nil
        }
        
        self.title = title!
        self.date = date!
        self.message = message!
    }
    
    static func fetchAnnouncements(completionHandler: ([Announcement]?) -> Void) {
        
        let query = PFQuery(className: "Announcement")
        
        query.orderByDescending("time")
        
        query.findObjectsInBackgroundWithBlock { objects, error in
            
            if let objects = objects as? [PFObject] {
                
                let announcements: [Announcement] = objects.map { Announcement(object: $0 ) }.filter { $0 != nil }.map { $0! }
                
                completionHandler(announcements)
                
            } else {
                
                completionHandler(nil)
            }
        }
    }
}
