//
//  ScheduleTableViewCell.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/8/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

/**
 These variables are linked up to the database. The images of a phone
 and a car should appear if contact information and a location
 respectively are avalible (unless we don't get around to
 finalizing images before tonight). The eventName box is set to two
 lines, which may accomodate longer event names. Should the issue
 with overly long lines occur in the other two, there is an
 option in the attributes inspector to increase that size, but
 I don't like how the interface moves with that. Can't think of a better way though.
 
 The event title now has four lines and the location is set to autoshrink. For a combination of long text and a small phone screen it is better
 to display all the text rather than truncate it. (it would be better still to autoshrink and only add as many lines as needed to avoid truncation)
 The phone and car images have been hidden.
 */
class ScheduleTableViewCell: UITableViewCell {

  @IBOutlet weak var startLabel: UILabel!
  @IBOutlet weak var endLabel: UILabel!
  @IBOutlet weak var phoneImageView: UIImageView!
  @IBOutlet weak var carImageView: UIImageView!
  @IBOutlet weak var eventName: UILabel!
  @IBOutlet weak var eventLocation: UILabel!
  @IBOutlet weak var contactTextView: UITextView!
  @IBOutlet weak var contactBottomSpaceConstraint: NSLayoutConstraint!
  @IBOutlet weak var locationHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var contactHeightConstraint: NSLayoutConstraint!
}
