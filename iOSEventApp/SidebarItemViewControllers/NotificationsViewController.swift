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
//    @IBOutlet weak var headerLabel: UILabel!
    var welcomeMessage: String?
    var scheduleItems: [ScheduleItem]?
    var hasRecentEvent = true
    var hasNextEvent = true
    var themeSections: [Theme]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 225
        tableView.tableFooterView = UIView()
        
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let loader = DataController(newPersistentContainer: container)
        scheduleItems = loader.fetchAllObjects(onContext: container.viewContext, forName: "ScheduleItem") as? [ScheduleItem]
        themeSections = loader.fetchAllObjects(onContext: container.viewContext, forName: "Theme") as? [Theme]
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
            guard dateString.count > 10 else {
                print("date String too short! \(dateString)")
                cell.dateLabel.text = dateString
                return cell
            }
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
                    print("Something went wrong and the most recent item was on \(String(describing: mostRecentItem.day?.date!))")
                    cell.dateLabel.text = mostRecentItem.day?.date
                }
                cell.bodyTextView.text = "\(mostRecentItem.itemDescription!)"
                if mostRecentItem.location != "null" {
                    cell.bodyTextView.text += " at:\n\(mostRecentItem.location!)"
                }
                
                let themeArray: [Theme]? = themeSections
                for theme in themeArray! {
                    if (theme.themeName == mostRecentItem.category!) {
                        let themeRGB: String = String((theme.themeValue?.split(separator: "#")[0])!)
                        let greenStartIdx = themeRGB.index(themeRGB.startIndex, offsetBy: 2)
                        let blueStartIdx = themeRGB.index(greenStartIdx, offsetBy: 2)
                        let themeRed:Int = Int(String(themeRGB[..<greenStartIdx]), radix:16)!
                        let themeGreen:Int = Int(String(themeRGB[greenStartIdx..<blueStartIdx]), radix:16)!
                        let themeBlue:Int = Int(String(themeRGB[blueStartIdx..<themeRGB.endIndex]), radix:16)!
                        let themeColor = UIColor(red: CGFloat(themeRed)/256.0, green: CGFloat(themeGreen)/256.0, blue: CGFloat(themeBlue)/256.0, alpha: 0.15)
                        cell.backgroundColor = themeColor
                        cell.bodyTextView.backgroundColor = themeColor.withAlphaComponent(0)
                    }
                }
                
                
                hasRecentEvent = true
            } else {
                hasRecentEvent = false
            }
            
            
            
        } else {
            // Get upcoming event
            if let nextItem: ScheduleItem = findNextEvent() {
//                print(nextItem.day?.date)
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
                    print("Something went wrong and the next item was on \(String(describing: nextItem.day?.date!))")
                    cell.dateLabel.text = nextItem.day?.date
                }
                cell.bodyTextView.text = "\(nextItem.itemDescription!)"
                if nextItem.location != "null" {
                    cell.bodyTextView.text += " at:\n\(nextItem.location!)"
                }
                
                let themeArray: [Theme]? = themeSections
                for theme in themeArray! {
                    if (theme.themeName == nextItem.category!) {
                        let themeRGB: String = String((theme.themeValue?.split(separator: "#")[0])!)
                        let greenStartIdx = themeRGB.index(themeRGB.startIndex, offsetBy: 2)
                        let blueStartIdx = themeRGB.index(greenStartIdx, offsetBy: 2)
                        let themeRed:Int = Int(String(themeRGB[..<greenStartIdx]), radix:16)!
                        let themeGreen:Int = Int(String(themeRGB[greenStartIdx..<blueStartIdx]), radix:16)!
                        let themeBlue:Int = Int(String(themeRGB[blueStartIdx..<themeRGB.endIndex]), radix:16)!
                        let themeColor = UIColor(red: CGFloat(themeRed)/256.0, green: CGFloat(themeGreen)/256.0, blue: CGFloat(themeBlue)/256.0, alpha: 0.15)
                        cell.backgroundColor = themeColor
                        cell.bodyTextView.backgroundColor = themeColor.withAlphaComponent(0)
                    }
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
            if (item.day!.date == today && Int(item.startTime!)! <= now && Int(item.startTime!)! > Int(result.startTime!)!) {
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
            if (item.day?.date == today && Int(item.startTime ?? "0")! > now && Int(item.startTime ?? "0")! < Int(result.startTime ?? "0")!) {
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
            } else if Int(String(time[..<time.index(time.startIndex, offsetBy: 2)]))! == 12 {
                return "12:\(time[time.index(time.startIndex, offsetBy: 2)...]) PM"
            } else if Int(String(time[..<time.index(time.startIndex, offsetBy: 2)]))! == 24 || Int(String(time[..<time.index(time.startIndex, offsetBy: 2)]))! == 00 {
                return "12:\(time[time.index(time.startIndex, offsetBy: 2)...]) AM"
            } else {
                let afternoonTime = Int(String(time[..<time.index(time.startIndex, offsetBy: 2)]))! - 12
                return "\(afternoonTime):\(time[time.index(time.startIndex, offsetBy: 2)...]) PM"
            }
        } else {
            if Int(String(time[..<time.index(time.startIndex, offsetBy: 1)])) == 0 {
                return "12:\(time[time.index(time.startIndex, offsetBy: 1)...]) AM"
            }
            return "\(time[..<time.index(time.startIndex, offsetBy: 1)]):\(time[time.index(time.startIndex, offsetBy: 1)...]) AM"
        }
        
    }
}
