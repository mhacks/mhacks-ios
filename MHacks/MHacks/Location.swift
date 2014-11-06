//
//  Location.swift
//  MHacks
//
//  Created by Russell Ladd on 11/5/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation

struct Location {
    
    let name: String
    
    init?(object: PFObject) {
        
        let name = object.objectForKey("name") as? String
        
        if (name == nil) {
            return nil
        }
        
        self.name = name!
    }
}
