//
//  WelcomeViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 6/15/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

  @IBAction func tappedScan(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }
}
