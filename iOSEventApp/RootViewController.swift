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

class RootViewController: UIViewController {

  @IBOutlet weak var navigationControllerContainer: UIView!
  @IBOutlet weak var sidebarContainer: UIView!
  @IBOutlet weak var dimView: UIView!
  
  var embeddedNavigationController: UINavigationController!
  var sidebarViewController: SidebarTableViewController!


  @IBAction func dimViewTapped(_ sender: Any) {
    menuButtonTapped()
  }
  
  @IBAction func swipedLeft(_ sender: Any) {
    menuButtonTapped()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "embedNavigationController" {
      embeddedNavigationController =
        segue.destination as! UINavigationController
      (embeddedNavigationController.viewControllers[0]
        as? QRScannerViewController)?.delegate = self
      let mainContainerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainContainer") as! MainContainerViewController
      mainContainerVC.delegate = self
      embeddedNavigationController.viewControllers.append(mainContainerVC)
    }
    else if segue.identifier == "embedSidebarViewController" {
      sidebarViewController = segue.destination as! SidebarTableViewController
      sidebarViewController.menuDelegate = self
    }
  }
}

extension RootViewController: MenuButton {
  func menuButtonTapped() {

    sidebarViewController.loadSidebarItemsIfNeeded()
    
    if self.sidebarContainer.frame.origin.x != 0 {
      self.dimView.isHidden = false
      UIView.animate(withDuration: 0.2) {
        self.sidebarContainer.frame.origin.x = 0
        self.dimView.alpha = 0.25
      }
    }
    else {
      UIView.animate(withDuration: 0.2, animations: {
        self.sidebarContainer.frame.origin.x =
          -self.sidebarContainer.frame.size.width
        self.dimView.alpha = 0
      }, completion: { (_) in
        self.dimView.isHidden = true
      })
    }
  }
}

extension RootViewController: MenuDelegate {
  func switchTo(vcName: String, entityNameForData: String?, informationPageName pageName: String?) {
    let mainContainerVC = embeddedNavigationController.viewControllers[1]
        as! MainContainerViewController
    mainContainerVC.loadViewController(identifier: vcName,
                                       entityNameForData: entityNameForData,
                                       informationPageName: pageName)
    menuButtonTapped()
  }
  
  func swipedToClose() {
    menuButtonTapped()
  }
}
