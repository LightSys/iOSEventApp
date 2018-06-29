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
  The user is taken to the current day initially, or the first day if not during the event.
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
    if let day = scheduleDays?[0] {
      let dayLabel = scheduleLabelTexts![0]
      let dayVC = newPage(forDay: day, dayName: dayLabel)
      
      viewControllerDict[dayLabel] = dayVC
      setViewControllers([dayVC], direction: .forward, animated: false, completion: nil)
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
    newVC.dayLabelText = day.date
    viewControllerDict[dayName] = newVC
    newVC.view.frame = view.frame
    return newVC
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    if let dayVC = viewController as? ScheduleDayViewController {
      let vcIndex = scheduleLabelTexts!.index(of: dayVC.dayLabel.text!)!
      
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
      let vcIndex = scheduleLabelTexts!.index(of: dayVC.dayLabel.text!)!
      
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
