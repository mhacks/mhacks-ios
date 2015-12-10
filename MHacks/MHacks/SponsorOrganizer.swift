//
//  SponsorOrganizer.swift
//  MHacks
//
//  Created by Russell Ladd on 12/3/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation

struct SponsorOrganizer {
    
    // MARK: Initialization
    
    init(sponsors: [Sponsor]) {
        
        // Sorting
        
        let sponsors = sponsors.sort()
        
        // Tier
        
        tiers = sponsors.reduce([]) { tiers, sponsor in
            return tiers + (tiers.indexOf(sponsor.tier) == nil ? [sponsor.tier] : [])
        }.sort()
        
        // Sponsors
        
        self.sponsors = tiers.map { tier in
            return sponsors.filter { sponsor in
                return sponsor.tier == tier
            }
        }
    }
    
    // MARK: Sponsors and tiers
    
    let sponsors: [[Sponsor]]
    let tiers: [Sponsor.Tier]
}
