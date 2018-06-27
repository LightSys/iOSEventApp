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

protocol IsComparable {
  var compareString: String? { get }
}

class MainContainerViewController: UIViewController {
  let loader = DataController(newPersistentContainer:
    (UIApplication.shared.delegate as! AppDelegate).persistentContainer)
  var currentPageInformation: (identifier: String, entityName: String?, informationPageName: String?)?
  var activityIndicator: UIActivityIndicatorView!

  @IBOutlet weak var containerView: UIView!
  weak var delegate: MenuButton?

  @IBAction func menuButtonTapped(_ sender: Any) {
    delegate?.menuButtonTapped()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if loader.objectsInDataModel(onContext: loader.persistentContainer.viewContext) {
      loadViewController(identifier: "notifications", entityNameForData: nil, informationPageName: nil)
      DataController.startRefreshTimer(mainContainer: self)
    }
    else {
      loadViewController(identifier: "welcome", entityNameForData: nil, informationPageName: nil)
    }
    
    activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    activityIndicator.center = view.center
    activityIndicator.hidesWhenStopped = true
    view.addSubview(activityIndicator)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    
    // Guard that there is a notificationsLastUpdatedAt date.
    // If sufficient time (refresh rate or 30 minutes) has elapsed, reload notifications.
    // Override a never rate with 30 minutes

    guard let notificationsLastUpdatedAt = UserDefaults.standard.object(forKey: "notificationsLastUpdatedAt") as? Date else {
      return
    }
    
    var refreshRateMinutes = 30
    let chosenRate = UserDefaults.standard.integer(forKey: "chosenRefreshRateMinutes")
    if chosenRate == 0 {
      let defaultRate = UserDefaults.standard.integer(forKey: "defaultRefreshRateMinutes")
      if defaultRate > 0 {
        refreshRateMinutes = defaultRate
      }
    }
    else if chosenRate > 0 {
      refreshRateMinutes = chosenRate
    }
    
    if Date().timeIntervalSince(notificationsLastUpdatedAt) >= TimeInterval(refreshRateMinutes * 60) {
      loader.reloadNotifications { (_, _) in
        // Don't act on success or errors from the reload and start the refresh timer.
        DataController.startRefreshTimer(mainContainer: self)
      }
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    if isBeingDismissed {
      DataController.refreshController?.removeContainerVC()
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
      contactsVC.contactArray = contacts?.sorted()
      contactsVC.contactPageSections = contactPageSections?.sorted()
    }
    else if let notificationsVC = vc as? NotificationsViewController {
      let notifications = loader.fetchAllObjects(onContext: context, forName: "Notification") as? [Notification]
      let general = loader.fetchAllObjects(onContext: context, forName: "General") as? [General]
      let welcomeMessage = general?.first?.welcome_message
      notificationsVC.notificationArray = notifications?.sorted(by: >) // Syntax for newest at top
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
      
        if let sortable = data as? [IsComparable] { // All objects in the array are the same type
          takesArrayData.dataArray = sortable.sorted(by: { (obj1, obj2) -> Bool in
            guard let str1 = obj1.compareString, let str2 = obj2.compareString else {
              return false
            }
            return str1 < str2
          })
        }
        else {
          takesArrayData.dataArray = data as [Any]
        }
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
      DispatchQueue.main.async {
        guard success == true else {
          let alertController = UIAlertController(title: "Data refresh failed", message: DataController.messageForErrors(errors), preferredStyle: .alert)
          let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
          alertController.addAction(okAction)
          self.present(alertController, animated: true, completion: nil)
          return
        }
        DataController.startRefreshTimer(mainContainer: self)
        // TODO: verify that this does something
        self.activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.3, animations: {
          self.refreshCurrentPage()
        }, completion: { (_) in
          self.activityIndicator.stopAnimating()
        })
      }
    }
  }
}
