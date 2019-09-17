//
//  SiMHacksInfoController.swift
//  MHacks
//
//  Created by Connor Svrcek on 9/16/19.
//  Copyright © 2019 MHacks. All rights reserved.
//

import UIKit

class SiMHacksInfoController: UIViewController {
    lazy var infoLabel : UILabel = {
        let info = UILabel()
        info.textColor = UIColor.white
        info.text = "SiMHacks = Sims + MHacks. A brand new way for hackers to interact and engage with each other!\n You will be given 5 quests at a time and once you complete a quest, you will be given a randomly generated new one.\n To complete a quest, you will need to find a fellow hacker who fulfills the description of the quest and scan their QR code. You also cannot scan the same hacker twice.\n You also have the option to refresh all quests every 3 hours in case you get stuck. \n Best of luck on your journey and most of all, have fun!"
        info.numberOfLines = 0
        info.lineBreakMode = .byWordWrapping
        info.translatesAutoresizingMaskIntoConstraints = false
        info.textAlignment = .center
        info.font = UIFont(name: "AndaleMono", size: 25)
        return info
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = MHacksColor.backgroundDarkBlue
        
        setupViews()
    }
    
    func setupViews() {
        // TODO: change navigation button tint to white
        
        // Add subviews
        view.addSubview(infoLabel)
        
        // Add anchors to subviews
        infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        infoLabel.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        infoLabel.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
}
