//
//  ContactsViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/9/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController, TakesArrayData, UITableViewDataSource, UITableViewDelegate {
  var dataArray: [Any]?
  var contactPageSections: [ContactPageSection]?

    override func viewDidLoad() {
        super.viewDidLoad()
      let loader = DataController(newPersistentContainer:
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer)

      contactPageSections = loader.fetchAllObjects(forName: "ContactPageSection") as? [ContactPageSection]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if dataArray?.count ?? 0 > 0 {
      // We still need to display the contacts
      return contactPageSections?.count ?? 1
    }
    else {
      // There is NO data to display
      return contactPageSections?.count ?? 0
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactTableViewCell
    let row = indexPath.row
    if let contactPageSection = contactPageSections?[row] {
      cell.cellHeader.text = contactPageSection.header
      cell.cellBody.text = contactPageSection.content
    }
    else {
      cell.cellHeader.text = "Contact List"
    }
    
    if row < (contactPageSections?.count ?? 1)-1 {
      // Only display the section info
    }
    else {
      let contactArray = dataArray as! [Contact]
      var bodyText = cell.cellBody.text
      for contact in contactArray {
        bodyText?.append("\n")
        if let name = contact.name {
          bodyText?.append("\n\(name)")
        }
        if let address = contact.address {
          bodyText?.append("\n\(address)")
        }
        if let phone = contact.phone {
          bodyText?.append("\n\(phone)")
        }
      }
      cell.cellBody.text = bodyText
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 204 // TODO: Vary heights of table view cells
  }

}
