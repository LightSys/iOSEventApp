//
//  NotificationsViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/6/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit
import os.log

extension Notification: Comparable {
    public static func < (lhs: Notification, rhs: Notification) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        guard let dateString1 = lhs.date, let date1 = dateFormatter.date(from: dateString1), let dateString2 = rhs.date, let date2 = dateFormatter.date(from: dateString2) else {
            return false
        }
        return date1 < date2
    }
}

/**
 Displays notifications in the order provided.
 */
class NotificationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var notificationArray: [Notification]?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerLabel: UILabel!
    var welcomeMessage: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.text = welcomeMessage
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 225
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Add 2 rows for upcoming/recent events
        return (notificationArray?.count ?? 0) + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableViewCell

        if indexPath.row > 1 {
            
            cell.titleLabel.text = notificationArray?[indexPath.row - 2].title
            cell.bodyTextView.text = notificationArray?[indexPath.row - 2].body
            let dateString : String = (notificationArray?[indexPath.row - 2].date) ?? ""
            cell.dateLabel.text = String(dateString[..<dateString.index(dateString.startIndex, offsetBy: 10)])
            
        } else if indexPath.row == 1 {
            // Get most recent event
            cell.titleLabel.text = "Most Recently"
            
            
        } else {
            // Get upcoming event
            cell.titleLabel.text = "Upcoming"
            
        }
        return cell
        
    }
}
