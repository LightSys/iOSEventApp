//
//  ContactTableViewCell.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/9/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

/// One header and a large text view. The cell should expand as needed (see `ContactsViewController`). Each cell corresponds to a contact page.
class ContactTableViewCell: UITableViewCell {
  @IBOutlet weak var cellHeader: UILabel!
  @IBOutlet weak var cellBody: UITextView!
}
