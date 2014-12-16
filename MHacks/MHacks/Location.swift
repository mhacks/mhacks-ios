//
//  Location.swift
//  MHacks
//
//  Created by Russell Ladd on 11/5/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation

struct Location {
    
    let ID: String
    let name: String
}

extension Location: Fetchable {
    
    init?(object: PFObject) {
        
        let name = object.objectForKey("name") as? String
        
        if (name == nil) {
            return nil
        }
        
        self.ID = object.objectId
        self.name = name!
    }
}

func ==(lhs: Location, rhs: Location) -> Bool {
    
    return (lhs.ID == rhs.ID &&
        lhs.name == rhs.name)
}
