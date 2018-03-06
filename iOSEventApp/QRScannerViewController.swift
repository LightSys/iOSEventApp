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
  
  override func viewDidAppear(_ animated: Bool) {
    let loader = DataController(newPersistentContainer: (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
    loader.loadDataFromURL(URL(string: "https://lightsys.org/sbcat_event/2018-1-a64ffdcdf77818aba3ddbe1efbf680ae/")!)
  }
}
