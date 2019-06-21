//
//  ChangeEventsViewController.swift
//  iOSEventApp
//
//  Created by Nate Gamble on 6/18/19.
//  Copyright © 2019 LightSys. All rights reserved.
//

import UIKit


/** Settings screen used to delete stored events
 *
 */
class ChangeEventsViewController: UIViewController {
    
    private var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    var URLArray = UserDefaults.standard.dictionary(forKey: "savedURLs")
    var textArray: [String] = []
    
    override func viewDidLoad() {
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        self.tableView.allowsMultipleSelectionDuringEditing = false
        tableView.tableFooterView = UIView()
        // "new" blank item sometimes sneaking into savedURLs dictionary
        if URLArray!.keys.contains("new") {
            URLArray!["new"] = nil
            UserDefaults.standard.set(URLArray, forKey: "savedURLs")
        }
    }
}

// MARK: - Table View DataSource, Delegate
extension ChangeEventsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return URLArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "changeEventCell", for: indexPath) as! ChangeEventTableViewCell
        
        var labelText = ""
        
        for key in URLArray!.keys {
            if !textArray.contains(key) {
                labelText = key
                textArray.append(key)
                break
            }
        }
        
        // Set Cells here
        
        cell.cellLabel.text = labelText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        // If user taps on cell with data currently loaded, do nothing
        if self.textArray[indexPath.row] == UserDefaults.standard.string(forKey: "currentEvent") {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        // Create the alert controller to confirm event loading
        let alertController = UIAlertController(title: "Load saved event?", message: "Do want to load \(self.textArray[indexPath.row])? (Check the menu after loading for event)", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "Load", style: UIAlertAction.Style.default) {
            UIAlertAction in
            
            // Load information from event/cell selected
            self.deleteData()
            let url = self.URLArray![self.textArray[indexPath.row]]!
            self.loadData("\(url)")
            UserDefaults.standard.set(Date(), forKey: "notificationsLastUpdatedAt")

            // rootController sends to welcome page, navigationController sends to QR scanning, mainContainer sends to blankish notification page, notifications sends to blank notification page, sidebarController sends to broken sidebar page
            UIApplication.shared.keyWindow?.rootViewController = self.storyboard!.instantiateViewController(withIdentifier: "rootController")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
        }
        
        // Add the actions
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
        
        
        // Cells are selectable but shouldn't stay selected
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            
            // Create the alert controller to confirm deletion
            let alertController = UIAlertController(title: "Delete event?", message: "Do want to delete \(self.textArray[indexPath.row])? You will need to rescan the QR code to undo.", preferredStyle: .alert)
            
            // Create the actions
            let okAction = UIAlertAction(title: "Delete", style: UIAlertAction.Style.destructive) {
                UIAlertAction in
                var tempArray = UserDefaults.standard.dictionary(forKey: "savedURLs")
                tempArray?.removeValue(forKey: self.textArray[indexPath.row])
                UserDefaults.standard.set(tempArray, forKey: "savedURLs")
                self.URLArray = tempArray
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                // If event deleted is current event, remove all data and send user to welcome screen
                if let current = UserDefaults.standard.string(forKey: "currentEvent") {
                    if (self.textArray[indexPath.row] == current) {
                        self.deleteData()
                        // Send user to welcome screen
                        UIApplication.shared.keyWindow?.rootViewController = self.storyboard!.instantiateViewController(withIdentifier: "rootController")
                    }
                }
                self.textArray.remove(at: indexPath.row)
                
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                UIAlertAction in
            }
            
            // Add the actions
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            // Present the controller
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    /// Deletes all data in the currently loaded event
    func deleteData() {
        
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
    }
    
    func loadData(_ urlString : String) {
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
    //                            completion(success)
                            })
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                        else if errors?.count ?? 0 > 0 {
                            let alertController = UIAlertController(title: "Data loaded with some errors", message: DataController.messageForErrors(errors), preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
    //                            completion(success)
                            })
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                        else {
    //                        completion(success)
                        }
                    }
                })
            
                let general = loader.fetchAllObjects(onContext: context, forName: "General")?.first as? General
                UserDefaults.standard.set(general?.event_name, forKey: "currentEvent")
                UserDefaults.standard.set(url, forKey: "loadedDataURL")
                UserDefaults.standard.set(url, forKey: "loadedNotificationsURL")
                UserDefaults.standard.set(Date(), forKey: "notificationsLastUpdatedAt")
                
                
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
        
    }
}
    
