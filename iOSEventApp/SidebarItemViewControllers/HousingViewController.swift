//
//  HousingViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/9/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

extension HousingUnit: IsComparable {
    var compareString: String? {
        return driver
    }
}

/**
 The housing cells have the driver's name as a header, the host's name and
 contact info on the left, and the name of the people assigned on the right.
 The HousingViewController only loads contacts whose name is a host name.
 */
class HousingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TakesArrayData {
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var headerLabel : UILabel!
    var dataArray: [Any]?
    var contactsByName = [String: Contact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 231
        
        if let housing = dataArray as? [HousingUnit] {
            let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
            let loader = DataController(newPersistentContainer: container)
            let predicate = NSPredicate(format: "name in %@", housing.compactMap({ $0.hostName }))
            let contacts = loader.fetchAllObjects(onContext: container.viewContext, forName: "Contact", withPredicate: predicate, includePropertyValues: true) as? [Contact]
            for contact in contacts ?? [] {
                contactsByName[contact.name ?? ""] = contact
            }
            //after having accessed the event json, retrieve the housing page nav title.
            //get access to the event json and retrieve the schedule page nav title.
            let navNames = loader.fetchAllObjects(onContext: container.viewContext, forName: "SidebarAppearance") as! [SidebarAppearance]
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "housingCell", for: indexPath) as! HousingTableViewCell
        
        let housingUnitArray = dataArray as! [HousingUnit]
        
        if let driver = housingUnitArray[indexPath.row].driver {
            if (indexPath.row != 0 && driver == housingUnitArray[indexPath.row - 1].driver) {
                // Hide Driver cell if the driver for this location is the same as the previous location
                cell.titleHeight.constant = 0
            } else if driver == "" {
                // Hide Driver cell if the driver for this location if the driver field is blank
                cell.titleHeight.constant = 0
            }else {
                cell.titleLabel.text = "Driver: " + driver
            }
        }
        if let name = housingUnitArray[indexPath.row].hostName {
            cell.leftTextView.text = name
            if let address = contactsByName[name]?.address {
                cell.leftTextView.text.append("\n\n\(address)")
                if let phone = contactsByName[name]?.phone {
                    cell.leftTextView.text.append("\n\(phone)")
                }
            }
            else if let phone = contactsByName[name]?.phone {
                cell.leftTextView.text.append("\n\n\(phone)")
            }
        }
        else {
            cell.leftTextView.text = ""
        }
        cell.rightTextView.text = housingUnitArray[indexPath.row].students
        
        return cell
    }
}
