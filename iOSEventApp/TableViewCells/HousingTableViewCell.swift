//
//  HousingTableViewCell.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/9/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

/// Housing View Controller should let these expand as needed to fit the text views.
class HousingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var rightTextView: UITextView!
    @IBOutlet weak var leftTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleHeight: NSLayoutConstraint!
}
