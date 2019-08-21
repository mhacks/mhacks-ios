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
        title.font = UIFont(name: "AndaleMono", size: 30)
        title.textAlignment = .center
        title.numberOfLines = 3
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = UIColor.white
        return title
    }()
    
    let pointLabel: UILabel = {
        let points = UILabel()
        points.font = UIFont(name: "AndaleMono", size: 24)
        points.textAlignment = .center
        points.translatesAutoresizingMaskIntoConstraints = false
        points.textColor = UIColor.white
        return points
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // TODO: add subviews, style, anchor, etc
        
        // Add stack view
        contentView.addSubview(questTitle)
        contentView.addSubview(pointLabel)
        contentView.backgroundColor = UIColor.blue
        
        // Anchor stack view
        questTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        questTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        questTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        pointLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        pointLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
