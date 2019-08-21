//
//  SiMHacksViewController.swift
//  MHacks
//
//  Created by Connor Svrcek on 5/21/19.
//  Copyright © 2019 MHacks. All rights reserved.
//

import UIKit


class SiMHacksViewController: UIViewController, ScannerViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        edgesForExtendedLayout = [] // Make no view go under nav bar
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: member variables
    var currentQuests: [Quest] = [Quest(title: "Find a hacker whose favorite ice cream flavor is Vanilla", points: 100), Quest(title: "Test2", points: 100), Quest(title: "Test3", points: 100)]
    
    let collectionView: UICollectionView = {
        let horizontalLayout = UICollectionViewFlowLayout()
        horizontalLayout.scrollDirection = .horizontal
        let coll = UICollectionView(frame: .zero, collectionViewLayout: horizontalLayout)
        coll.translatesAutoresizingMaskIntoConstraints = false
        return coll
    }()
    
    // MARK: Subviews
    
    // Leaderboard stuff
    let leaderboardTitle: UILabel = {
        let board = UILabel()
        board.text = "Leaderboard"
        board.textAlignment = .left
        board.font = UIFont(name: "ArcadeClassic", size: 38)
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
        qTitle.font = UIFont(name: "ArcadeClassic", size: 38)
        return qTitle
    }()
    
    lazy var questStackView: UIStackView = { // FIXME: quests are very small on SE
        let qSV = UIStackView(arrangedSubviews: [questTitle, collectionView])
        qSV.axis = .vertical
        qSV.translatesAutoresizingMaskIntoConstraints = false
        qSV.spacing = 15
        return qSV
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        // Collection view setup
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(QuestCell.self, forCellWithReuseIdentifier: QuestCell.identifier)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.yellow
        collectionView.isPagingEnabled = true
        
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
    
    // MARK: Collection view protocols
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentQuests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: QuestCell.identifier, for: indexPath) as! QuestCell
        let data = currentQuests[indexPath.item]
        cell.questTitle.text = data.title
        cell.pointLabel.text = "\(data.points) points"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero // TODO: change if inset wanted
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0 // TODO: change?
    }
    
    
}
