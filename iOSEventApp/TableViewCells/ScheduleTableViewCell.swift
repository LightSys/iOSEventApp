//
//  ScheduleTableViewCell.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/8/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

/*
 These variables are linked up to the database. The images of a phone
    and a car should appear if contact information and a location
    respectively are avalible (unless we don't get around to
    finalizing images before tonight). The eventName box is set to two
    lines, which may accomodate longer event names. Should the issue
    with overly long lines occur in the other two, there is an
    option in the attributes inspector to increase that size, but
    I don't like how the interface moves with that. Can't think of a better way though.
 
 
 */

import UIKit

class ScheduleTableViewCell: UITableViewCell {

  @IBOutlet weak var startLabel: UILabel!
  @IBOutlet weak var endLabel: UILabel!
  @IBOutlet weak var phoneImageView: UIImageView!
  @IBOutlet weak var carImageView: UIImageView!
  @IBOutlet weak var eventName: UILabel!
  @IBOutlet weak var eventLocation: UILabel!
  @IBOutlet weak var eventContact: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
