//
//  ScheduleViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/8/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

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
  
  var viewControllerDict = [String: ScheduleDayTableViewController]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    dataSource = self
    // Do any additional setup after loading the view.
  }
  
  func loadViewControllers() {
    if let day = scheduleDays?[0] {
      let dayLabel = scheduleLabelTexts![0]
      let dayVC = newPage(forDay: day, dayName: dayLabel)
      
      viewControllerDict[dayLabel] = dayVC
      setViewControllers([dayVC], direction: .forward, animated: false, completion: nil)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

extension ScheduleViewController: UIPageViewControllerDelegate {
  
}

extension ScheduleViewController: UIPageViewControllerDataSource {
  func newPage(forDay day: ScheduleDay, dayName: String) -> ScheduleDayTableViewController {
    let newVC = storyboard?.instantiateViewController(withIdentifier: "ScheduleDayPrototype") as! ScheduleDayTableViewController
    if day.items?.count ?? 0 > 0 {
      newVC.scheduleItems = Array(day.items!) as? [ScheduleItem]
      newVC.scheduleItems?.sort() // This is to handle the am/pm string sort mixup introduced by the above line
    }
    newVC.dayLabelText = day.date
    viewControllerDict[dayName] = newVC
    newVC.view.frame = view.frame
    return newVC
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    if let dayVC = viewController as? ScheduleDayTableViewController {
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
    if let dayVC = viewController as? ScheduleDayTableViewController {
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

extension ScheduleItem: Comparable {
  public static func <(lhs: ScheduleItem, rhs: ScheduleItem) -> Bool {
    return Int(lhs.startTime!)! < Int(rhs.startTime!)!
  }
}
