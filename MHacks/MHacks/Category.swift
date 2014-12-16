//
//  Category.swift
//  MHacks
//
//  Created by Russell Ladd on 11/5/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import Foundation

struct Category {
    
    enum Color: Int {
        case Red = 0
        case Green = 1
        case Blue = 2
        
        var color: UIColor {
            switch self {
            case .Red:
                return UIColor.redColor()
            case .Green:
                return UIColor.greenColor()
            case .Blue:
                return UIColor.blueColor()
            }
        }
    }
    
    let ID: String
    let title: String
    let color: Color
}

extension Category: Fetchable {
    
    init?(object: PFObject) {
        
        let title = object.objectForKey("title") as? String
        let colorNumber = object.objectForKey("color") as? NSNumber
        
        if (title == nil || colorNumber == nil) {
            return nil
        }
        
        self.ID = object.objectId
        self.title = title!
        self.color = Color(rawValue: colorNumber!.integerValue) ?? .Red
    }
}

func ==(lhs: Category, rhs: Category) -> Bool {
    
    return (lhs.ID == rhs.ID &&
        lhs.title == rhs.title &&
        lhs.color == rhs.color)
}
