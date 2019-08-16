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
    
    // MARK: Subviews
    
    // Leaderboard stuff
    lazy var leaderboardTitle: UILabel = {
        let board = UILabel(frame: CGRect(x: 0, y: 30, width: view.frame.width, height: 32))
        board.text = "Leaderboard"
        board.numberOfLines = 0
        board.textAlignment = .center
        board.textColor = UIColor.black
        board.font = UIFont(name: "Helvetica", size: 32)
        board.center.x = self.view.center.x
        board.translatesAutoresizingMaskIntoConstraints = false
        return board
    }()

    let playerTitle: UILabel = {
        let player = UILabel()
        player.text = "Player"
        player.font = UIFont(name: "Helvetica", size: 24)
        player.translatesAutoresizingMaskIntoConstraints = false
        return player
    }()
    
    let scoreTitle: UILabel = {
        let score = UILabel()
        score.text = "Score"
        score.font = UIFont(name: "Helvetica", size: 24)
        score.translatesAutoresizingMaskIntoConstraints = false
        return score
    }()
    
    lazy var playerScoreStackView: UIStackView = {
        let psSV = UIStackView(arrangedSubviews: [playerTitle, scoreTitle])
        psSV.axis = .horizontal
        psSV.translatesAutoresizingMaskIntoConstraints = false
        return psSV
    }()
    
    lazy var leaderboard : UIView = {
        let board = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height / 2))
        board.backgroundColor = UIColor.blue
        board.translatesAutoresizingMaskIntoConstraints = false
        return board
    }()
    
    lazy var boardStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [leaderboardTitle, playerScoreStackView, leaderboard])
        sv.axis = .vertical
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // TODO: figure out quest tiles
    
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
        
        // Constrain board subview
        boardStackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
        boardStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        boardStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        boardStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
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
