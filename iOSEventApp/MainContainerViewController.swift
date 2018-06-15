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
  var currentPageInformation: (identifier: String, entityName: String?, informationPageName: String?)?

  @IBOutlet weak var containerView: UIView!
  weak var delegate: MenuButton?

  @IBAction func menuButtonTapped(_ sender: Any) {
    delegate?.menuButtonTapped()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if loader.objectsInDataModel(onContext: loader.persistentContainer.viewContext) {
      loadViewController(identifier: "notifications", entityNameForData: nil, informationPageName: nil)
      loader.startRefreshTimer(mainContainer: self)
    }
    else {
      loadViewController(identifier: "welcome", entityNameForData: nil, informationPageName: nil)
    }
  }
  
  /// <#Description#>
  ///
  /// - Parameters:
  ///   - identifier: <#identifier description#>
  ///   - entityNameForData: Pass in nil for NotificationsViewController and ContactsViewController, so they get special treatment
  ///   - pageName: <#pageName description#>
  func loadViewController(identifier: String, entityNameForData: String?, informationPageName pageName: String?) {
    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    let context = loader.persistentContainer.viewContext
    if childViewControllers.count > 0 {
      let childVC = childViewControllers[0]
      childVC.view.removeFromSuperview()
      childVC.willMove(toParentViewController: nil)
      childVC.removeFromParentViewController()
    }
    if let contactsVC = vc as? ContactsViewController{
      let contacts = loader.fetchAllObjects(onContext: context, forName: "Contact") as? [Contact]
      let contactPageSections = loader.fetchAllObjects(onContext: context, forName: "ContactPageSection") as? [ContactPageSection]
      contactsVC.contactArray = contacts
      contactsVC.contactPageSections = contactPageSections
    }
    else if let notificationsVC = vc as? NotificationsViewController {
      let notifications = loader.fetchAllObjects(onContext: context, forName: "Notification") as? [Notification]
      let general = loader.fetchAllObjects(onContext: context, forName: "General") as? [General]
      let welcomeMessage = general?.first?.welcome_message
      notificationsVC.notificationArray = notifications?.sorted().reversed() // Newest at top
      notificationsVC.welcomeMessage = welcomeMessage
    }
    else if let entityName = entityNameForData, var data = loader.fetchAllObjects(onContext: context, forName: entityName) {
      if pageName != nil {
        let infoPage = (data.first(where: { (object) -> Bool in
          if let infoPage = object as? InformationPage {
            return infoPage.infoNav?.nav == pageName
          }
          return false
        }) as! InformationPage)
        data = infoPage.infoSections?.sortedArray(using: [NSSortDescriptor(key: "order", ascending: true)]) as! [InformationPageSection]
        (vc as! InformationPageViewController).headerText = pageName
      }

      if let takesArrayData = vc as? TakesArrayData {
        takesArrayData.dataArray = data as [Any]
      }
    }
    addChildViewController(vc)
    containerView.addSubview(vc.view)
    vc.didMove(toParentViewController: self)
    view.setNeedsLayout()
    
    currentPageInformation = (identifier, entityNameForData, pageName)
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    for view in containerView.subviews {
      view.frame.size = containerView.frame.size
      view.frame.origin = CGPoint.zero
    }
  }
  
  func refreshCurrentPage() {
    guard let pageInfo = currentPageInformation else {
      return
    }
    loadViewController(identifier: pageInfo.identifier, entityNameForData: pageInfo.entityName, informationPageName: pageInfo.informationPageName)
  }
  
  /// The container needs to get this, so that it can pass in a completion handler to the reload function.
  func reloadNotifications() {
    loader.reloadNotifications { (success, errors) in
      guard success == true else {
        return
      }
      DispatchQueue.main.async {
        // TODO: Loading indicator + disable screen // guard success
        self.refreshCurrentPage() // only if notifications
      }
    }
  }
}
