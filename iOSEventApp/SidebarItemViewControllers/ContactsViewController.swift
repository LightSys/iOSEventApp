//
//  ContactsViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/9/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

extension Contact: Comparable {
    public static func < (lhs: Contact, rhs: Contact) -> Bool {
        guard let name1 = lhs.name, let name2 = rhs.name else {
            return false
        }
        return name1 < name2
    }
}

extension ContactPageSection: Comparable {
    public static func < (lhs: ContactPageSection, rhs: ContactPageSection) -> Bool {
        guard let id1 = lhs.id, let id2 = rhs.id else {
            return false
        }
        return id1 < id2
    }
}

/**
 Displays the contact pages and the contacts in the same cell as the l/Users/avloaner/Documents/iOSEventApp/iOSEventApp/SidebarItemViewControllers/PrayerPartnersViewController.swiftast page.
 */
class ContactsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var headerLabel: UILabel!
    var contactPageSections: [ContactPageSection]?
    var contactArray: [Contact]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 225
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if contactPageSections?.count ?? 0 > 0 {
            // Contacts (in addition to the normal page) will be displayed in the last page section
            return contactPageSections!.count
        }
        else {
            // All contacts will be displayed in one row if there are any contacts to be displayed.
            return (contactArray?.count ?? 0 > 0) ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactTableViewCell
        let row = indexPath.row
        if (contactPageSections?.count ?? 0) > 0, let contactPageSection = contactPageSections?[row] {
            cell.cellHeader.text = contactPageSection.header
            if (row != 1) {
                cell.cellBody.text = contactPageSection.content
            } else {
                cell.cellBody.text = ""
            }
        }
        else {
            cell.cellHeader.text = "Contact List"
        }
        
        if (row == (contactPageSections?.count ?? 1)-1) && (contactArray?.count ?? 0 > 0) {
            var bodyText = cell.cellBody.text
            let importantContacts : String = (contactPageSections?[1].content)!
            let importantContactArray : Array<String> = importantContacts.components(separatedBy: ":")
            for contact in contactArray! {
                if (importantContactArray.contains(contact.name!)) {
//                    bodyText?.append("\n")
                    if let name = contact.name {
                        bodyText?.append("\n\(name)")
                    }
                    if let address = contact.address {
                        bodyText?.append("\n\(address)")
                    }
                    if let phone = contact.phone {
                        bodyText?.append("\n\(phone)")
                    }
                    bodyText?.append("\n")
                }
            }
            cell.cellBody.text = bodyText
        }
        
        return cell
    }
}
