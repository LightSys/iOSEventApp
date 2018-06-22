//
//  SettingsViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/9/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit
import UserNotifications

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  private var activityIndicator: UIActivityIndicatorView!

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var ratePickerView: UIPickerView!
  @IBOutlet weak var pickerContainerView: UIView!
  private var refreshRateOptionsMinutes = [15, 30, 45, 60, 120, -1] // If the event refresh rate is one of these values, the duplicate will be removed. -1 is never
  private var defaultRefreshRateMinutes: Int = 0 // Guarantee a value
  private var chosenRefreshRateMinutes: Int?
  private var defaultOptionText: String?
  private let animationTime: TimeInterval = 0.2

  // TODO: clear refresh rate on new event?
  override func viewDidLoad() {
    activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    activityIndicator.center = view.center
    activityIndicator.hidesWhenStopped = true
    view.addSubview(activityIndicator)
    
    let defaultRate = UserDefaults.standard.integer(forKey: "defaultRefreshRateMinutes")
    if defaultRate != 0 {
      defaultRefreshRateMinutes = defaultRate
      defaultOptionText = "Default (\(timeTextForMinutes(defaultRate)))"
      if let removeIndex = refreshRateOptionsMinutes.index(of: defaultRate) {
        refreshRateOptionsMinutes.remove(at: removeIndex)
      }
    }
    
    var chosenRate = UserDefaults.standard.integer(forKey: "chosenRefreshRateMinutes")
    if chosenRate == 0 {
      chosenRate = defaultRate
    }
    if chosenRate != 0 {
      chosenRefreshRateMinutes = chosenRate
    }
    
    if let selectedIndex = refreshRateOptionsMinutes.index(of: chosenRate) {
      ratePickerView.selectRow(selectedIndex, inComponent: 0, animated: false)
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
      let minutes = chosenRefreshRateMinutes ?? defaultRefreshRateMinutes
      if minutes > 0 {
        labelText = "Refresh every: \(timeTextForMinutes(minutes)) "
      }
      else {
        labelText = "Automatic refresh disabled"
      }
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
            self.present(alertController, animated: true) {
              self.sendNotification()
            }
          }
        }
      }
    case 2:
      pickerContainerView.isHidden = false
      UIView.animate(withDuration: animationTime) {
        self.pickerContainerView.alpha = 1
      }
    default:
      print("default case")
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }

  func sendNotification() {
    let notificationCenter = UNUserNotificationCenter.current()
    
    notificationCenter.getNotificationSettings { (settings) in
      // Do not schedule notifications if not authorized.
      guard settings.authorizationStatus == .authorized else {return}
      
      
      let content = UNMutableNotificationContent()
      content.title = "Weekly Staff Meeting"
      content.body = "Every Tuesday at 2pm"

      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
      let request = UNNotificationRequest(identifier: "test notification", content: content, trigger: trigger)
      notificationCenter.add(request, withCompletionHandler: nil)
//      if settings.alertSetting == .enabled {
//        // Schedule an alert-only notification.
//        self.myScheduleAlertNotification()
//      }
//      else {
//        // Schedule a notification with a badge and sound.
//        self.badgeAppAndPlaySound()
//      }
    }
  }
  
  @IBAction func dimViewTapped(_ sender: Any) {
    UIView.animate(withDuration: animationTime, animations: {
      self.pickerContainerView.alpha = 0
    }) { (_) in
      self.pickerContainerView.isHidden = true
    }
  }
  
  @IBAction func saveRefreshRateTapped(_ sender: Any) {
    let selectedRow = ratePickerView.selectedRow(inComponent: 0)
    
    UIView.animate(withDuration: animationTime, animations: {
      (self.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! SettingsTableViewCell).cellLabel.text = self.refreshRateCellTextForPickerRow(selectedRow)
      self.pickerContainerView.alpha = 0
    }) { (_) in
      self.pickerContainerView.isHidden = true
    }
    
    let selectedMinutes = minutesForPickerRow(selectedRow)
    if selectedMinutes != chosenRefreshRateMinutes {
      if selectedMinutes == defaultRefreshRateMinutes {
        UserDefaults.standard.removeObject(forKey: "chosenRefreshRateMinutes")
      }
      else {
        UserDefaults.standard.set(selectedMinutes, forKey: "chosenRefreshRateMinutes")
      }
      chosenRefreshRateMinutes = selectedMinutes
      DataController.restartRefreshTimer()
    }
  }
  
  /// Minutes is expected to be non-zero, non-negative, unless it corresponds to "Never"
  ///
  /// - Parameter minutes: The number of minutes to put in text format
  /// - Returns: never, x hour(s), or x minute(s), with the s included only when x > 1.
  func timeTextForMinutes(_ minutes: Int) -> String {
    guard minutes > 0 else {
      return "never"
    }
    if minutes % 60 == 0 {
      let hours = minutes / 60
      let s = hours > 1 ? "s" : ""
      return "\(hours) hour\(s)"
    }
    else {
      let s = minutes > 1 ? "s" : ""
      return "\(minutes) minute\(s)"
    }
  }
  
  func minutesForPickerRow(_ row: Int) -> Int {
    if row == 0 && defaultRefreshRateMinutes != 0 {
      return defaultRefreshRateMinutes
    }
    let defaultOffset = defaultRefreshRateMinutes != 0 ? 1 : 0
    return refreshRateOptionsMinutes[row - defaultOffset]
  }
  
  /// Call to get the text that should be displayed in the picker row corresponding to row.
  ///
  /// - Returns: Will include "Default" if there is a default option and the row is 0.
  func textForPickerRow(_ row: Int) -> String {
    let minutes = minutesForPickerRow(row)
    if minutes == defaultRefreshRateMinutes {
      return defaultOptionText!
    }
    if minutes == -1 {
      // We want a capital n in never (lowercase is used in default option)
      return "Never"
    }
    else {
      return timeTextForMinutes(minutes)
    }
  }
  
  /// What should be displayed in the table view cell for refresh rate.
  ///
  /// - Parameter row: The picker row this corresponds to
  func refreshRateCellTextForPickerRow(_ row: Int) -> String {
    var pickerText = textForPickerRow(row)
    if pickerText.contains("ever") { // The n is omitted as it may be upper or lower case.
      return "Automatic refresh disabled"
    }
    if pickerText.contains("Default") {
      pickerText = timeTextForMinutes(defaultRefreshRateMinutes)
    }
    return "Refresh every: \(pickerText)"
  }
}

extension SettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    // refresh rate options for minutes, plus (maybe) the default option
    return refreshRateOptionsMinutes.count + (defaultRefreshRateMinutes != 0 ? 1 : 0)
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return textForPickerRow(row)
  }
}
