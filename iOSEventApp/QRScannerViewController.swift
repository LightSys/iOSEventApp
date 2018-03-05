//
//  QRScannerViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/5/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

protocol MenuButton: AnyObject {
  func menuButtonTapped()
}

class QRScannerViewController: UIViewController {
  weak var delegate: MenuButton?
  
  @IBAction func menuButtonTapped(_ sender: Any) {
    delegate?.menuButtonTapped()
  }
}
