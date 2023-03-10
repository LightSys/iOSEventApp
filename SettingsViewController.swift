//
//  SettingsViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/9/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

/**
 Has a few setting cells that the user can tap whether or not data is loaded.
 Most of the logic in this controller is needed to support the refresh rate
 picker.
 */
class SettingsViewController: UIViewController {
    
    private var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ratePickerView: UIPickerView!
    @IBOutlet weak var pickerContainerView: UIView!
    private var refreshRateOptionsMinutes = [5, 10, 15, 30, 45, 60, 120, -1] // If the event refresh rate is one of these values, the duplicate will be removed. -1 is never
    private var defaultRefreshRateMinutes: Int = 0 // Guarantee a value
    private var chosenRefreshRateMinutes: Int?
    private var defaultOptionText: String?
    private let animationTime: TimeInterval = 0.2
    public var loadDevEvents = 0
    
    override func viewDidLoad() {
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        tableView.tableFooterView = UIView()
        
        pickerContainerView.alpha = 0 // If set in the storyboard, it is impossible to see the view
        
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
        
        if var selectedIndex = refreshRateOptionsMinutes.index(of: chosenRate) {
            if (defaultRefreshRateMinutes != 0) {
                selectedIndex += 1
            }
            ratePickerView.selectRow(selectedIndex, inComponent: 0, animated: false)
        }
        else {
            // default
            ratePickerView.selectRow(0, inComponent: 0, animated: false)
        }
    }
}

// MARK: - Table View DataSource, Delegate
extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as! SettingsTableViewCell
        
        var labelText = ""
        switch indexPath.row {
        /*case 0:
            labelText = "Scan new QR code"*/
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
        case 3:
            labelText = "Load/delete events"
        default:
            labelText = ""
        }
        
        cell.cellLabel.text = labelText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        /*case 0:
            loadDevEvents = 0
            navigationController?.pushViewController(QRScannerViewController.init(), animated: true)*/
            
        case 1:
            if loadDevEvents == 1 {
                loadDevEvents += 1
            } else {
                loadDevEvents = 0
            }
            activityIndicator.startAnimating()
            let loader = DataController(newPersistentContainer: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
            loader.reloadAllData { (success, errors, newNotifications) in
                DataController.startRefreshTimer() // The rate or end date may have changed. (if the rate hasn't changed, the timer will be left alone)
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
                    UserNotificationController.sendNotifications(newNotifications) // may be zero notifications
                }
            }
        case 2:
            loadDevEvents = 0
            pickerContainerView.isHidden = false
            UIView.animate(withDuration: animationTime) {
                self.pickerContainerView.alpha = 1
            }
        case 3:
            if loadDevEvents == 0 || loadDevEvents == 2{
                loadDevEvents += 1
            } else if loadDevEvents == 3 {
                loadTestData()
                loadDevEvents = 0
                // Deselect cell and don't load change events page
                tableView.deselectRow(at: indexPath, animated: true)
                return
            } else {
                loadDevEvents = 0
            }
            self.performSegue(withIdentifier: "ChangeEventsSegue", sender: self)
        default:
            loadDevEvents = 0
            print("default case") // Shouldn't happen if only 4 cells
        }
        // Cells are selectable but shouldn't stay selected
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /**
     loadTestData will load example data for testing purposes.
     This function will only be called if the user taps the load/delete events cell, followed by refresh, then load/delete twice more
     Uses code from deleteData() and loadData() from ChangeEventsViewController.swift
    */
    func loadTestData() {
        let alertController = UIAlertController(title: "Load Testing Data?", message: "Do you want to load testing data used by developers?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Load", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.loadData()
            self.reload()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
            return
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func loadData() {
        
        // Delete current info
        UserDefaults.standard.set(nil, forKey: "currentEvent")
        
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.performBackgroundTask { (context) in
            
            // The user won't want notifications from a different event... clear everything except chosen refresh rate
            UserDefaults.standard.removeObject(forKey: "defaultRefreshRateMinutes")
            UserDefaults.standard.removeObject(forKey: "loadedDataURL")
            UserDefaults.standard.removeObject(forKey: "loadedNotificationsURL")
            UserDefaults.standard.removeObject(forKey: "notificationsLastUpdatedAt")
            UserDefaults.standard.removeObject(forKey: "notificationLoadedInBackground")
            UserDefaults.standard.removeObject(forKey: "refreshedDataInBackground")
            
            DispatchQueue.main.async {
                let loader = DataController(newPersistentContainer: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
                loader.deleteAllObjects(onContext: context)
                // Refresh sidebar
            }
        }
        
        // https://jsonblob.com hosts json data free. Dev Testing data last updated 7/31/19
        let urlString = "https://jsonblob.com/api/blob/7d5df36e-a4f6-11e9-8df4-937db7cf2e4c"
        
        // Load information from dev event
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.performBackgroundTask { (context) in
            DispatchQueue.main.async {
                
                let url: URL = URL(string: urlString)!
                
                
                
                let loader = DataController(newPersistentContainer: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
                loader.loadDataFromURL(url, completion: { (success, errors, _) in
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        
                        if success == false {
                            let alertController = UIAlertController(title: "Failed to load data", message: DataController.messageForErrors(errors), preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                                //completion(success) //was commented
                            })
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                        else if errors?.count ?? 0 > 0 {
                            let alertController = UIAlertController(title: "Data loaded with some errors", message: DataController.messageForErrors(errors), preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
                                //completion(success) //was commented
                            })
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                        else {
                            //completion(success) //was commented
                        }
                    }
                })
                
                UserDefaults.standard.set("Dev Testing", forKey: "currentEvent")
                UserDefaults.standard.set(url, forKey: "loadedDataURL")
                UserDefaults.standard.set(url, forKey: "loadedNotificationsURL")
                UserDefaults.standard.set(Date(), forKey: "notificationsLastUpdatedAt")
                
                if var savedURLs = UserDefaults.standard.dictionary(forKey: "savedURLs") {
                    savedURLs["Dev Testing"] = urlString
                    UserDefaults.standard.set(savedURLs, forKey: "savedURLs")
                } else {
                    UserDefaults.standard.set(["Dev Testing": urlString], forKey: "savedURLs")
                }
                
                
                loader.reloadNotifications { (success, errors, refresh, newNotification) in
                    DispatchQueue.main.async {
                        guard success == true else {
                            let alertController = UIAlertController(title: "Data refresh failed", message: DataController.messageForErrors(errors), preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                            return
                        }
                    }
                }
            }
            
        }
        
        UserDefaults.standard.set(Date(), forKey: "notificationsLastUpdatedAt")
        
        // rootController sends to welcome page, navigationController sends to QR scanning, mainContainer sends to blankish notification page, notifications sends to blank notification page, sidebarController sends to broken sidebar page
        UIApplication.shared.keyWindow?.rootViewController = self.storyboard!.instantiateViewController(withIdentifier: "rootController")
    }
    
    func reload() {
        let loader = DataController(newPersistentContainer: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
        loader.reloadAllData { (success, errors, newNotifications) in
            DataController.startRefreshTimer() // The rate or end date may have changed. (if the rate hasn't changed, the timer will be left alone)
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
                UserNotificationController.sendNotifications(newNotifications) // may be zero notifications
            }
        }
    }
}

// MARK: - Picker View DataSource, Delegate
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

// MARK: - Picker View Helper Methods
extension SettingsViewController {
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
        if selectedMinutes > 0 {
            UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(selectedMinutes * 60))
        }
        else {
            UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(UIApplication.backgroundFetchIntervalNever))
        }
        if selectedMinutes != chosenRefreshRateMinutes {
            if selectedMinutes == defaultRefreshRateMinutes {
                UserDefaults.standard.removeObject(forKey: "chosenRefreshRateMinutes")
            }
            else {
                UserDefaults.standard.set(selectedMinutes, forKey: "chosenRefreshRateMinutes")
            }
            chosenRefreshRateMinutes = selectedMinutes
            DataController.startRefreshTimer()
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
