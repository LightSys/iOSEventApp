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

  @IBOutlet weak var containerView: UIView!
  weak var delegate: MenuButton?

  @IBAction func menuButtonTapped(_ sender: Any) {
    delegate?.menuButtonTapped()
  }

  override func viewDidAppear(_ animated: Bool) {
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadViewController(identifier: "notifications", entityNameForData: "", informationPageName: nil)
  }
  
  func loadViewController(identifier: String, entityNameForData: String, informationPageName pageName: String?) {
    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    if childViewControllers.count > 0 {
      let childVC = childViewControllers[0]
      childVC.view.removeFromSuperview()
      childVC.willMove(toParentViewController: nil)
      childVC.removeFromParentViewController()
    }
    if entityNameForData != "", var data = loader.fetchAllObjects(forName: entityNameForData) {
      if pageName != nil {
        let infoPage = (data.first(where: { (object) -> Bool in
          if let infoPage = object as? InformationPage {
            return infoPage.infoNav?.nav == pageName
          }
          return false
        }) as! InformationPage)
        data = infoPage.infoSections?.sortedArray(using: [NSSortDescriptor(key: "order", ascending: true)]) as! [InformationPageSection]
      }
      if let takesArrayData = vc as? TakesArrayData {
        // TODO: Handle infoPage name. Perhaps add a takesDictData?
        takesArrayData.dataArray = data as [Any]
      }
    }
    addChildViewController(vc)
    containerView.addSubview(vc.view)
    vc.didMove(toParentViewController: self)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    for view in containerView.subviews {
      view.frame.size = containerView.frame.size
      view.frame.origin = CGPoint.zero
    }
  }
}
