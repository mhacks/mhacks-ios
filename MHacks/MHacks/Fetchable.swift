//
//  Fetch.swift
//  MHacks
//
//  Created by Russell Ladd on 11/18/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation

protocol Fetchable {
    
    init?(object: PFObject)
}

extension PFQuery {
    
    func fetch<T: Fetchable>(completionHandler: ([T]?) -> Void) {
        
        findObjectsInBackgroundWithBlock { objects, error in
            
            if let objects = objects as? [PFObject] {
                
                let structures: [T] = objects.map { T(object: $0 ) }.filter { $0 != nil }.map { $0! }
                
                completionHandler(structures)
                
            } else {
                
                completionHandler(nil)
            }
        }
    }
}
