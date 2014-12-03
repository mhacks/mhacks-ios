//
//  Sponsor.swift
//  MHacks
//
//  Created by Russell Ladd on 11/24/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation

struct Sponsor {
    
    let name: String
    let description: String
    let website: String
    let tier: Tier
    let location: Location
    
    private let logoFile: PFFile
    
    private(set) var logo: UIImage?
    
    mutating func fetchLogo() {
        logoFile.getDataInBackgroundWithBlock { data, error in
            
            if data != nil {
                self.logo = UIImage(data: data) ?? UIImage()
            }
        }
    }
    
    mutating func evictLogo() {
        logo = nil
    }
    
    struct Tier {
        
        let name: String
        let level: Int
    }
}

extension Sponsor: Fetchable {
    
    init?(object: PFObject) {
        
        let name = object["name"] as? String
        let description = object["description"] as? String
        let website = object["website"] as? String
        let tierObject = object["tier"] as? PFObject
        let locationObject = object["location"] as? PFObject
        let logoFile = object["logo"] as? PFFile
        
        if name == nil || description == nil || website == nil || tierObject == nil || locationObject == nil || logoFile == nil {
            return nil
        }
        
        let tier = Tier(object: tierObject!)
        let location = Location(object: locationObject!)
        
        if (tier == nil || location == nil) {
            return nil
        }
        
        self.name = name!
        self.description = description!
        self.website = website!
        self.tier = tier!
        self.location = location!
        self.logoFile = logoFile!
    }
}

extension Sponsor.Tier: Fetchable {
    
    init?(object: PFObject) {
        
        let name = object["name"] as? String
        let level = (object["level"] as? NSNumber)?.integerValue
        
        if (name == nil || level == nil) {
            return nil
        }
        
        self.name = name!
        self.level = level!
    }
}
