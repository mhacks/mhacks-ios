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
//        guard let andaleFont = UIFont(name: "AndaleMono", size: UIFont.labelFontSize) else {
//            fatalError("No AndaleMono available")
//        }
//        if #available(iOS 11.0, *) {
//            title.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: andaleFont)
//        } else {
//            title.font = UIFont(name: "AndaleMono", size: 24)
//        }
//        if #available(iOS 10.0, *) {
//            title.adjustsFontForContentSizeCategory = true
//        } else {}
        title.font = UIFont(name: "AndaleMono", size: 28)
        title.textAlignment = .center
        title.numberOfLines = 3
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = UIColor.white
        return title
    }()
    
    let pointLabel: UILabel = {
        let points = UILabel()
//        guard let andaleFont = UIFont(name: "AndaleMono", size: UIFont.labelFontSize) else {
//            fatalError("No AndaleMono available")
//        }
//        if #available(iOS 11.0, *) {
//            points.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: andaleFont)
//        } else {
//            points.font = UIFont(name: "AndaleMono", size: 24)
//        }
//        if #available(iOS 10.0, *) {
//            points.adjustsFontForContentSizeCategory = true
//        } else {}
        points.font = UIFont(name: "AndaleMono", size: 24)
        points.textAlignment = .center
        points.translatesAutoresizingMaskIntoConstraints = false
        points.textColor = UIColor.white
        return points
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Add views
        contentView.addSubview(questTitle)
        contentView.addSubview(pointLabel)
        contentView.backgroundColor = MHacksColor.lighterBlue
        
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
