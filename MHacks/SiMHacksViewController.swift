//
//  SiMHacksViewController.swift
//  MHacks
//
//  Created by Connor Svrcek on 5/21/19.
//  Copyright © 2019 MHacks. All rights reserved.
//

import UIKit


class SiMHacksViewController: UIViewController, ScannerViewControllerDelegate {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        edgesForExtendedLayout = [] // Make no view go under nav bar
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: member variables
    var currentQuests: [Quest] = []
    
    // MARK: Subviews
    
    // Leaderboard stuff
    let leaderboardTitle: UILabel = {
        let board = UILabel()
        board.text = "Leaderboard"
        board.textAlignment = .left
        board.font = UIFont(name: "Helvetica", size: 32) // TODO: change to Arcade Classic
        return board
    }()
    
    lazy var leaderboard : UIView = { // TODO: change to a table view?
        let board = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 2))
        board.backgroundColor = UIColor.blue
        return board
    }()
    
    lazy var boardStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [leaderboardTitle, leaderboard])
        sv.axis = .vertical
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.spacing = 15
        return sv
    }()
    
    let questTitle: UILabel = {
        let qTitle = UILabel()
        qTitle.text = "Quests"
        qTitle.font = UIFont(name: "Helvetica", size: 32) // TODO: change to Arcade Classic
        return qTitle
    }()
    
    // Displaying one quest for testing
//    let quest: QuestCell = {
//        let q = QuestCell(title: "Find someone whose favorite video game genre is First Person Shooter.", points: 200)
//        return q
//    }()
    
    lazy var questStackView: UIStackView = { // FIXME: quests are very small on SE
        let qSV = UIStackView(arrangedSubviews: [questTitle, quest])
        qSV.axis = .vertical
        qSV.translatesAutoresizingMaskIntoConstraints = false
        qSV.spacing = 15
        return qSV
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        // Set up navigation stuff
        setupNavigation()
        
        // Set up subviews
        setupSubviews()
    }
    
    func setupNavigation() {
        navigationItem.title = "SiMHacks"
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeSim))
        let scanButton = UIBarButtonItem(title: "Scan", style: .plain, target: self, action: #selector(scan))
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.rightBarButtonItem = scanButton
    }
    
    func setupSubviews() {
        // Add board subview
        view.addSubview(boardStackView)
        
        // Constrain board stack view
        boardStackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        boardStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30).isActive = true
        boardStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        boardStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        
        // Add quest subviews
        view.addSubview(questStackView)
        
        // Constrain quest stack view
        questStackView.topAnchor.constraint(equalTo: boardStackView.bottomAnchor, constant: 40).isActive = true
        questStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        questStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        questStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -75).isActive = true
        
    }
    
    @objc func closeSim() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func scan() {
        let scannerViewController = ScannerViewController(nibName: nil, bundle: nil)
        scannerViewController.delegate = self
        
        let scannerNavigationController = UINavigationController(rootViewController: scannerViewController)
        scannerNavigationController.isToolbarHidden = false
        
        present(scannerNavigationController, animated: true, completion: nil)
    }
    
    
    // MARK: Scanner view controller delegate
    func scannerViewControllerDidFinish(scannerViewController: ScannerViewController) {
        dismiss(animated: true, completion: nil)
    }
}
