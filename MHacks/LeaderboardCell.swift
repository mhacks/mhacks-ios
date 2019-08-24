//
//  LeaderboardCell.swift
//  MHacks
//
//  Created by Connor Svrcek on 8/22/19.
//  Copyright © 2019 MHacks. All rights reserved.
//

import UIKit

class LeaderboardCell: UITableViewCell {
    
    // MARK: member vars
    
    static let identifier = "leaderboard"
    
    // MARK: subviews
    
    let positionLabel: UILabel = {
        let pos = UILabel()
        pos.font = UIFont(name: "AndaleMono", size: 20)
        pos.textAlignment = .center
        pos.textColor = UIColor.white
        pos.translatesAutoresizingMaskIntoConstraints = false
        return pos
    }()
    
    let nameLabel: UILabel = {
        let name = UILabel()
        name.font = UIFont(name: "AndaleMono", size: 20)
        name.textAlignment = .center
        name.textColor = UIColor.white
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }()
    
    let scoreLabel: UILabel = {
        let score = UILabel()
        score.font = UIFont(name: "AndaleMono", size: 17)
        score.textAlignment = .center
        score.textColor = UIColor.white
        score.translatesAutoresizingMaskIntoConstraints = false
        return score
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = MHacksColor.lighterBlue
        
        // TODO: add subviews and their anchors
        
        // Add views
        contentView.addSubview(positionLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(scoreLabel)
        
        // Anchor views
        positionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        positionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: positionLabel.trailingAnchor, constant: 30).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        scoreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        scoreLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
