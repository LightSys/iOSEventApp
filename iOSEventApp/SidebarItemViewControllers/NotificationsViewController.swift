//
//  NotificationsViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/6/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

extension Notification: Comparable {
  public static func < (lhs: Notification, rhs: Notification) -> Bool {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
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
    return notificationArray?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableViewCell
    
    cell.titleLabel.text = notificationArray?[indexPath.row].title
    cell.bodyTextView.text = notificationArray?[indexPath.row].body
    cell.dateLabel.text = notificationArray?[indexPath.row].date

    return cell
  }
}
