//
//  ScheduleViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/8/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

extension ScheduleItem: Comparable {
    public static func <(lhs: ScheduleItem, rhs: ScheduleItem) -> Bool {
        return Int(lhs.startTime!)! < Int(rhs.startTime!)!
    }
}

/**
 A UIPageViewController! This is its own dataSource, so it instantiates schedule days with sorted schedule items.
 Once a view controller has been created, while the user is on the schedule, that day is stored in memory for reuse.
 The user is taken to the current day initially, or the first day if before the event, or the last day if after the event
 */
class ScheduleViewController: UIPageViewController {
    
    var scheduleDays: [ScheduleDay]?
    var scheduleLabelTexts: [String]? {
        get {
            guard let days = scheduleDays else {
                return nil
            }
            return days.map({ $0.date! })
        }
    }
    
    var viewControllerDict = [String: ScheduleDayViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
    }
    
    func loadViewControllers() {
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        var monthString: String
        if (month < 10) {
            monthString = "0" + String(month)
        } else {
            monthString = String(month)
        }
        let day = calendar.component(.day, from: date)
        var dayString: String
        if (day < 10) {
            dayString = "0" + String(day)
        } else {
            dayString = String(day)
        }
        let today: String =  monthString + "/" + dayString + "/" + String(year)
        
        for index in 0..<scheduleDays!.count {
            if scheduleDays?[index].date! == today {
                if let day = scheduleDays?[index] {
                    let dayLabel = scheduleLabelTexts![index]
                    let dayVC = newPage(forDay: day, dayName: dayLabel)
                    
                    viewControllerDict[dayLabel] = dayVC
                    setViewControllers([dayVC], direction: .forward, animated: false, completion: nil)
                    return
                }
            }
        }
        
        var lastEventDateArray = scheduleDays![scheduleDays!.count - 1].date!.split(separator: "/")
        var firstEventDateArray = scheduleDays![0].date!.components(separatedBy: "/")
        
        let yearBefore:Bool = Int(String(lastEventDateArray[2]))! < year
        let monthBefore:Bool = (Int(String(lastEventDateArray[2]))! == year && Int(String(lastEventDateArray[0]))! < month)
        let dayBefore:Bool = (Int(String(lastEventDateArray[2]))! == year && Int(String(lastEventDateArray[0]))! == month && Int(String(lastEventDateArray[1]))! < day)
        
        let yearAfter:Bool = Int(String(firstEventDateArray[2]))! > year
        let monthAfter:Bool = (Int(String(firstEventDateArray[2]))! == year && Int(String(firstEventDateArray[0]))! > month)
        let dayAfter:Bool = (Int(String(firstEventDateArray[2]))! == year && Int(String(firstEventDateArray[0]))! == month && Int(String(firstEventDateArray[1]))! > day)
        
        // If all the events happened before today, show the last event, else if all the events have yet to happen, show the first day
        if (yearBefore || monthBefore || dayBefore) {
            if let day = scheduleDays?[scheduleDays!.count - 1] {
                let dayLabel = scheduleLabelTexts![scheduleDays!.count - 1]
                let dayVC = newPage(forDay: day, dayName: dayLabel)
                
                viewControllerDict[dayLabel] = dayVC
                setViewControllers([dayVC], direction: .forward, animated: false, completion: nil)
            }
        } else if (yearAfter || monthAfter || dayAfter) {
            if let day = scheduleDays?[0] {
                let dayLabel = scheduleLabelTexts![0]
                let dayVC = newPage(forDay: day, dayName: dayLabel)
                
                viewControllerDict[dayLabel] = dayVC
                setViewControllers([dayVC], direction: .forward, animated: false, completion: nil)
            }
        }
    }
}

extension ScheduleViewController: UIPageViewControllerDelegate {
    
}

extension ScheduleViewController: UIPageViewControllerDataSource {
    func newPage(forDay day: ScheduleDay, dayName: String) -> ScheduleDayViewController {
        let newVC = storyboard?.instantiateViewController(withIdentifier: "ScheduleDayPrototype") as! ScheduleDayViewController
        if day.items?.count ?? 0 > 0 {
            newVC.scheduleItems = (Array(day.items!) as? [ScheduleItem])?.sorted()
        }
        
        let weekDate = day.date!
        let dayOfWeek = getDayOfWeek(weekDate)
        let formattedWeekDate = formatDate(weekDate)
        newVC.dayLabelText = dayOfWeek + " " + formattedWeekDate
        newVC.dayLabelDate = day.date!
        viewControllerDict[dayName] = newVC
        newVC.view.frame = view.frame
        return newVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let dayVC = viewController as? ScheduleDayViewController {
            
            let vcIndex = scheduleLabelTexts!.index(of: dayVC.dayLabelDate)!
            
            if 0 < vcIndex {
                let newIndex = vcIndex-1
                let newDayLabel = scheduleLabelTexts![newIndex]
                if let existingVC = viewControllerDict[newDayLabel] {
                    return existingVC
                }
                else {
                    let day = scheduleDays![newIndex]
                    return newPage(forDay: day, dayName: newDayLabel)
                }
            }
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let dayVC = viewController as? ScheduleDayViewController {
            
            //      let vcIndex = scheduleLabelTexts!.index(of: dayVC.dayLabelDate) as! Int
            let vcIndex = scheduleLabelTexts!.index(of: dayVC.dayLabelDate)!
            
            if vcIndex < scheduleDays!.count-1 {
                let newIndex = vcIndex+1
                let newDayLabel = scheduleLabelTexts![newIndex]
                if let existingVC = viewControllerDict[newDayLabel] {
                    return existingVC
                }
                else {
                    let day = scheduleDays![newIndex]
                    return newPage(forDay: day, dayName: newDayLabel)
                }
            }
        }
        return nil
    }
}

// day of week algorithm from
// https://stackoverflow.com/questions/25533147/get-day-of-week-using-nsdate
func getDayOfWeek(_ today:String) -> String {
    let formatter  = DateFormatter()
    formatter.dateFormat = "MM-dd-yyyy"
    guard let todayDate = formatter.date(from: today) else { return "" }
    let myCalendar = Calendar(identifier: .gregorian)
    let weekDay = myCalendar.component(.weekday, from: todayDate)
    
    let mappings = [1: "Sunday",
                    2: "Monday",
                    3: "Tuesday",
                    4: "Wednesday",
                    5: "Thursday",
                    6: "Friday",
                    7: "Saturday"]
    
    return mappings[weekDay]!
}

func formatDate(_ date: String) -> String {
    
    // mapping month numbers to month names
    let months = [01: "January",
                  02: "February",
                  03: "March",
                  04: "April",
                  05: "May",
                  06: "June",
                  07: "July",
                  08: "August",
                  09: "September",
                  10: "October",
                  11: "November",
                  12: "December"] as [Int: String]
    
    // splitting up the date string into components
    let dateSegments = date.components(separatedBy: "/")
    let mm: Int = (dateSegments[0] as NSString).integerValue
    let dd: Int = (dateSegments[1] as NSString).integerValue
    let yyyy = dateSegments[2]
    
    // determining the proper superscript to add to the day
    var superscript: String;
    switch dd {
    case 1:
        superscript = "st"
    case 2:
        superscript = "nd"
    case 3:
        superscript = "rd"
    default:
        superscript = "th"
    }
    
    // recombining the datestring back together
    return months[mm]! + " " + String(dd) + superscript + " " + yyyy
}
