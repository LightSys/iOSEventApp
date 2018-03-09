//
//  HousingTableViewCell.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/9/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

class HousingTableViewCell: UITableViewCell {

  @IBOutlet weak var rightTextView: UITextView!
  @IBOutlet weak var leftTextView: UITextView!
  @IBOutlet weak var titleLabel: UITextField!
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
