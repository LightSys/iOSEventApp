//
//  SidebarTableViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/6/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

protocol ViewControllerSwitching:AnyObject {
  func switchTo(vcName: String, entityNameForData: String?, informationPageName pageName: String?)
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
  
  func loadSidebarItemsIfNeeded() {
    guard variableSidebarItems.count == 0 else {
      return
    }
    reloadSidebarItems()
  }
  
  func reloadSidebarItems() {
    let loader = DataController(newPersistentContainer:
      (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
    
    let sidebarItems = (loader.fetchAllObjects(forName: "SidebarAppearance")
      as! [SidebarAppearance]).sorted(by: { (item1, item2) -> Bool in
        return item1.order! < item2.order!
      })
    variableSidebarItems = sidebarItems
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
    return variableSidebarItems.count + 2 // About, and Settings
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.row {
    case 0...(variableSidebarItems.count == 0 ? 0 : variableSidebarItems.count-1):
      if variableSidebarItems.count > 0 {
        if variableSidebarItems[indexPath.row].nav == "Notifications" {
          vcSwitchingDelegate?.switchTo(vcName: "notifications", entityNameForData: nil, informationPageName: nil)
        }
        else if variableSidebarItems[indexPath.row].nav == "Contacts" {
          vcSwitchingDelegate?.switchTo(vcName: "contacts", entityNameForData: nil, informationPageName: nil)
        }
        else if variableSidebarItems[indexPath.row].nav == "Housing" {
          vcSwitchingDelegate?.switchTo(vcName: "housing", entityNameForData: "HousingUnit", informationPageName: nil)
        }
        else if variableSidebarItems[indexPath.row].nav == "Schedule" {
          vcSwitchingDelegate?.switchTo(vcName: "schedule", entityNameForData: "ScheduleDay", informationPageName: nil)
        }
        else if variableSidebarItems[indexPath.row].nav == "Prayer Partners" {
          vcSwitchingDelegate?.switchTo(vcName: "prayerPartners", entityNameForData: "PrayerPartnerGroup", informationPageName: nil)
        }
        else {
          vcSwitchingDelegate?.switchTo(vcName: "informationPage", entityNameForData: "InformationPage", informationPageName: variableSidebarItems[indexPath.row].nav)
        }
      }
      print("case \(indexPath.row)")
    case variableSidebarItems.count:
      print("About selected")
    default:
      vcSwitchingDelegate?.switchTo(vcName: "settings", entityNameForData: nil, informationPageName: nil)
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "sidebarCell", for: indexPath) as! SidebarTableViewCell
    
    let row = indexPath.row
    if row < variableSidebarItems.count {
      cell.sideImageView.image = UIImage(named: variableSidebarItems[row].icon!)
      cell.label.text = variableSidebarItems[row].nav!
    }
    else if row == variableSidebarItems.count {
      cell.sideImageView.image = UIImage(named: "ic_info")
      cell.label.text = "About"
    }
    else {
      cell.sideImageView.image = nil
      cell.label.text = "Settings"
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let loader = DataController(newPersistentContainer:
      (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
    
    if let imageData = (loader.fetchAllObjects(forName: "General")?.first as? General)?.logo {
      let image = UIImage(data: imageData)
      let imageView = UIImageView(image: image)
      return imageView
    }
    return nil
  }
}

