//
//  ScannerViewController.swift
//  MHacks
//
//  Created by Russell Ladd on 9/21/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

protocol ScannerViewControllerDelegate: class {
    
    func scannerViewControllerDidFinish(scannerViewController: ScannerViewController)
}

final class ScannerViewController: UIViewController, ScannerViewDelegate {
    
    // MARK: Model
    
    var currentScanEvent = APIManager.shared.scanEvents.first {
        didSet {
            updateEventsBarButtonItemTitle()
        }
    }
    
    var scanIdentifier: String?
    var scanFields: [ScannedDataField]? {
        didSet {
            updateUserView()
            updateToolbarItems(animated: true)
        }
    }
    
    // MARK: Delegate
    
    weak var delegate: ScannerViewControllerDelegate?
    
    // MARK: Beacons
    
    let beaconUUID = UUID(uuidString: "5759985C-B037-43B4-939D-D6286CE9C941")!
    
    let peripheralManager = CBPeripheralManager()
    
    lazy var beaconRegion: CLBeaconRegion = {
        return CLBeaconRegion(proximityUUID: self.beaconUUID, major: 0, minor: 0, identifier: "com.MHacks.ScanTicketBeacon")
    }()
    
    // MARK: Views
    
    let eventsBarButtonItem = UIBarButtonItem(title: "Loading", style: .plain, target: nil, action: nil)
    let dismissBarButtonItem = UIBarButtonItem(title: "Dismiss", style: .done, target: nil, action: nil)
    
    let scannerView = ScannerView()
    
    let userBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
    let userStackView = UIStackView()
    
    final class DoubleLabel: UIStackView {
        
        init() {
            super.init(frame: CGRect.zero)
            
            addArrangedSubview(titleLabel)
            addArrangedSubview(textLabel)
            
            axis = .vertical
            alignment = .leading
            
            titleLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
            
            textLabel.numberOfLines = 0
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        let titleLabel = UILabel()
        let textLabel = UILabel()
    }
    
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View
        
        view.backgroundColor = UIColor.white
        
        // Bars
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Finish", style: .plain, target: self, action: #selector(finish))
        
        navigationItem.title = "Scan Tickets"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(search))
        
        eventsBarButtonItem.target = self
        eventsBarButtonItem.action = #selector(selectScanEvent)
        
        dismissBarButtonItem.target = self
        dismissBarButtonItem.action = #selector(dismissUserScan)
        
        // Scanner view
        
        scannerView.translatesAutoresizingMaskIntoConstraints = false
        scannerView.delegate = self
        view.addSubview(scannerView)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissUserScan))
        scannerView.addGestureRecognizer(tapGestureRecognizer)
        
        userBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userBackgroundView)
        
        userStackView.translatesAutoresizingMaskIntoConstraints = false
        userStackView.axis = .vertical
        userStackView.spacing = 15.0
        
        userBackgroundView.contentView.addSubview(userStackView)
        
        NSLayoutConstraint.activate([
            scannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scannerView.topAnchor.constraint(equalTo: view.topAnchor),
            scannerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            userBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            userBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            userBackgroundView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),
            userStackView.leadingAnchor.constraint(equalTo: userBackgroundView.contentView.leadingAnchor, constant: 10.0),
            userStackView.trailingAnchor.constraint(equalTo: userBackgroundView.contentView.trailingAnchor, constant: -10.0),
            userStackView.topAnchor.constraint(equalTo: userBackgroundView.contentView.topAnchor, constant: 10.0),
            userStackView.bottomAnchor.constraint(equalTo: userBackgroundView.contentView.bottomAnchor, constant: -10.0),
        ])
        
        updateViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(scanEventsUpdated), name: APIManager.ScanEventsUpdatedNotification, object: nil)
        
        APIManager.shared.updateScanEvents()
        
        let beaconPeripheralData = beaconRegion.peripheralData(withMeasuredPower: nil)
        peripheralManager.startAdvertising(beaconPeripheralData.copy() as? [String: AnyObject])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        peripheralManager.stopAdvertising()
        
        NotificationCenter.default.removeObserver(self, name: APIManager.ScanEventsUpdatedNotification, object: nil)
    }
    
    // MARK: Update views
    
    func updateViews() {
        
        updateEventsBarButtonItemTitle()
        
        updateUserView()
        
        updateToolbarItems(animated: false)
    }
    
    func updateEventsBarButtonItemTitle() {
        
        eventsBarButtonItem.title = currentScanEvent?.name ?? "Loading"
    }
    
    func updateUserView() {
        
        userBackgroundView.alpha = (scanFields == nil) ? 0.0 : 1.0
        
        if let fields = scanFields {
            
            // Ensure the stack view has the right number of double labels
            
            while userStackView.arrangedSubviews.count < fields.count {
                userStackView.addArrangedSubview(DoubleLabel())
            }
            
            while userStackView.arrangedSubviews.count > fields.count {
                userStackView.arrangedSubviews.last!.removeFromSuperview()
            }
            
            for (index, field) in fields.enumerated() {
                
                let doubleLabel = userStackView.arrangedSubviews[index] as! DoubleLabel
                
                doubleLabel.titleLabel.text = field.label
                doubleLabel.textLabel.text = field.value
                
                doubleLabel.titleLabel.textColor = field.color
                doubleLabel.textLabel.textColor = field.color
            }
        }
    }
    
    func updateToolbarItems(animated: Bool) {
        
        let barButtonItem = (scanFields == nil) ? eventsBarButtonItem : dismissBarButtonItem
        
        setToolbarItems([UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), barButtonItem, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)], animated: animated)
    }
    
    // MARK: Actions
    
    func finish() {
        delegate?.scannerViewControllerDidFinish(scannerViewController: self)
    }
    
    func search() {
        
        dismissUserScan()
        
        let alertController = UIAlertController(title: "Search by Email", message: "Enter the hacker's email address.", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.keyboardType = .emailAddress
            textField.placeholder = "hacker@school.edu"
            textField.returnKeyType = .search
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Search", style: .default, handler: { action in
            
            if let identifier = alertController.textFields!.first!.text {
                self.performScan(identifier: identifier)
            }
        }))
        
        present(alertController, animated: true)
    }
    
    func scanEventsUpdated() {
        
        DispatchQueue.main.async {
            
            if self.currentScanEvent == nil {
                self.currentScanEvent = APIManager.shared.scanEvents.first
            }
        }
    }
    
    func selectScanEvent() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        for scanEvent in APIManager.shared.scanEvents {
            
            alertController.addAction(UIAlertAction(title: scanEvent.name, style: .default, handler: { action in
                self.currentScanEvent = scanEvent
            }))
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: Scanner view delegate
    
    func scannerView(scannerView: ScannerView, didScanIdentifier identifier: String) {
        
        performScan(identifier: identifier)
    }
    
    // MARK: Perform and cancel scan
    
    func performScan(identifier: String) {
        
        guard scanIdentifier != identifier, let scanEvent = currentScanEvent else {
            return
        }
        
        scanIdentifier = identifier
        
        APIManager.shared.performScan(userDataScanned: identifier, scanEvent: scanEvent, readOnlyPeek: false) { success, additionalData in
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.15) {
                    self.scanFields = additionalData
                }
            }
        }
    }
    
    func dismissUserScan() {
        
        UIView.animate(withDuration: 0.15) {
            self.scanIdentifier = nil
            self.scanFields = nil
        }
    }
}
