//
//  MainContainerViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/6/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

/*
 The menu button reveals the sidebar, and tapping beside the sidebar removes
    the menu. 
 
 */


import UIKit

protocol MenuButton: AnyObject {
  func menuButtonTapped()
}

protocol TakesArrayData: AnyObject {
  var dataArray: [Any]? { get set }
}

class MainContainerViewController: UIViewController {
  let loader = DataController(newPersistentContainer:
    (UIApplication.shared.delegate as! AppDelegate).persistentContainer)

  weak var delegate: MenuButton?

  @IBAction func menuButtonTapped(_ sender: Any) {
    delegate?.menuButtonTapped()
  }

  override func viewDidAppear(_ animated: Bool) {
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadViewController(identifier: "notifications", entityNameForData: "")
  }
  
  func loadViewController(identifier: String, entityNameForData: String) {
    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    if childViewControllers.count > 0 {
      let childVC = childViewControllers[0]
      childVC.view.removeFromSuperview()
      childVC.willMove(toParentViewController: nil)
      childVC.removeFromParentViewController()
    }
    addChildViewController(vc)
    let childView = vc.view
    childView?.frame.size = view.frame.size
    view.addSubview(vc.view)
    vc.didMove(toParentViewController: self)
    
    guard entityNameForData != "" else {
      return
    }
    if let data = loader.fetchAllObjects(forName: entityNameForData) {
      if let takesArrayData = vc as? TakesArrayData {
        takesArrayData.dataArray = data as [Any]
      }
    }
  }}
