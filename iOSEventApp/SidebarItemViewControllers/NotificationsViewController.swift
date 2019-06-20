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
    var scheduleItems: [ScheduleItem]?
    var hasRecentEvent = true
    var hasNextEvent = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerLabel.text = welcomeMessage
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 225
        
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let loader = DataController(newPersistentContainer: container)
        scheduleItems = loader.fetchAllObjects(onContext: container.viewContext, forName: "ScheduleItem") as? [ScheduleItem]
        print("Date format: \(scheduleItems![0].day?.date)")
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
        if let _ = UserDefaults.standard.string(forKey: "currentEvent") {
            return (notificationArray?.count ?? 0) + 2
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationTableViewCell

        if indexPath.row > 1 {
            
            cell.titleLabel.text = notificationArray?[indexPath.row - 2].title
            cell.bodyTextView.text = notificationArray?[indexPath.row - 2].body
            let dateString : String = (notificationArray?[indexPath.row - 2].date) ?? ""
            print("DateString: \(dateString)")
            cell.dateLabel.text = String(dateString[..<dateString.index(dateString.startIndex, offsetBy: 10)])
            
        } else if indexPath.row == 1 {
            // Get most recent event
            if let mostRecentItem: ScheduleItem = findMostRecentEvent() {
                cell.titleLabel.text = "Most Recently"
                // Format date string
                let date = Date()
                let yesterdate: Date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                let today = formatter.string(from: date)
                let yesterday = formatter.string(from: yesterdate)
                let startTime = formatTime(mostRecentItem.startTime!)
                if mostRecentItem.day?.date == today {
                    cell.dateLabel.text = "Today at \(startTime)"
                } else if mostRecentItem.day?.date == yesterday {
                    cell.dateLabel.text = "Yesterday at \(startTime)"
                } else {
                    // Shouldn't happen
                    print("Something went wrong and the most recent item was on \(mostRecentItem.day?.date!)")
                    cell.dateLabel.text = mostRecentItem.day?.date
                }
                cell.bodyTextView.text = "\(mostRecentItem.itemDescription!)"
                if mostRecentItem.location != "null" {
                    cell.bodyTextView.text += " at:\n\(mostRecentItem.location!)"
                }
                hasRecentEvent = true
            } else {
                hasRecentEvent = false
            }
            
        } else {
            // Get upcoming event
            if let nextItem: ScheduleItem = findNextEvent() {
                cell.titleLabel.text = "Upcoming"
                // Format date string
                let date = Date()
                let tomorrowDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                let today = formatter.string(from: date)
                let tomorrow = formatter.string(from: tomorrowDate)
                let startTime = formatTime(nextItem.startTime!)
                if nextItem.day?.date == today {
                    cell.dateLabel.text = "Today at \(startTime)"
                } else if nextItem.day?.date == tomorrow {
                    cell.dateLabel.text = "Tomorrow at \(startTime)"
                } else {
                    // Shouldn't happen
                    print("Something went wrong and the next item was on \(nextItem.day?.date!)")
                    cell.dateLabel.text = nextItem.day?.date
                }
                cell.bodyTextView.text = "\(nextItem.itemDescription!)"
                if nextItem.location != "null" {
                    cell.bodyTextView.text += " at:\n\(nextItem.location!)"
                }
                hasNextEvent = true
            } else {
                hasNextEvent = false
            }
            
        }
        return cell
        
    }
    
    /// Sets the height for rows to 0 if there is no upcoming or recent event
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 && !hasNextEvent {
            return 0.0
        } else if indexPath.row == 1 && !hasRecentEvent {
            return 0.0
        }
        return UITableView.automaticDimension
    }
    
    func findMostRecentEvent() -> ScheduleItem? {
        var result: ScheduleItem
        let date = Date()
        let yesterdate: Date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let today = formatter.string(from: date)
        let yesterday = formatter.string(from: yesterdate)
        formatter.dateFormat = "HHmm"
        let now = Int(formatter.string(from: date))!
        result = scheduleItems![0]
        result.startTime = "0000"
        // Loop through today's events
        for item in scheduleItems! {
            if (item.day!.date == today && Int(item.startTime!)! < now && Int(item.startTime!)! > Int(result.startTime!)!) {
                result = item
            }
        }
        // Loop through yesterday's events
        if result.startTime == "0000" {
            for item in scheduleItems! {
                if (item.day!.date == yesterday && Int(item.startTime!)! > Int(result.startTime!)!) {
                    result = item
                }
            }
        }
        
        if result.startTime == "0000" {
            return nil
        } else {
            return result
        }
        
    }
    
    
    func findNextEvent() -> ScheduleItem? {
        var result: ScheduleItem
        let date = Date()
        let tomorrowDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let today = formatter.string(from: date)
        let tomorrow = formatter.string(from: tomorrowDate)
        formatter.dateFormat = "HHmm"
        let now = Int(formatter.string(from: date))!
        result = scheduleItems![0]
        // Loop through today's events
        result.startTime = "9999"
        for item in scheduleItems! {
            if (item.day!.date == today && Int(item.startTime!)! > now && Int(item.startTime!)! < Int(result.startTime!)!) {
                result = item
            }
        }
        // Loop through tomorrow's events
        if result.startTime == "9999" {
            for item in scheduleItems! {
                if (item.day!.date == tomorrow && Int(item.startTime!)! < Int(result.startTime!)!) {
                    result = item
                }
            }
        }
        
        if result.startTime == "9999" {
            return nil
        } else {
            return result
        }
    }
    
    func formatTime(_ time: String) -> String {
        if time.count == 4 {
            if Int(String(time[..<time.index(time.startIndex, offsetBy: 2)]))! < 12 {
            return "\(time[..<time.index(time.startIndex, offsetBy: 2)]):\(time[time.index(time.startIndex, offsetBy: 2)...]) AM"
            } else {
                let afternoonTime = Int(String(time[..<time.index(time.startIndex, offsetBy: 2)]))! - 12
                return "\(afternoonTime):\(time[time.index(time.startIndex, offsetBy: 2)...]) PM"
            }
        } else {
            return "\(time[..<time.index(time.startIndex, offsetBy: 1)]):\(time[time.index(time.startIndex, offsetBy: 1)...]) AM"
        }
        
    }
}
