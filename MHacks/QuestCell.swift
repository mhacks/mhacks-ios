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
    
    // MARK: subviews
    
    let questTitle: UILabel = {
        let title = UILabel()
        title.font = UIFont(name: "AndaleMono", size: 28)
        title.textAlignment = .center
        title.numberOfLines = 0
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = UIColor.white // TODO: change to background blue
        return title
    }()
    
    let pointLabel: UILabel = {
        let points = UILabel()
        points.font = UIFont(name: "AndaleMono", size: 24)
        points.textAlignment = .center
        points.numberOfLines = 0
        points.translatesAutoresizingMaskIntoConstraints = false
        points.textColor = UIColor.white // TODO: change to background blue
        return points
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Add views
        contentView.addSubview(questTitle)
        contentView.addSubview(pointLabel)
        contentView.backgroundColor = MHacksColor.lighterBlue // TODO: change to white
        
        // Anchor views
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
