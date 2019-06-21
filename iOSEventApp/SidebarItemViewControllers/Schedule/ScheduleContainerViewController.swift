//
//  ScheduleContainerViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/8/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

/**
 This view controller doesn't do a lot. It (in the storyboard) has a header, which means
 that the ScheduleViewController just has to present its days in the order given to it.
 */
class ScheduleContainerViewController: UIViewController, TakesArrayData {
    
//    @IBOutlet weak var headerLabel: UILabel!
    var dataArray: [Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //get access to the event json and retrieve the schedule page nav title.
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let loader = DataController(newPersistentContainer: container)
        let navNames = loader.fetchAllObjects(onContext: container.viewContext, forName: "SidebarAppearance") as! [SidebarAppearance]
        
        //get access to the schedule days and load them.
        if let scheduleVC = (children.first as? ScheduleViewController), (dataArray?.count ?? 0) > 0 {
            scheduleVC.scheduleDays = (dataArray as? [ScheduleDay])?.sorted(by: { (day1, day2) -> Bool in
                return day1.date! < day2.date!
            })
            scheduleVC.loadViewControllers()
        }
    }
}

