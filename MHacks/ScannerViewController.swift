//
//  ScannerViewController.swift
//  MHacks
//
//  Created by Russell Ladd on 9/21/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

protocol ScannerViewControllerDelegate: class {
    
    func scannerViewControllerDidCancel(scannerViewController: ScannerViewController)
}

final class ScannerViewController: UIViewController {
    
    // MARK: Model
    
    var currentScanEvent: ScanEvent?
    
    // MARK: Delegate
    
    weak var delegate: ScannerViewControllerDelegate?
    
    // MARK: Views
    
    let inputModeControl = UISegmentedControl(items: ["List", "Scan"])
    
    let eventsBarButtonItem = UIBarButtonItem(title: "Loading", style: .plain, target: nil, action: nil)
    
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        
        navigationItem.titleView = inputModeControl
        
        inputModeControl.selectedSegmentIndex = 1
        inputModeControl.addTarget(self, action: #selector(inputModeControlValueChanged), for: .valueChanged)
        
        eventsBarButtonItem.target = self
        eventsBarButtonItem.action = #selector(selectScanEvent)
        
        toolbarItems = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), eventsBarButtonItem, UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)]
        
        updateViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        APIManager.shared.updateScanEvents()
        
        NotificationCenter.default.addObserver(self, selector: #selector(scanEventsUpdated), name: APIManager.ScanEventsUpdatedNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: APIManager.ScanEventsUpdatedNotification, object: nil)
    }
    
    // MARK: Update views
    
    func updateViews() {
        
        eventsBarButtonItem.title = APIManager.shared.scanEvents.first?.name ?? "Loading"
    }
    
    // MARK: Actions
    
    func cancel() {
        delegate?.scannerViewControllerDidCancel(scannerViewController: self)
    }
    
    func inputModeControlValueChanged() {
        
        
    }
    
    func scanEventsUpdated() {
        updateViews()
    }
    
    func selectScanEvent() {
        
        
    }
}
