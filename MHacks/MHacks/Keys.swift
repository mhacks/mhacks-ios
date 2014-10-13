//
//  Keys.swift
//  MHacks
//
//  Created by Russell Ladd on 10/13/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation

struct Keys {
    
    static let sharedKeys = Keys()
    
    let parseApplicationID: String
    let parseClientKey: String
    
    private init() {
        
        let dictionary = NSDictionary(contentsOfFile: "Keys")
        
        parseApplicationID = dictionary["ParseApplicationID"] as String
        parseClientKey = dictionary["ParseClientKey"] as String
    }
}
