//
//  InterfaceController.swift
//  MHacksWatch Extension
//
//  Created by Manav Gabhawala on 10/3/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import WatchKit
import Foundation

class WatchAnnouncementCell: NSObject
{
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var descriptionLabel: WKInterfaceLabel!
    @IBOutlet var dateLabel: WKInterfaceLabel!
}

class InterfaceController: WKInterfaceController {
    
    @IBOutlet var tableView : WKInterfaceTable!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        setTitle("MHacks")
        APIManager.shared.updateAnnouncements()
    }
    
    override func willActivate() {
        super.willActivate()
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableView(_:)), name: APIManager.AnnouncementsUpdatedNotification, object: nil)
        APIManager.shared.updateAnnouncements()
        updateTableView(Notification(name: APIManager.AnnouncementsUpdatedNotification))
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        NotificationCenter.default.removeObserver(self)
    }
    
    func updateTableView(_ : Notification) {
        DispatchQueue.main.async {
            self.tableView.setNumberOfRows(APIManager.shared.announcements.count, withRowType: "announcementCell")
            for (i, announcement) in APIManager.shared.announcements.enumerated()
            {
                let cell = self.tableView.rowController(at: i) as! WatchAnnouncementCell
                cell.titleLabel.setText(announcement.title)
                cell.titleLabel.setTextColor(announcement.category.color)
                cell.descriptionLabel.setText(announcement.message)
                cell.dateLabel.setText(announcement.localizedDate)
            }
        }
    }
}

extension APIManager {
    func showNetworkIndicator() {}
    func hideNetworkIndicator() {}
}
