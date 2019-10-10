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
    
    // MARK: member functions
    
    func produceGenericLabel() -> UILabel {
        let gen = UILabel()
        guard let andaleFont = UIFont(name: "AndaleMono", size: UIFont.labelFontSize) else {
            fatalError("No AndaleMono available")
        }
        if #available(iOS 11.0, *) {
            gen.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: andaleFont)
        } else {
            gen.font = UIFont(name: "AndaleMono", size: 20)
        }
        if #available(iOS 10.0, *) {
            gen.adjustsFontForContentSizeCategory = true
        } else {}
        gen.textAlignment = .left
        gen.textColor = MHacksColor.backgroundDarkBlue
        gen.translatesAutoresizingMaskIntoConstraints = false
        return gen
    }
    
    // MARK: subviews
    
    lazy var positionLabel = produceGenericLabel()
    
    lazy var nameLabel = produceGenericLabel()
    
    lazy var scoreLabel = produceGenericLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.white
        
        // Add properties to name label
        nameLabel.numberOfLines = 0
        nameLabel.adjustsFontSizeToFitWidth = true
        
        // Add views
        contentView.addSubview(positionLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(scoreLabel)
        
        // Anchor views
        positionLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.2).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6).isActive = true
        scoreLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.1).isActive = true
        positionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        positionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: positionLabel.trailingAnchor, constant: 30).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: scoreLabel.leadingAnchor, constant:-10).isActive = true
        scoreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20).isActive = true
        scoreLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
