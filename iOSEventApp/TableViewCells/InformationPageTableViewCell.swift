//
//  InformationPageTableViewCell.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/9/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

/// One header and a large text view. The cell should expand as needed (see `InformationPageViewController`). Each cell corresponds to an information page section.
class InformationPageTableViewCell: UITableViewCell {

  @IBOutlet weak var headerLabel: UILabel!
  @IBOutlet weak var textView: UITextView!
}
