//
//  SidebarTableViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/6/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

protocol ViewControllerSwitching:AnyObject {
  func switchTo(vcName: String, entityNameForData: String)
}

class SidebarTableViewController: UITableViewController {
  
  weak var vcSwitchingDelegate: ViewControllerSwitching?
  
  var _variableSidebarItems = [SidebarAppearance]()
  var variableSidebarItems: [SidebarAppearance] {
    get {
      return _variableSidebarItems
    }
    set {
      _variableSidebarItems = newValue
      tableView.reloadData()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {

    super.viewWillAppear(animated)
    
    
    
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return variableSidebarItems.count + 3 // Notifications, About, and Settings
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.row {
    case 0:
      vcSwitchingDelegate?.switchTo(vcName: "notifications", entityNameForData: "")
    case 1...(variableSidebarItems.count == 0 ? 1 : variableSidebarItems.count):
      if variableSidebarItems.count > 0 {
        if variableSidebarItems[indexPath.row-1].nav == "Prayer Partners" {
          vcSwitchingDelegate?.switchTo(vcName: "prayerPartners", entityNameForData: "PrayerPartnerGroup")
        }
      }
      print("case \(indexPath.row)")
    case variableSidebarItems.count+1:
      print("About selected")
    default:
      print("Settings selected")
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "sidebarCell", for: indexPath) as! SidebarTableViewCell
    
    let row = indexPath.row
    if row == 0 {
//      cell.sideImageView.image = UIImage(imageLiteralResourceName: "ic_bell")
      cell.label.text = "Notifications"
    }
    else if row <= variableSidebarItems.count {
//      cell.sideImageView.image = UIImage(imageLiteralResourceName: variableSidebarItems[row-1].icon!)
      cell.label.text = variableSidebarItems[row-1].nav!
    }
    else if row == variableSidebarItems.count+1 {
//      cell.sideImageView.image = UIImage(imageLiteralResourceName: "ic_info")
      cell.label.text = "About"
    }
    else {
//      cell.sideImageView.image = nil
      cell.label.text = "Settings"
    }
    return cell
  }
}
