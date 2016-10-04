//
//  NotificationController.swift
//  MHacksWatch Extension
//
//  Created by Manav Gabhawala on 10/3/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import WatchKit
import Foundation
import UserNotifications


class NotificationController: WKUserNotificationInterfaceController {
    
    @IBOutlet var titleLabel: WKInterfaceLabel!
    @IBOutlet var descriptionLabel: WKInterfaceLabel!
    
    func createUI(title: String, body: String, category: Int)
    {
        titleLabel.setText(title)
        titleLabel.setTextColor(Announcement.Category(rawValue: category).color)
        descriptionLabel.setText(body)
    }
    
    @available(watchOSApplicationExtension 3.0, *)
    override func didReceive(_ notification: UNNotification, withCompletion completionHandler: @escaping (WKUserNotificationInterfaceType) -> Swift.Void) {
        // This method is called when a notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        //
        // After populating your dynamic notification interface call the completion block.
        createUI(title: notification.request.content.userInfo["title"] as? String ?? "", body: notification.request.content.body, category: notification.request.content.userInfo["category"] as? Int ?? 0)

        completionHandler(.custom)
        
    }
    
    
    override func didReceiveRemoteNotification(_ remoteNotification: [AnyHashable : Any], withCompletion completionHandler: @escaping (WKUserNotificationInterfaceType) -> Swift.Void) {
        
        guard let aps = remoteNotification["aps"] as? [String: Any], let alert = aps["alert"] as? [String: Any], let title = remoteNotification["title"] as? String, let body = alert["body"] as? String
        else {
            completionHandler(.default)
            return
        }
        
        createUI(title: title, body: body, category: remoteNotification["category"] as? Int ?? 0)
        completionHandler(.custom)
    }
}
