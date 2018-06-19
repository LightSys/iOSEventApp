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

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var ratePickerView: UIPickerView!
  @IBOutlet weak var pickerContainerView: UIView!
  private var refreshRateOptionsMinutes = [15, 30, 45] // If the event refresh rate is not in either array, it will be added
  private var refreshRateOptionsHours = [1, 2]
  private var defaultRefreshRateMinutes: Int = 0 // Guarantee a value
  private var chosenRefreshRateMinutes: Int?
  // TODO: save and compare refresh rates
  // TODO: clear refresh rate on new event?
  override func viewDidLoad() {
    activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    activityIndicator.center = view.center
    activityIndicator.hidesWhenStopped = true
    view.addSubview(activityIndicator)
    
    let defaultRate = UserDefaults.standard.integer(forKey: "defaultRefreshRateMinutes")
    if defaultRate != 0 {
      defaultRefreshRateMinutes = defaultRate
      if defaultRate % 60 == 0 {
        // It is hours
        if !refreshRateOptionsHours.contains(defaultRate / 60) {
          refreshRateOptionsHours.append(defaultRate / 60)
          refreshRateOptionsHours.sort()
        }
      }
      else if defaultRate == -1 {
        // Never is the default
      }
      else {
        // It is minutes
        if !refreshRateOptionsMinutes.contains(defaultRate) {
          refreshRateOptionsMinutes.append(defaultRate)
          refreshRateOptionsMinutes.sort()
        }
      }
    }
    let chosenRate = UserDefaults.standard.integer(forKey: "defaultRefreshRateMinutes")
    if chosenRate != 0 {
      chosenRefreshRateMinutes = chosenRate
    }
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
      labelText = "Refresh event data now"
    case 2:
      labelText = "Refresh every: \(0) minutes"
    case 3:
      fallthrough
    default:
      labelText = ""
    }
    
    cell.cellLabel.text = labelText
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.row {
    case 0:
      navigationController?.popViewController(animated: true)
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
      pickerContainerView.isHidden = false
      print("case 2")
    // Change notification refresh rate
    default:
      print("default case")
      // change data refresh rate
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }

  
  @IBAction func dimViewTapped(_ sender: Any) {
    // TODO: Animate
    pickerContainerView.isHidden = true
  }
  
  @IBAction func saveRefreshRateTapped(_ sender: Any) {
    var refreshLabelText = pickerView(ratePickerView, titleForRow: ratePickerView.selectedRow(inComponent: 0), forComponent: 0)?.replacingOccurrences(of: " (default)", with: "") ?? ""
    if refreshLabelText == "Never" {
      refreshLabelText = "Automatic refresh disabled"
    }
    else {
      // Only show " (default)" and " (selected)" in the picker
      refreshLabelText = "Refresh every: \(refreshLabelText)"
    }
    (tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! SettingsTableViewCell).cellLabel.text = refreshLabelText
    pickerContainerView.isHidden = true
  }
}

extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    // refresh rate options for minutes and hours, plus the never option
    return refreshRateOptionsMinutes.count + refreshRateOptionsHours.count + 1
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    switch row {
    case 0..<refreshRateOptionsMinutes.count:
      let minutes = refreshRateOptionsMinutes[row]
      if minutes == defaultRefreshRateMinutes {
        return "\(minutes) minutes (default)"
      }
      else {
        return "\(minutes) minutes"
      }
    case refreshRateOptionsMinutes.count..<(refreshRateOptionsMinutes.count+refreshRateOptionsHours.count):
      let hoursRow = row - refreshRateOptionsMinutes.count
      let hours = refreshRateOptionsHours[hoursRow]
      var hoursText = "\(hours) hour"
      if hours > 1 {
        hoursText.append("s")
      }
      if defaultRefreshRateMinutes % 60 == 0 && hours == defaultRefreshRateMinutes / 60 {
        return hoursText.appending(" (default)")
      }
      else {
        return hoursText
      }
    default:
      if defaultRefreshRateMinutes == -1 {
        return "Never (default)"
      }
      else {
        return "Never"
      }
    }
  }
}
