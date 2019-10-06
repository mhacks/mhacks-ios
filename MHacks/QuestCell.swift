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
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                contentView.backgroundColor = MHacksColor.lighterBlue
                questTitle.textColor = UIColor.white
                pointLabel.textColor = UIColor.white
            } else {
                contentView.backgroundColor = UIColor.white
                questTitle.textColor = MHacksColor.backgroundDarkBlue
                pointLabel.textColor = MHacksColor.backgroundDarkBlue
            }
        }
    }
    
    // MARK: subviews
    
    let questTitle: UILabel = {
        let title = UILabel()
        title.font = UIFont(name: "AndaleMono", size: 28)
        title.textAlignment = .center
        title.numberOfLines = 0
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = MHacksColor.backgroundDarkBlue
        return title
    }()
    
    let pointLabel: UILabel = {
        let points = UILabel()
        points.font = UIFont(name: "AndaleMono", size: 24)
        points.textAlignment = .center
        points.numberOfLines = 0
        points.translatesAutoresizingMaskIntoConstraints = false
        points.textColor = MHacksColor.backgroundDarkBlue
        return points
    }()
    
    let forwardButton: UIButton = {
        let forward = UIButton()
        forward.setTitle(">", for:.normal)
        forward.titleLabel?.font =  UIFont(name: "AndaleMono", size: 24)
        forward.backgroundColor = MHacksColor.backgroundDarkBlue
        forward.translatesAutoresizingMaskIntoConstraints = false
        forward.layer.cornerRadius = 5
        
        forward.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0.01, bottom: 0.01, right: 0)


        return forward
    }()
    
    let backwardsButton: UIButton = {
        let backwards = UIButton()
        backwards.setTitle("<", for:.normal)
        backwards.titleLabel?.font =  UIFont(name: "AndaleMono", size: 24)
        backwards.backgroundColor = MHacksColor.backgroundDarkBlue
        backwards.translatesAutoresizingMaskIntoConstraints = false
        backwards.layer.cornerRadius = 5
        
        backwards.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0.01, bottom: 0.01, right: 0)
        
        return backwards
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Add views
        contentView.addSubview(questTitle)
        contentView.addSubview(pointLabel)
        contentView.addSubview(forwardButton)
        contentView.addSubview(backwardsButton)
        contentView.backgroundColor = UIColor.white
        
        // Anchor views
        questTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        questTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        questTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        pointLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        pointLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        forwardButton.bottomAnchor.constraint(equalTo:contentView.bottomAnchor, constant:-15).isActive = true

        forwardButton.trailingAnchor.constraint(equalTo:contentView.trailingAnchor, constant:-10).isActive = true
        
        forwardButton.heightAnchor.constraint(equalTo:contentView.heightAnchor, multiplier:0.2).isActive=true
        forwardButton.widthAnchor.constraint(equalTo:contentView.widthAnchor, multiplier:0.12).isActive=true

        backwardsButton.bottomAnchor.constraint(equalTo:contentView.bottomAnchor, constant:-15).isActive = true

        backwardsButton.leadingAnchor.constraint(equalTo:contentView.leadingAnchor, constant:10).isActive = true
        
        backwardsButton.heightAnchor.constraint(equalTo:contentView.heightAnchor, multiplier:0.2).isActive=true
        backwardsButton.widthAnchor.constraint(equalTo:contentView.widthAnchor, multiplier:0.12).isActive=true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
