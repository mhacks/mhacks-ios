//
//  QuestCell.swift
//  MHacks
//
//  Created by Connor Svrcek on 8/19/19.
//  Copyright © 2019 MHacks. All rights reserved.
//

import UIKit

class QuestCell: UICollectionViewCell {
    
    // MARK: member vars
    
    static let identifier = "quest"
    
    let questTitle: UILabel = {
        let title = UILabel()
        title.font = UIFont(name: "Helvetica", size: 32) // TODO: change to Andale Mono
        return title
    }()
    
    let pointLabel: UILabel = {
        let points = UILabel()
        points.font = UIFont(name: "Helvetica", size: 24) // TODO: change to Andale Mono
        return points
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // TODO: add subviews, style, etc
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
