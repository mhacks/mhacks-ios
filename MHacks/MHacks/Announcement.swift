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
}

extension Announcement: Fetchable {
    
    init?(object: PFObject) {
        
        let title = object["title"] as? String
        let date = object["date"] as? NSDate
        let message = object["message"] as? String
        
        if (title == nil || date == nil || message == nil) {
            return nil
        }
        
        self.title = title!
        self.date = date!
        self.message = message!
    }
}
