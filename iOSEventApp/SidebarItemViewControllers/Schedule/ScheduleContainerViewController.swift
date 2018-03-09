//
//  ScheduleContainerViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/8/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

class ScheduleContainerViewController: UIViewController, TakesArrayData {
  
  var dataArray: [Any]?
  
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let scheduleVC = (childViewControllers.first as? ScheduleViewController), (dataArray?.count ?? 0) > 0 {
      scheduleVC.scheduleDays = (dataArray as? [ScheduleDay])?.sorted(by: { (day1, day2) -> Bool in
        return day1.date! < day2.date!
      })
      scheduleVC.loadViewControllers()
    }
    
    // Do any additional setup after loading the view.
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

