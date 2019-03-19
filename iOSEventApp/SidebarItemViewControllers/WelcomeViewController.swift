//
//  WelcomeViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 6/15/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

/**
 A landing page for a user with no event, to avoid dumping a user on a camera screen with no explanation.
 */
class WelcomeViewController: UIViewController {

  @IBAction func tappedScan(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }
}
