//
//  SiMHacksViewController.swift
//  MHacks
//
//  Created by Connor Svrcek on 5/21/19.
//  Copyright © 2019 MHacks. All rights reserved.
//

import UIKit


class SiMHacksViewController: UIViewController, ScannerViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        edgesForExtendedLayout = [] // Make no view go under nav bar
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: member variables
    
    private var gameState: [String:Any]?
    
    private var currentQuests: [Quest] = []
    
    private var peopleOnBoard: [LeaderboardPosition] = []
    
    private let refreshControl = UIRefreshControl()
    
    // MARK: Subviews
    
    private lazy var scanButton: UIButton = {
        let scan = UIButton()
        scan.setTitle("Scan", for: .normal)
        scan.backgroundColor = UIColor.yellow
        scan.setTitleColor(UIColor.black, for: .normal)
        scan.setTitleColor(UIColor.white, for: .highlighted)
        scan.translatesAutoresizingMaskIntoConstraints = false
        scan.layer.cornerRadius = 10
        return scan
    }()
    
    // Leaderboard stuff
    private let leaderboardTitle: UILabel = {
        let board = UILabel()
        board.text = "Leaderboard"
        board.textColor = UIColor.white
        board.font = UIFont(name: "ArcadeClassic", size: 38)
        return board
    }()
    
    private lazy var leaderboard : UITableView = {
        let board = UITableView(frame: .zero, style: .plain)
        board.register(LeaderboardCell.self, forCellReuseIdentifier: LeaderboardCell.identifier)
        board.backgroundColor = MHacksColor.lighterBlue
        board.layer.cornerRadius = 10
        return board
    }()
    
    private lazy var boardStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [leaderboardTitle, leaderboard])
        sv.axis = .vertical
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.spacing = 15
        return sv
    }()
    
    // Quest stuff
    private let questTitle: UILabel = {
        let qTitle = UILabel()
        qTitle.text = "Quests"
        qTitle.textColor = UIColor.white
        qTitle.font = UIFont(name: "ArcadeClassic", size: 38)
        qTitle.minimumScaleFactor = 0.5
        return qTitle
    }()
    
    private let collectionView: UICollectionView = {
        let horizontalLayout = UICollectionViewFlowLayout()
        horizontalLayout.scrollDirection = .horizontal
        let coll = UICollectionView(frame: .zero, collectionViewLayout: horizontalLayout)
        coll.isPagingEnabled = true
        coll.backgroundColor = MHacksColor.backgroundDarkBlue
        coll.register(QuestCell.self, forCellWithReuseIdentifier: QuestCell.identifier)
        return coll
    }()
    
    private lazy var questStackView: UIStackView = { // FIXME: quests are very small on SE
        let qSV = UIStackView(arrangedSubviews: [questTitle, collectionView, scanButton])
        qSV.axis = .vertical
        qSV.translatesAutoresizingMaskIntoConstraints = false
        qSV.spacing = 15
        return qSV
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = MHacksColor.backgroundDarkBlue
        
        // Set up collectionview
        setupCollectionview()
        
        // Setup tableview
        setupLeaderboard()
        
        // Set up navigation stuff
        setupNavigation()
        
        // Set up subviews
        setupSubviews()
        
        // Fill leaderboard and quests
        getLeaderboard()
        getQuests()
    }
    
    func setupCollectionview() {
        // Collection view datasource & delegate
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func setupLeaderboard() {
        // Table view datasource & delegation
        leaderboard.dataSource = self
        leaderboard.delegate = self
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            leaderboard.refreshControl = refreshControl
        } else {
            leaderboard.addSubview(refreshControl)
        }
        
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshLeaderboard(_:)), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Updating leaderboard ...", attributes: [NSAttributedString.Key.font : UIFont(name: "AndaleMono", size: 12)!, NSAttributedString.Key.foregroundColor : UIColor.white])
        refreshControl.tintColor = UIColor.white
    }
    
    @objc func refreshLeaderboard(_ sender: Any) {
        // TODO: fetch leaderboard from API
        leaderboard.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    func getLeaderboard() {
        // TODO: fill data from an API request
        // If you are outside of top 5, create a LeaderboardPosition with position -1. When dequeing, check if position is -1, if so, hide position and points and make name = "...", add your info after that
        for i in 1...5 {
            peopleOnBoard.append(LeaderboardPosition(position: i, name: "cdids", score: 300))
        }
    }
    
    func getQuests() {
        // TODO: fill data from an API request
        
        APIManager.shared.getGameState { newState in
            self.gameState = newState?["state"] as? [String : Any]
            print(self.gameState?["quests"] ?? "NAH")
        }
        
    }
    
    func setupNavigation() {
        navigationItem.title = "SiMHacks"
        navigationController?.navigationBar.barTintColor = MHacksColor.backgroundDarkBlue
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont(name: "ArcadeClassic", size: 25)!]
        
        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeSim))
        closeButton.tintColor = UIColor.white
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(infoButtonPressed), for: .touchUpInside)
        infoButton.tintColor = UIColor.white
        
        let infoBarButton = UIBarButtonItem(customView: infoButton)
        
        // TODO: status bar is barely visible with dark background, fix
        
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.rightBarButtonItem = infoBarButton
    }
    
    @objc func infoButtonPressed() {
        navigationController?.pushViewController(SiMHacksInfoController(), animated: true)
    }
    
    func setupSubviews() {
        // Add board subview
        view.addSubview(boardStackView)
        
        // Constrain board stack view
        boardStackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5, constant: -40).isActive = true
        boardStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 15).isActive = true
        boardStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        boardStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        
        // Add quest subviews
        view.addSubview(questStackView)
        
        // Constrain quest stack view
        questStackView.topAnchor.constraint(equalTo: boardStackView.bottomAnchor, constant: 15).isActive = true
        questStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        questStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        questStackView.heightAnchor.constraint(equalTo: boardStackView.heightAnchor, multiplier: 0.85).isActive = true
        
        // Add scan button
        view.addSubview(scanButton)

        // Constrain scan button
        scanButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.08).isActive = true
        scanButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        scanButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        scanButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        
        scanButton.addTarget(self, action: #selector(scan), for: .touchUpInside)
    }
    
    @objc func closeSim() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func scan() {
        let scannerViewController = ScannerViewController(questType: "studio") // TODO: pass in quest type for scan
        scannerViewController.delegate = self
        
        let scannerNavigationController = UINavigationController(rootViewController: scannerViewController)
        scannerNavigationController.isToolbarHidden = false
        
        present(scannerNavigationController, animated: true, completion: nil)
    }
    
    // MARK: ScannerViewControllerDelegate
    
    func scannerViewControllerDidFinish(scannerViewController: ScannerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentQuests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QuestCell.identifier, for: indexPath) as! QuestCell
        let data = currentQuests[indexPath.item]
        cell.questTitle.text = data.title
        
        // Constraints for questTitle
        cell.questTitle.adjustsFontSizeToFitWidth = true
        cell.questTitle.heightAnchor.constraint(equalTo: cell.contentView.heightAnchor, multiplier: 1/2).isActive = true
        cell.questTitle.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 15).isActive = true
        cell.questTitle.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: 20).isActive = true
        cell.questTitle.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20).isActive = true
        
        cell.pointLabel.text = "\(data.points) points"
        
        // Constraints for pointLabel
        cell.pointLabel.adjustsFontSizeToFitWidth = true
        cell.pointLabel.topAnchor.constraint(equalTo: cell.questTitle.bottomAnchor, constant: 10).isActive = true
        cell.pointLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
        cell.contentView.layer.cornerRadius = 10 // rounded corners
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peopleOnBoard.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LeaderboardCell.identifier, for: indexPath) as! LeaderboardCell
        let data = peopleOnBoard[indexPath.item]
        cell.positionLabel.text = "\(data.position)"
        cell.nameLabel.text = data.name
        cell.scoreLabel.text = "\(data.score)"
        return cell
    }
    
    
}
