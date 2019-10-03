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
    
    // MARK: Member variables
    
    private var gameState: [String: Any] = [:]
    
    private var currentQuests: [Quest] = []
    
    private var peopleOnBoard: [LeaderboardPosition] = []
    
    private let refreshControl = UIRefreshControl()
    
    private var selectedQuest: String = ""
    
    private var questNames: [String] = []
    
    // MARK: Subviews
    
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
        board.backgroundColor = UIColor.white
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
    
    private lazy var scanButton: UIButton = {
        let scan = UIButton()
        scan.setTitle("Scan", for: .normal)
        scan.backgroundColor = UIColor.init(white: 1, alpha: 0.9)
        scan.setTitleColor(UIColor.black, for: .normal)
        scan.setTitleColor(UIColor.white, for: .highlighted)
        scan.translatesAutoresizingMaskIntoConstraints = false
        scan.layer.cornerRadius = 10
        return scan
    }()
    
    private lazy var questStackView: UIStackView = {
        let qSV = UIStackView(arrangedSubviews: [questTitle, collectionView, scanButton])
        qSV.axis = .vertical
        qSV.translatesAutoresizingMaskIntoConstraints = false
        qSV.spacing = 15
        return qSV
    }()
    
    
    // TODO
//    private lazy var noQuestsLabel: UILabel = {
//        let noQuests = UILabel()
//        noQuests.text = "No quests available."
//        noQuests.font = UIFont(name: "AndaleMono", size: 24)
//        noQuests.textColor = UIColor.white
//        noQuests.isHidden = true
//        return noQuests
//    }()
    
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
    
    func makeAlertController(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func setupCollectionview() {
        // Collection view datasource & delegate
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
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
        refreshControl.attributedTitle = NSAttributedString(string: "Updating leaderboard ...", attributes: [NSAttributedString.Key.font : UIFont(name: "AndaleMono", size: 12)!, NSAttributedString.Key.foregroundColor : MHacksColor.backgroundDarkBlue])
        refreshControl.tintColor = MHacksColor.backgroundDarkBlue
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
        // Dictionary for translating categories from response into text
        let questionDict = ["icecream": "Find someone whose favorite ice cream flavor is {}.",
                            "dinosaur": "Find someone whose favorite dinosaur is {}.",
                            "fuel": "Find someone whose gaming fuel of choice is {}.",
                            "console": "Find someone whose favorite game console is {}.",
                            "studio": "Find someone who thinks {} makes the best game.",
                            "pokemon": "Find someone whose favorite Pokémon is {}.",
                            "marvel": "Find someone whose favorite Marvel superhero is {}.",
                            "genre": "Find someone whose favorite video game genre is {}.",
                            "retro": "Find someone whose favorite retro video game is {}.",
                            "smash": "Find someone who mains {}."]
        
        // Get data from API
        APIManager.shared.getGameState { newState in
            
            guard let gState = newState?["state"] else {
                print("ERROR: could not parse state.")
                // TODO: display alert
                return
            }
            
            self.gameState = gState as! [String : Any]
            
            guard let quests = self.gameState["quests"] as? NSArray else {
                print("ERROR: could not parse quests from state.")
                // TODO: display alert
                return
            }
            
            for quest in quests {
                guard let q = quest as? [String: Any] else {
                    print("ERROR: could not parse individual quest into dictionary.")
                    // TODO: display alert
                    return
                }
                let questionKeyword = q["question"] as! String
                var fullQuestion = questionDict[questionKeyword] ?? "Invalid quest."
                let answer = q["answer"] as! String
                let numPoints = q["points"] as? Int ?? -1
                
                // Find and replace the {} with the real question content
                fullQuestion = fullQuestion.replacingOccurrences(of: "{}", with: answer)
                
                self.currentQuests.append(Quest(title: fullQuestion, points: numPoints))
                
                self.questNames.append(questionKeyword)
            }
            
            // Refresh the collectionview to display the quests
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    func setupNavigation() {
        navigationItem.title = "SiMHacks"
        navigationController?.navigationBar.barTintColor = MHacksColor.backgroundDarkBlue
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont(name: "ArcadeClassic", size: 25)!]
        navigationController?.navigationBar.barStyle = .black
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
        
//        // TODO: Add noQuestsLabel on top of collectionview
//        collectionView.addSubview(noQuestsLabel)
//        noQuestsLabel.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor).isActive = true
//        noQuestsLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor).isActive = true
//        noQuestsLabel.widthAnchor.constraint(equalTo: collectionView.widthAnchor).isActive = true
//        noQuestsLabel.heightAnchor.constraint(equalTo: collectionView.heightAnchor).isActive = true
        
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
        // Check for no quest selected
        if self.selectedQuest == "" {
            makeAlertController(title: "Error: No quest selected", message: "Please select a single quest to scan for.")
        } else {
            let scannerViewController = ScannerViewController(questType: self.selectedQuest)
            scannerViewController.delegate = self
            
            let scannerNavigationController = UINavigationController(rootViewController: scannerViewController)
            scannerNavigationController.isToolbarHidden = false
            
            present(scannerNavigationController, animated: true, completion: nil)
        }
    }
    
    // MARK: ScannerViewControllerDelegate
    
    func scannerViewControllerDidFinish(scannerViewController: ScannerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if currentQuests.count == 0 {
//            print("YEET")
//            self.noQuestsLabel.isHidden = false
//        }
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
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let item = collectionView.cellForItem(at: indexPath)
        if item?.isSelected ?? false {
            collectionView.deselectItem(at: indexPath, animated: true)
            self.selectedQuest = ""
        } else {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: [])
            self.selectedQuest = questNames[indexPath.row]
        }

        return false
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
