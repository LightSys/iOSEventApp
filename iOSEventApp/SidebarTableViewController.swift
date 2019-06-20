//
//  SidebarTableViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/6/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

protocol MenuDelegate:AnyObject {
    func switchTo(vcName: String, entityNameForData: String?, informationPageName pageName: String?)
    func swipedToClose()
}
/**
 Loads the SidebarAppearances and tells the RootViewController what view controller to load with what data.
 */
class SidebarTableViewController: UITableViewController {
    
    weak var menuDelegate: MenuDelegate?
    
    var _variableSidebarItems = [SidebarAppearance]()
    var variableSidebarItems: [SidebarAppearance] {
        get {
            return _variableSidebarItems
        }
        set {
            _variableSidebarItems = newValue
            tableView.reloadData()
            tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
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
            background.colors = [UIColor(red: 0x60/256.0, green: 0x80/256.0, blue: 0xC0/256.0, alpha: 1).cgColor, UIColor(red: 0x30/256.0, green: 0x40/256.0, blue: 0x60/256.0, alpha: 1).cgColor]
            // Make the gradient horizontal instead of vertical
            background.transform = CATransform3DMakeRotation(CGFloat.pi / 2, 0, 0, 1)
            background.frame = containingView.frame // Must come after the transform
            
            // Add views and layers
            containingView.layer.addSublayer(background)
            containingView.addSubview(imageView)
            tableView.tableHeaderView = containingView
        }
        else {
            tableView.tableHeaderView = nil
        }
        
        tableView.reloadData()
    }
    
    @IBAction func swipedLeft(_ sender: Any) {
        menuDelegate?.swipedToClose()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard variableSidebarItems.count > 0 else {
            return 3 // Welcome, About, Settings
        }
        // Welcome not shown
        return variableSidebarItems.count + 2 // About and Settings are constant
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0...(variableSidebarItems.count == 0 ? 0 : variableSidebarItems.count-1):
            if variableSidebarItems.count > 0 {
                if variableSidebarItems[indexPath.row].category == "Notifications" {
                    menuDelegate?.switchTo(vcName: "notifications", entityNameForData: nil, informationPageName: nil)
                }
                else if variableSidebarItems[indexPath.row].category == "ContactPage" {
                    menuDelegate?.switchTo(vcName: "contacts", entityNameForData: nil, informationPageName: nil)
                }
                else if variableSidebarItems[indexPath.row].category == "Housing" {
                    menuDelegate?.switchTo(vcName: "housing", entityNameForData: "HousingUnit", informationPageName: nil)
                }
                else if variableSidebarItems[indexPath.row].category == "Schedule" {
                    menuDelegate?.switchTo(vcName: "schedule", entityNameForData: "ScheduleDay", informationPageName: nil)
                }
                else if variableSidebarItems[indexPath.row].category == "PrayerPartners" {
                    menuDelegate?.switchTo(vcName: "prayerPartners", entityNameForData: "PrayerPartnerGroup", informationPageName: nil)
                }
                else {
                    menuDelegate?.switchTo(vcName: "informationPage", entityNameForData: "InformationPage", informationPageName: variableSidebarItems[indexPath.row].nav)
                }
            } else {
                menuDelegate?.switchTo(vcName: "welcome", entityNameForData: nil, informationPageName: nil)
            }
        case variableSidebarItems.count, 1:
            // Case one is covered earlier if data is loaded. By default switch statements don't fall through in swift.
            menuDelegate?.switchTo(vcName: "about", entityNameForData: nil, informationPageName: nil)
        default:
            // Settings is always at index 2 or greater
            menuDelegate?.switchTo(vcName: "settings", entityNameForData: nil, informationPageName: nil)
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
        else if row == 0 {
            // Only if data isn't loaded
            cell.label.text = "Welcome"
        }
        else if row == variableSidebarItems.count || row == 1 {
            // After welcome or all variable items
            cell.sideImageView.image = UIImage(named: "ic_info")
            cell.label.text = "About"
        }
        else {
            // Settings is last
            cell.sideImageView.image = nil
            cell.label.text = "Settings"
        }
        return cell
    }
}

