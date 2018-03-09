//
//  InformationPageTableViewCell.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/9/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

class InformationPageTableViewCell: UITableViewCell {

  @IBOutlet weak var headerLabel: UILabel!
  @IBOutlet weak var textView: UITextView!
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
