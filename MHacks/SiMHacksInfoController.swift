//
//  SiMHacksInfoController.swift
//  MHacks
//
//  Created by Connor Svrcek on 9/16/19.
//  Copyright © 2019 MHacks. All rights reserved.
//

import UIKit

class SiMHacksInfoController: UIViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        edgesForExtendedLayout = [] // Make no view go under nav bar
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var infoLabel : UITextView = {
        let info = UITextView()
        info.textColor = UIColor.white
        info.backgroundColor = MHacksColor.backgroundDarkBlue
        info.text = "SiMHacks = Sims + MHacks. A brand new way for hackers to interact and engage with each other! The hacker with the top score at the end will receive a prize that will surely make them get their game on ;)\n\n You will be given 3 quests at a time and once you complete a quest, you will be given a randomly generated new one.\n\n To complete a quest, you will need to find a fellow hacker who's corresponding SiMHacks response fulfills the description of the quest and scan their QR code, located on their ticket. You also cannot scan the same hacker twice.\n\n Best of luck on your journey and most of all, have fun!"
        info.translatesAutoresizingMaskIntoConstraints = false
        info.textAlignment = .center
        info.font = UIFont(name: "AndaleMono", size: 25)
        info.isEditable = false
        return info
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = MHacksColor.backgroundDarkBlue
        navigationController?.navigationBar.tintColor = UIColor.white
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
        infoLabel.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }
}
