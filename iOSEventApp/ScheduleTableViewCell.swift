//
//  ScheduleTableViewCell.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/8/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

class ScheduleTableViewCell: UITableViewCell {

  @IBOutlet weak var startLabel: UILabel!
  @IBOutlet weak var endLabel: UILabel!
  @IBOutlet weak var eventName: UITextField!
  @IBOutlet weak var eventLocation: UITextField!
  @IBOutlet weak var eventContact: UITextField!
  @IBOutlet weak var phoneImageView: UIImageView!
  @IBOutlet weak var carImageView: UIImageView!
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
