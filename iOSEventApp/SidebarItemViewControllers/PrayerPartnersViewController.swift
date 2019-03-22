//
//  PrayerPartnersTableViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/6/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

extension PrayerPartnerGroup: IsComparable {
  var compareString: String? {
    return String(order)
  }
}

/**
 Displays prayer partners in the order provided. When it loads cells, it does
  a one-time extraction of the partner names (the part displayed in the cells)
 */
class PrayerPartnersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TakesArrayData {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var headerLabel: UILabel!
  var dataArray: [Any]?
  lazy var stringArray: [String]? = {
      return (dataArray as? [PrayerPartnerGroup])?.map({ $0.students! })
  }()
  
  let cellReuseIdentifier = "prayerPartnersReuseIdentifier"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //get access to the event json and retrieve the prayer partners nav title.
    let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    let loader = DataController(newPersistentContainer: container)
    let navNames = loader.fetchAllObjects(onContext: container.viewContext, forName: "SidebarAppearance") as! [SidebarAppearance]
    for navName in navNames {
      if (navName.category == "PrayerPartners") {
        headerLabel.text = navName.nav
      }
    }
  }
  
  // MARK: - Table view data source
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataArray?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: PrayerPartnersTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! PrayerPartnersTableViewCell
    
    cell.groupNumberLabel.text = "Group ".appending(String(indexPath.row + 1))
    cell.partnersLabel.text = stringArray![indexPath.row]
    
    return cell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 120
  }
}
