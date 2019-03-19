//
//  MainContainerViewController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/6/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit

protocol MenuButton: AnyObject {
  func menuButtonTapped()
  func refreshSidebar()
}

protocol TakesArrayData: AnyObject {
  var dataArray: [Any]? { get set }
}

/// A workaround to allow sorting of data without having to do a separate if else for every data type.
protocol IsComparable {
  var compareString: String? { get }
}

/**
 The MainContainerViewController is in charge of presenting all data view
  controllers, one at a time. By default it loads welcome if no data and
  notifications if there is data loaded. It is prompted to change view
  controllers by the sidebarTableViewController.
 
 As it is the immediate parent of the current view controller, it is in
  charge of updating the current views in response to the periodic refresh.
 
 The menu button reveals the sidebar, and tapping beside the sidebar removes
  the menu. The MainContainerViewController does not handle the menu logic,
  but it does own the menu button.
 */
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
    
    // By default, one of these is loaded.
    if loader.objectsInDataModel(onContext: loader.persistentContainer.viewContext) {
      loadViewController(identifier: "notifications", entityNameForData: nil, informationPageName: nil)
      DataController.startRefreshTimer(mainContainer: self)
    }
    else {
      loadViewController(identifier: "welcome", entityNameForData: nil, informationPageName: nil)
    }
    
    activityIndicator = UIActivityIndicatorView(style: .gray)
    activityIndicator.center = view.center
    activityIndicator.hidesWhenStopped = true
    view.addSubview(activityIndicator)
  }
  
  /// If the user is entering the app, but it hasn't very recently been updated, then notifications are queried for updates.
  func appBecameActive() {
    
    // Guard that there is a notificationsLastUpdatedAt date.
    // If sufficient time (refresh rate or 5 minutes) has elapsed, reload notifications immediately.
    // Override a never rate with 5 minutes

    guard let notificationsLastUpdatedAt = UserDefaults.standard.object(forKey: "notificationsLastUpdatedAt") as? Date else {
      return
    }
    
    let maxInterval = 5
    var refreshRateMinutes = maxInterval
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
    
    if UserDefaults.standard.bool(forKey: "notificationLoadedInBackground") || (UserDefaults.standard.bool(forKey: "refreshedDataInBackground") && children.first is NotificationsViewController) {
      refreshViews()
    }
    UserDefaults.standard.set(false, forKey: "notificationLoadedInBackground")
    UserDefaults.standard.set(false, forKey: "refreshedDataInBackground")

    if Date().timeIntervalSince(notificationsLastUpdatedAt) >= min(TimeInterval(refreshRateMinutes * 60), TimeInterval(maxInterval * 60)) {
      loader.reloadNotifications { (success, errors, refresh, newNotification) in
        DataController.startRefreshTimer(mainContainer: self)
        DispatchQueue.main.async {
          if success {
            if refresh || (newNotification && self.children.first is NotificationsViewController) {
              self.refreshViews()
            }
          }
          else if errors?.count ?? 0 > 0 {
            let alert = UIAlertController(title: "Failed to load notifications", message: "A retry will occur after the refresh interval in settings. The errors are:\n\(DataController.messageForErrors(errors))", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
          }
        }
      }
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    // isBeingDismissed doesn't work here
    if navigationController?.viewControllers.contains(self) == false {
      // Important to prevent refreshing when not in the main container.
      DataController.refreshController?.removeContainerVC()
    }
  }
  
  /// Instantiates a view controller, gives it the needed data, and adds it as a child view controller.
  ///
  /// - Parameters:
  ///   - identifier: The storyboard identifier for the view controller to instantiate
  ///   - entityNameForData: Pass in nil for NotificationsViewController and ContactsViewController, as they get special treatment regardless.
  ///   - pageName: What the information page's header text is. (for info pages) Used to distinguish the different information pages.
  func loadViewController(identifier: String, entityNameForData: String?, informationPageName pageName: String?) {
    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    let context = loader.persistentContainer.viewContext
    if children.count > 0 {
      let childVC = children[0]
      childVC.view.removeFromSuperview()
      childVC.willMove(toParent: nil)
      childVC.removeFromParent()
    }
    // The view controllers that get special treatment need information from multiple entities in core data.
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
        // Special information page logic, because `fetchAllObjects` fetches all information pages, but only one specific one is needed.
        let infoPage = (data.first(where: { (object) -> Bool in
          if let infoPage = object as? InformationPage {
            // Take it if the info page nav matches the provided page name
            return infoPage.infoNav?.nav == pageName
          }
          return false
        }) as! InformationPage)
        data = Array(infoPage.infoSections ?? []) as! [InformationPageSection]
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
    addChild(vc)
    containerView.addSubview(vc.view)
    vc.didMove(toParent: self)
    view.setNeedsLayout()
    
    currentPageInformation = (identifier, entityNameForData, pageName)
  }
  
  /// The views' frames are set here, as this can't be done in viewDidLoad.
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
    for view in containerView.subviews {
      view.frame.size = containerView.frame.size
      view.frame.origin = CGPoint.zero
    }
  }
  
  /// Refreshes by replacing the current page with a new one.
  func refreshViews() {
    self.delegate?.refreshSidebar()
    guard let pageInfo = currentPageInformation else {
      return
    }
    loadViewController(identifier: pageInfo.identifier, entityNameForData: pageInfo.entityName, informationPageName: pageInfo.informationPageName)
  }
  
  /// The container needs to get this, so that it can pass in a completion handler to the reload function.
  func reloadNotifications() {
    loader.reloadNotifications { (success, errors, refresh, newNotification) in
      DispatchQueue.main.async {
        guard success == true else {
          let alertController = UIAlertController(title: "Data refresh failed", message: DataController.messageForErrors(errors), preferredStyle: .alert)
          let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
          alertController.addAction(okAction)
          self.present(alertController, animated: true, completion: nil)
          return
        }
        DataController.startRefreshTimer(mainContainer: self)
        if refresh || (newNotification && self.children.first is NotificationsViewController){
          self.refreshViews()
        }
      }
    }
  }
}
