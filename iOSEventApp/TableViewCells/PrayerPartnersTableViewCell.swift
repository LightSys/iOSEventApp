//
//  PrayerPartnersTableViewCell.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/6/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

class PrayerPartnersTableViewCell: UITableViewCell {
  
  @IBOutlet weak var partnersView: UITextView!
  @IBOutlet weak var groupNumberLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
