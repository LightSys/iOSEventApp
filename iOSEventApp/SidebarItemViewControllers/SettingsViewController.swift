//
//  SettingsViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/9/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  private var activityIndicator: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    activityIndicator.center = view.center
    activityIndicator.hidesWhenStopped = true
    view.addSubview(activityIndicator)
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
      labelText = "Refresh event data"
    case 2:
      labelText = "Notification Refresh Rate: \(0) minutes"
    case 3:
      fallthrough
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
      activityIndicator.startAnimating()
      let loader = DataController(newPersistentContainer: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
      loader.reloadAllData { (success, errors) in
        DispatchQueue.main.async {
          self.activityIndicator.stopAnimating()
          if success == false {
            let alertController = UIAlertController(title: "Failed to refresh data", message: DataController.messageForErrors(errors), preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
          }
          else if errors?.count ?? 0 > 0 {
            let alertController = UIAlertController(title: "Data refreshed with some errors", message: DataController.messageForErrors(errors), preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
          }
          else {
            let alertController = UIAlertController(title: "Data refreshed", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
          }
        }
      }
    case 2:
      print("case 2")
    // Change notification refresh rate
    default:
      print("default case")
      // change data refresh rate
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }

}
