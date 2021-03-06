//
//  ScheduleDayViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/8/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

extension Theme: Comparable {
    public static func < (lhs: Theme, rhs: Theme) -> Bool {
        guard var id1 = lhs.themeValue, var id2 = rhs.themeValue else {
            return false
        }
        id1 = String(id1.split(separator: "#")[1])
        id2 = String(id2.split(separator: "#")[1])
        return Int(id1, radix:16)! < Int(id2, radix:16)!
    }
}

/**
 Displays schedule items in chronological order in a table view. This class loads
 all contacts for its schedule items so that it can display that in the cells.
 As time is provided in 24 hour time, this class also converts it to AM/PM for display.
 */
class ScheduleDayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dayLabel: UILabel!
    var dayLabelText: String?
    var dayLabelDate: String = ""
    var scheduleItems: [ScheduleItem]?
    var contactsByName = [String: Contact]()
    var themeSections: [Theme]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dayLabel.text = dayLabelText
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 175
        tableView.tableFooterView = UIView()
        
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let loader = DataController(newPersistentContainer: container)
        themeSections = loader.fetchAllObjects(onContext: container.viewContext, forName: "Theme") as? [Theme]
        
        if let schedule = scheduleItems {
            let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            let loader = DataController(newPersistentContainer: container)
            let predicate = NSPredicate(format: "name in %@", schedule.compactMap({ $0.location }))
            let contacts = loader.fetchAllObjects(onContext: container.viewContext, forName: "Contact", withPredicate: predicate, includePropertyValues: true) as? [Contact]
            for contact in contacts ?? [] {
                contactsByName[contact.name ?? ""] = contact
            }
        }
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

        if let location = scheduleItem.location {
            let contact = contactsByName[location]
            var contactInfo = ""
            if let address = contact?.address, let phone = contact?.phone {
                contactInfo = "\(address)\n\(phone)"
            }
            else {
                contactInfo = contact?.address ?? contact?.phone ?? ""
            }
            if location != "null"{
                cell.eventLocation.text = location
            } else {
                cell.eventLocation.text = ""
            }
            cell.contactTextView.text = contactInfo
            if contactInfo == "" {
                cell.contactBottomSpaceConstraint.constant = 0
                cell.contactHeightConstraint.constant = 0
            }
        }
        else {
            cell.eventLocation.text = ""
            cell.contactTextView.text = ""
            cell.contactBottomSpaceConstraint.constant = 0
            cell.contactHeightConstraint.constant = 0
            cell.locationHeightConstraint.constant = 0
        }
        
        let themeArray: [Theme]? = themeSections
        for theme in themeArray! {
            if (theme.themeName == scheduleItem.category!) {
                let themeRGB: String = String((theme.themeValue?.split(separator: "#")[0])!)
                let greenStartIdx = themeRGB.index(themeRGB.startIndex, offsetBy: 2)
                let blueStartIdx = themeRGB.index(greenStartIdx, offsetBy: 2)
                let themeRed:Int = Int(String(themeRGB[..<greenStartIdx]), radix:16)!
                let themeGreen:Int = Int(String(themeRGB[greenStartIdx..<blueStartIdx]), radix:16)!
                let themeBlue:Int = Int(String(themeRGB[blueStartIdx..<themeRGB.endIndex]), radix:16)!
                let themeColor = UIColor(red: CGFloat(themeRed)/256.0, green: CGFloat(themeGreen)/256.0, blue: CGFloat(themeBlue)/256.0, alpha: 0.15)
                cell.backgroundColor = themeColor
                cell.contactTextView.backgroundColor = themeColor.withAlphaComponent(0)
            }
        }
        
        return cell
    }
    
    func amPMTime(twentyFourHour startTime: String, minutesOffset: String) -> String {
        let stringLength = startTime.count
        var startTimeString = startTime
        
        if startTime == "0" {
            startTimeString = "0000"
        }
        
        guard var numericHours = Int(startTimeString.prefix(stringLength-2)), var numericMinutes = Int(startTimeString.suffix(2)), let offset = Int(minutesOffset) else {
            return ""
        }
        
        // Modify values depending on offset
        numericMinutes += offset
        numericHours += numericMinutes / 60 // integer division, which has no decimal
        numericMinutes = numericMinutes % 60 // mod 60, returns remainder
        numericHours %= 24 // In case it loops around to the next day... it will still sort correctly
        
        // Convert to AM/PM
        var amPMSuffix = " AM"
        if numericHours >= 13 && numericHours <= 23 {
            numericHours = numericHours - 12
            amPMSuffix = " PM"
        }
        else if numericHours == 12 {
            amPMSuffix = " PM"
        }
        else if numericHours == 24 || numericHours == 0 {
            numericHours = 12
            // Suffix is am by default
        }
        else {
            // Nothing needs to change
        }
        let zeroPaddedMinutes = String(format: "%02d", numericMinutes)
        return "\(numericHours):\(zeroPaddedMinutes)\(amPMSuffix)"
    }
}

