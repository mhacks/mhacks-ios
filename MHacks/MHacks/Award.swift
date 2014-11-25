
//
//  Award.swift
//  MHacks
//
//  Created by Colin Szechy on 11/19/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation

struct Award {
    
    let description: String;
    let prize: Int;
    //sponsor (we'll just store name for visibility until maybe a Sponsor struct arises)
    let sponsor: String;
    let title: String;
    let value: Int;
    let website: String;
    
}

extension Award: Fetchable {
    
    init?(object: PFObject) {
        println(object);
        let description = object["description"] as? String
        let prize = object["prize"] as? Int
        let sponsor = object["sponsor"] as? String;
        let title = object["title"] as? String;
        let value = object["value"] as? Int;
        let website = object["website"] as? String;
        
        if (description == nil || prize == nil || title == nil
                || value == nil || website == nil ) {
            return nil
        }
        
        self.description = description!
        self.prize = prize!
        self.sponsor = sponsor!
        self.title = title!
        self.value = value!
        self.website = website!
    }
    
}