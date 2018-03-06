//
//  ViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/5/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var navigationControllerContainer: UIView!
  @IBOutlet weak var sidebarContainer: UIView!
  @IBOutlet weak var dimView: UIView!
  
  var embeddedNavigationController: UINavigationController!
  var sidebarViewController: SidebarTableViewController!

//  override func viewDidLoad() {
//    navigationControllerContainer.
//  }

  @IBAction func dimViewTapped(_ sender: Any) {
    menuButtonTapped()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "embedNavigationController" {
      embeddedNavigationController = segue.destination as! UINavigationController
      (embeddedNavigationController.viewControllers[0] as? QRScannerViewController)?.delegate = self
    }
    else if segue.identifier == "embedSidebarViewController" {
      sidebarViewController = segue.destination as! SidebarTableViewController
      sidebarViewController.vcSwitchingDelegate = self
    }
  }
}

extension ViewController: MenuButton {
  func menuButtonTapped() {
    UIView.animate(withDuration: 0.2) {
      if self.sidebarContainer.frame.origin.x != 0 {
        self.sidebarContainer.frame.origin.x = 0
        self.dimView.isHidden = false
      }
      else {
        self.sidebarContainer.frame.origin.x = -self.sidebarContainer.frame.size.width
        self.dimView.isHidden = true
      }
    }
  }
}

extension ViewController: ViewControllerSwitching {
  func switchTo(vcName: String, entityNameForData: String) {
    let scannerVC = embeddedNavigationController.viewControllers[0] as! QRScannerViewController
    scannerVC.loadViewController(identifier: vcName, entityNameForData: entityNameForData)
    menuButtonTapped()
  }
}
