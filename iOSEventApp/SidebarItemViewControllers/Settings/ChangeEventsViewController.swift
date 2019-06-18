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
    var textArray = ["Hello", "There"]
    
    override func viewDidLoad() {
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        self.tableView.allowsMultipleSelectionDuringEditing = false;
    }
}

// MARK: - Table View DataSource, Delegate
extension ChangeEventsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "changeEventCell", for: indexPath) as! ChangeEventTableViewCell
        
        let labelText = textArray[indexPath.row]
        // Set Cells here
        
        cell.cellLabel.text = labelText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Load information from event/cell selected
        
        
        
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
                self.textArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
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
}
