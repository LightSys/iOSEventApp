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
    let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    let loader = DataController(newPersistentContainer: container)
    let context = container.viewContext

    let sidebarItems = (loader.fetchAllObjects(onContext: context, forName: "SidebarAppearance")
      as! [SidebarAppearance]).sorted(by: { (item1, item2) -> Bool in
        return item1.order! < item2.order!
      })
    variableSidebarItems = sidebarItems
  }
  
  override func viewDidLoad() {
    let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    let loader = DataController(newPersistentContainer: container)
    let context = container.viewContext

    if let data = (loader.fetchAllObjects(onContext: context, forName: "General")?.first as? General)?.logo, let imageData = Data(base64Encoded: data) {
      let image = UIImage(data: imageData)
      let imageView = UIImageView(image: image)
      // Shrink image view's width (and keep aspect ratio)
      let maxWidth = view.frame.size.width
      if imageView.frame.size.width > maxWidth {
        imageView.frame.size.height *= maxWidth / imageView.frame.size.width
        imageView.frame.size.width = maxWidth
      }
      // Shrink image view's height (and keep aspect ratio)
      let maxHeight: CGFloat = 160
      if imageView.frame.size.height > maxHeight {
        imageView.frame.size.width *= maxHeight / imageView.frame.size.height
        imageView.frame.size.height = maxHeight
      }
      // To prevent the image view from stretching and provide a background.
      let containingView = UIView(frame: CGRect(x: 0, y: 0, width: maxWidth, height: imageView.frame.size.height))
      
      // Background
      let background = CAGradientLayer()
      background.colors = [UIColor(red: 111/256.0, green: 148/256.0, blue: 221/256.0, alpha: 1).cgColor, UIColor.blue.cgColor]
      // Make the gradient horizontal instead of vertical
      background.transform = CATransform3DMakeRotation(CGFloat.pi / 2, 0, 0, 1)
      background.frame = containingView.frame // Must come after the transform

      // Add views and layers
      containingView.layer.addSublayer(background)
      containingView.addSubview(imageView)
      tableView.tableHeaderView = containingView
    }
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return variableSidebarItems.count + 2 // About and Settings are constant
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
    case variableSidebarItems.count:
      print("About selected")
    default:
      vcSwitchingDelegate?.switchTo(vcName: "settings", entityNameForData: nil, informationPageName: nil)
    }
    tableView.deselectRow(at: indexPath, animated: true)
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
}

