//
//  TodayViewController.swift
//  MHacksToday
//
//  Created by Manav Gabhawala on 2/6/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit
import NotificationCenter


class TodayViewController: UIViewController, NCWidgetProviding {
	
	@IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        extensionContext?.widgetLargestAvailableDisplayMode = .expanded
		tableView.delegate = self
		tableView.dataSource = self
		tableView.separatorEffect = UIVibrancyEffect.widgetPrimary()
		tableView.separatorColor = UIColor(white: 1.0, alpha: 0.6)
		tableView.separatorInset = .zero
    }
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		APIManager.shared.updateAnnouncements()
		tableView.reloadData()
		updatePreferredContentSize()
	}

    func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Void) {
        APIManager.shared.updateAnnouncements {
            guard $0
                else {
                    completionHandler(.noData)
                    return
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            completionHandler(.newData)
        }
	}
	
	func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
		defer { tableView.setNeedsUpdateConstraints() }
		return .zero
	}
		
	func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize)
    {
        tableView.reloadData()
        updatePreferredContentSize()
    }
	func updatePreferredContentSize()
	{
        preferredContentSize = CGSize(width: preferredContentSize.width, height: tableView.rowHeight * CGFloat(tableView(tableView, numberOfRowsInSection: 0)))
	}
}

extension TodayViewController: UITableViewDelegate, UITableViewDataSource
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		if extensionContext?.widgetActiveDisplayMode == .compact
        {
            return min(2, APIManager.shared.announcements.count)
        }
        return min(5, APIManager.shared.announcements.count)
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
        let cell = tableView.dequeueReusableCell(withIdentifier: "Announcement Cell", for: indexPath) as! AnnouncementCell
        
        let announcement = APIManager.shared.announcements[(indexPath as NSIndexPath).row]
        
        cell.titleLabel.text = announcement.title
        cell.dateLabel.text = announcement.localizedDate
        
        cell.colorView.backgroundColor = announcement.category.color
        
		return cell
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		tableView.deselectRow(at: indexPath, animated: false)
		extensionContext?.open(URL(string: "mhacks://announcements")!, completionHandler: nil)
	}
}

