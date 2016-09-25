//
//  ScannerViewController.swift
//  MHacks
//
//  Created by Russell Ladd on 9/21/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

protocol ScannerViewControllerDelegate: class {
    
    func scannerViewControllerDidFinish(scannerViewController: ScannerViewController)
}

final class ScannerViewController: UIViewController, ScannerViewDelegate {
    
    // MARK: Model
    
    enum InputMode: Int {
        case list = 0
        case scan = 1
    }
    
    var inputMode = InputMode.scan {
        didSet {
            updateViews()
        }
    }
    
    var currentScanEvent = APIManager.shared.scanEvents.first {
        didSet {
            updateEventsBarButtonItemTitle()
        }
    }
    
    // MARK: Delegate
    
    weak var delegate: ScannerViewControllerDelegate?
    
    // MARK: Views
    
    let inputModeControl = UISegmentedControl(items: ["List", "Scan"])
    
    let eventsBarButtonItem = UIBarButtonItem(title: "Loading", style: .plain, target: nil, action: nil)
    
    let tableView = UITableView(frame: CGRect.zero, style: .plain)
    let scannerView = ScannerView()
    
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View
        
        view.backgroundColor = UIColor.white
        
        // Bars
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Finish", style: .plain, target: self, action: #selector(finish))
        
        navigationItem.titleView = inputModeControl
        
        inputModeControl.selectedSegmentIndex = 1
        inputModeControl.addTarget(self, action: #selector(inputModeControlValueChanged), for: .valueChanged)
        
        eventsBarButtonItem.target = self
        eventsBarButtonItem.action = #selector(selectScanEvent)
        
        toolbarItems = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), eventsBarButtonItem, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)]
        
        // Table view
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Scanner view
        
        scannerView.translatesAutoresizingMaskIntoConstraints = false
        scannerView.delegate = self
        view.addSubview(scannerView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scannerView.topAnchor.constraint(equalTo: view.topAnchor),
            scannerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        updateViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(scanEventsUpdated), name: APIManager.ScanEventsUpdatedNotification, object: nil)
        
        APIManager.shared.updateScanEvents()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: APIManager.ScanEventsUpdatedNotification, object: nil)
    }
    
    // MARK: Update views
    
    func updateViews() {
        
        inputModeControl.selectedSegmentIndex = inputMode.rawValue
        
        tableView.isHidden = (inputMode != .list)
        scannerView.isHidden = (inputMode != .scan)
        
        updateEventsBarButtonItemTitle()
    }
    
    func updateEventsBarButtonItemTitle() {
        
        eventsBarButtonItem.title = currentScanEvent?.name ?? "Loading"
    }
    
    // MARK: Actions
    
    func finish() {
        delegate?.scannerViewControllerDidFinish(scannerViewController: self)
    }
    
    func inputModeControlValueChanged() {
        inputMode = InputMode(rawValue: inputModeControl.selectedSegmentIndex)!
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
        
        
    }
}
