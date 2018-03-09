//
//  ViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/5/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

/*
 Root view controler. Contains the sidebar, so that the sidebar can overlap the
    navigation controler. Navigation controler can by this be toggled between
    different parts of the app.
 */

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var navigationControllerContainer: UIView!
  @IBOutlet weak var sidebarContainer: UIView!
  @IBOutlet weak var dimView: UIView!
  
  var embeddedNavigationController: UINavigationController!
  var sidebarViewController: SidebarTableViewController!


  @IBAction func dimViewTapped(_ sender: Any) {
    menuButtonTapped()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "embedNavigationController" {
      embeddedNavigationController =
        segue.destination as! UINavigationController
      (embeddedNavigationController.viewControllers[0]
        as? QRScannerViewController)?.delegate = self
    }
    else if segue.identifier == "embedSidebarViewController" {
      sidebarViewController = segue.destination as! SidebarTableViewController
      sidebarViewController.vcSwitchingDelegate = self
    }
  }
}

extension ViewController: MenuButton {
  func menuButtonTapped() {
    let loader = DataController(newPersistentContainer:
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer)

    let sidebarItems = (loader.fetchAllObjects(forName: "SidebarAppearance")
        as! [SidebarAppearance]).sorted(by: { (item1, item2) -> Bool in
      return item1.order! < item2.order!
    })
    sidebarViewController.variableSidebarItems = sidebarItems
    
    print("Data loaded successfully!")

    UIView.animate(withDuration: 0.2) {
      if self.sidebarContainer.frame.origin.x != 0 {
        self.sidebarContainer.frame.origin.x = 0
        self.dimView.isHidden = false
      }
      else {
        self.sidebarContainer.frame.origin.x =
            -self.sidebarContainer.frame.size.width
        self.dimView.isHidden = true
      }
    }
  }
}

extension ViewController: ViewControllerSwitching {
  func switchTo(vcName: String, entityNameForData: String) {
    let mainContainerVC = embeddedNavigationController.viewControllers[1]
        as! MainContainerViewController
    mainContainerVC.loadViewController(identifier: vcName,
                                       entityNameForData: entityNameForData)
    menuButtonTapped()
  }
}
