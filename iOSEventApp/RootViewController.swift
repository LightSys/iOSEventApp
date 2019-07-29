//
//  ViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/5/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

/**
 Root view controler. Contains the sidebar, so that the sidebar can overlap the
 navigation controler. Navigation controller can by this be toggled between
 different parts of the app.
 */
class RootViewController: UIViewController {
    
    @IBOutlet weak var navigationControllerContainer: UIView!
    @IBOutlet weak var sidebarContainer: UIView!
    @IBOutlet weak var dimView: UIView!
    
    var embeddedNavigationController: UINavigationController!
    var sidebarViewController: SidebarTableViewController!
    
    // Mechanism for closing the menu
    @IBAction func dimViewTapped(_ sender: Any) {
        closeMenu()
    }
    
    // Mechanism for closing the menu
    @IBAction func swipedLeft(_ sender: Any) {
        closeMenu()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedNavigationController" {
            embeddedNavigationController =
                (segue.destination as! UINavigationController)
            (embeddedNavigationController.viewControllers[0]
                as? QRScannerViewController)?.delegate = self // The qr scanner will pass this on to any new main container after a scan.
            let mainContainerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainContainer") as! MainContainerViewController
            mainContainerVC.delegate = self
            embeddedNavigationController.viewControllers.append(mainContainerVC)
        }
        else if segue.identifier == "embedSidebarViewController" {
            sidebarViewController = (segue.destination as! SidebarTableViewController)
            sidebarViewController.menuDelegate = self
        }
    }
    
}

extension RootViewController: MenuButton {
    
    /// The menu button can be "tapped"
    func menuButtonTapped() {
        openMenu()
    }
    
    func openMenu() {
        sidebarViewController.loadSidebarItemsIfNeeded()
        self.dimView.isHidden = false // Can't animate this, but it is necessary to control touches to the dim view.
        UIView.animate(withDuration: 0.2) {
            self.sidebarContainer.frame.origin.x = 0
            self.dimView.alpha = 0.25
        }
    }
    
    func closeMenu() {
        UIView.animate(withDuration: 0.2, animations: {
            self.sidebarContainer.frame.origin.x =
                -self.sidebarContainer.frame.size.width
            self.dimView.alpha = 0
        }, completion: { (_) in
            self.dimView.isHidden = true
        })
    }
    
    func refreshSidebar() {
        sidebarViewController.reloadSidebarItems()
    }
}

extension RootViewController: MenuDelegate {
    func switchTo(vcName: String, entityNameForData: String?, informationPageName pageName: String?) {
        let mainContainerVC = embeddedNavigationController.viewControllers[1]
            as! MainContainerViewController
        mainContainerVC.loadViewController(identifier: vcName,
                                           entityNameForData: entityNameForData,
                                           informationPageName: pageName)
        closeMenu()
    }
    
    // Mechanism for closing the menu
    func swipedToClose() {
        closeMenu()
    }
}
