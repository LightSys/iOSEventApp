//
//  SettingsViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/9/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as! SettingsTableViewCell
    
    var labelText = ""
    switch indexPath.row {
    case 0:
      labelText = "Scan new QR code"
    case 1:
      labelText = "Notification Refresh Rate: \(0) minutes"
    default:
      labelText = "Data Refresh Rate: \(0) minutes"
    }
    
    cell.cellLabel.text = labelText
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 80
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.row {
    case 0:
      navigationController?.popViewController(animated: true) // TODO: Distinguish between manual refresh and scan a new barcode?
    case 1:
      print("case 1")
    // Change notification refresh rate
    default:
      print("case 2")
      // change data refresh rate
    }
  }

}
