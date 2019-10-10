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
    
    private let leaderboardUser: UILabel = {
        let rankscore = UILabel()
        rankscore.text = "Your rank: 0 | Your points: 0"
        rankscore.textColor = UIColor.white
        rankscore.numberOfLines = 0
        rankscore.translatesAutoresizingMaskIntoConstraints = false
        rankscore.font = UIFont(name: "ArcadeClassic", size: 19)
        return rankscore
    }()
    
    private lazy var leaderboard : UITableView = {
        let board = UITableView(frame: .zero, style: .plain)
        board.register(LeaderboardCell.self, forCellReuseIdentifier: LeaderboardCell.identifier)
        board.backgroundColor = UIColor.white
        board.layer.cornerRadius = 10
        return board
    }()
    
    private lazy var boardStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [leaderboardTitle, leaderboardUser, leaderboard])
        sv.axis = .vertical
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.spacing = 5
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
        
        // Fill leaderboard, quests, user's own rank and score
        // Repeated API call to gameState necessary to differentiate quest view from leaderboard view
        getQuests()
        getUserRankScore()
        getLeaderboard()
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
        leaderboard.reloadData()
        getLeaderboard()
        getUserRankScore()
        self.refreshControl.endRefreshing()
    }
    
    func getUserRankScore() {
        // TODO: Get user's rank from gameState when available
        APIManager.shared.getGameState { newState in
            
            print(newState ?? "nothin")
            
            guard let gState = newState?["state"] else {
                self.makeAlertController(title: "ERROR: could not parse state.", message: "Could not parse state from the server response.")
                return
            }
            
            self.gameState = gState as! [String : Any]
            guard let user_points = self.gameState["points"] as? Int else {
                self.makeAlertController(title: "ERROR: could not parse user points from state.", message: "Could not parse user points from state.")
                return
            }
            
            // Refresh the UILabel to display the user's rank and score
            DispatchQueue.main.async {
                self.leaderboardUser.text = "Your rank: 0 | Your points: " + String(user_points)
            }
        }
    }
    
    func getLeaderboard() {
        APIManager.shared.getLeaderboard { newLeaderBoard in
            // TODO: find out the json keys for leaderboard
            
            guard let leaderboard = newLeaderBoard?["leaderboard"] as? NSArray else {
                self.makeAlertController(title: "ERROR: could not parse leaderboard.", message: "Could not parse leaderboard from state.")
                return
            }
            var rank = 1;
            var new_board : [LeaderboardPosition] = []
            for entry in leaderboard as NSArray {
                guard let e = entry as? [String: Any] else {
                    self.makeAlertController(title: "ERROR: could not parse individual entry.", message: "Could not parse individual entry into dictionary.")
                    return
                }
                let entry_points = e["points"] as! Int
                let entry_user = e["user"] as! [String: Any]
                let entry_user_name = entry_user["full_name"] as! String
                print(entry_points)
                print(entry_user_name)
                let entry_rank = rank
                
                new_board.append(LeaderboardPosition(position: entry_rank, name: entry_user_name, score: entry_points))
                rank += 1;
            }
            self.peopleOnBoard = new_board
        
            print(self.peopleOnBoard)
            // Refresh the leaderboard
            DispatchQueue.main.async {
                self.leaderboard.reloadData()
            }
            
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
                self.makeAlertController(title: "ERROR: could not parse state.", message: "Could not parse state from the server response.")
                return
            }
            
            self.gameState = gState as! [String : Any]
            
            guard let quests = self.gameState["quests"] as? NSArray else {
                self.makeAlertController(title: "ERROR: could not parse quests from state.", message: "Could not parse quests from state.")
                return
            }
            
            for quest in quests {
                guard let q = quest as? [String: Any] else {
                    self.makeAlertController(title: "ERROR: could not parse individual quest into dictionary.", message: "Could not convert quest into dictionary.")
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
            makeAlertController(title: "ERROR: No quest selected", message: "Please select a single quest to scan for.")
        } else {
            let scannerViewController = ScannerViewController(questType: self.selectedQuest)
            scannerViewController.delegate = self
            
            let scannerNavigationController = UINavigationController(rootViewController: scannerViewController)
            scannerNavigationController.isToolbarHidden = false
            
            present(scannerNavigationController, animated: true) {
                print("YOOOOOOO")
                self.currentQuests = []
                self.getQuests()
                self.getLeaderboard()
            }
            
//            present(scannerNavigationController, animated: true, completion: )
            
            
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
        
        cell.forwardButton.isEnabled = true
        cell.forwardButton.addTarget(self, action:#selector(forwardAction), for:.touchUpInside)
        cell.forwardButton.addTarget(self, action:#selector(pressed), for:.touchDown)
        cell.backwardsButton.isEnabled = true
        cell.backwardsButton.addTarget(self, action:#selector(backwardsAction), for:.touchUpInside)
        cell.backwardsButton.addTarget(self, action:#selector(pressed), for:.touchDown)
               
       if(indexPath.item == 0)
       {
           cell.backwardsButton.isHidden = true
       }
       else if(indexPath.item == 2)
       {
           cell.forwardButton.isHidden = true
       }
                     
        return cell
    }
    
    @objc func pressed(sender: UIButton)
    {
        sender.backgroundColor = MHacksColor.purple
    }
    
    @objc func forwardAction(sender: UIButton!)
    {
        let current = collectionView.indexPathsForVisibleItems
        var scrollto = current[0]
        scrollto.item += 1
        //print("current \(current)")
        collectionView.scrollToItem(at: scrollto, at:[], animated: true)
        sender.backgroundColor = MHacksColor.backgroundDarkBlue
    }
    @objc func backwardsAction(sender: UIButton!)
    {
        sender.backgroundColor = MHacksColor.backgroundDarkBlue
        let current = collectionView.indexPathsForVisibleItems
        var scrollto = current[0]
        scrollto.item -= 1
        collectionView.scrollToItem(at: scrollto, at:[], animated: true)
        sender.backgroundColor = MHacksColor.backgroundDarkBlue
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        //return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        //return 20
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
