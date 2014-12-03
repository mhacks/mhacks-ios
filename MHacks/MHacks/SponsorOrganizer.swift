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
        
        // Tier
        
        tiers = sorted(sponsors.reduce([]) { tiers, sponsor in
            return tiers + (find(tiers, sponsor.tier) == nil ? [sponsor.tier] : [])
        })
        
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
