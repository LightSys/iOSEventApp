//
//  ScheduleDayViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/8/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

class ScheduleDayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var dayLabel: UILabel!
  var dayLabelText: String?
  var scheduleItems: [ScheduleItem]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    dayLabel.text = dayLabelText
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 175
  }
  
  // MARK: - Table view data source
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return scheduleItems?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath) as! ScheduleTableViewCell
    
    let row = indexPath.row
    let scheduleItem = scheduleItems![row]
    cell.startLabel.text = amPMTime(twentyFourHour: scheduleItem.startTime!, minutesOffset: "0")
    cell.endLabel.text = amPMTime(twentyFourHour: scheduleItem.startTime!, minutesOffset: scheduleItem.length!)
    cell.eventName.text = scheduleItem.itemDescription ?? ""
    cell.eventLocation.text = scheduleItem.location ?? "" // GET contact info!!!
    cell.contactTextView.text = ""

    return cell
  }
  
  // TEST 0000
  func amPMTime(twentyFourHour startTime: String, minutesOffset: String) -> String {
    let stringLength = startTime.count
    
    guard var numericHours = Int(startTime.prefix(stringLength-2)), var numericMinutes = Int(startTime.suffix(2)), let offset = Int(minutesOffset) else {
      return ""
    }
    
    // Modify values depending on offset
    numericMinutes += offset
    numericHours += numericMinutes / 60 // integer division, which has no decimal
    numericMinutes = numericMinutes % 60 // mod 60, returns remainder
    
    // Convert to AM/PM
    var amPMSuffix = " AM"
    if numericHours >= 13 && numericHours <= 23 {
      numericHours = numericHours - 12
      amPMSuffix = " PM"
    }
    else if numericHours == 12 {
      amPMSuffix = " PM"
    }
    else if numericHours == 24 {
      numericHours = 12
    }
    else {
      // Nothing needs to change
    }
    let zeroPaddedMinutes = String(format: "%02d", numericMinutes)
    return "\(numericHours):\(zeroPaddedMinutes)\(amPMSuffix)"
  }
}

