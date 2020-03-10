//
//  AppDelegate.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/5/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Can this be moved to after a qr code is scanned?
        UserNotificationController.sharedInstance.requestPermissions()
        
        var refreshRateMinutes = -1
        let chosenRate = UserDefaults.standard.integer(forKey: "chosenRefreshRateMinutes")
        if chosenRate != 0 {
            refreshRateMinutes = chosenRate
        }
        else {
            let defaultRate = UserDefaults.standard.integer(forKey: "defaultRefreshRateMinutes")
            if defaultRate != 0 {
                refreshRateMinutes = defaultRate
            }
        }
        
        // Background fetch is used to refresh the app data, and if possible display a notification to the user.
        // The system decides how often the background fetch really happens, so the user still may not see a notification until the app is opened.
        if refreshRateMinutes == -1 {
            application.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalNever)
        }
        else {
            application.setMinimumBackgroundFetchInterval(TimeInterval(refreshRateMinutes * 60))
        }
        
        return true
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let loader = DataController(newPersistentContainer: persistentContainer)
        loader.reloadNotifications { (success, errors, refresh, newNotification) in
            if success {
                // Refresh will be done on app launch, if there is a new notification
                if newNotification {
                    UserDefaults.standard.set(true, forKey: "notificationLoadedInBackground")
                    if refresh {
                        UserDefaults.standard.set(true, forKey: "refreshedDataInBackground") // Only set to true in case multiple fetches happen
                    }
                    completionHandler(.newData)
                }
                else {
                    completionHandler(.noData)
                }
            }
            else {
                UserNotificationController.sendFailedFetchNotification(failureMessage: DataController.messageForErrors(errors)) {
                    completionHandler(.failed)
                }
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Cancel the refresh timer (otherwise it will probably fire when the app foregrounds)
        RefreshController.cancelRefresh()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if let navigationController = application.keyWindow?.rootViewController?.children.first(where: { $0 is UINavigationController }) as? UINavigationController {
            if let mainContainer = navigationController.viewControllers.first(where: { $0 is MainContainerViewController }) as? MainContainerViewController {
                // The main container will decide if it is time to restart
                mainContainer.appBecameActive()
            }
        }
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "iOSEventApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    // TODO: is this called by default in application will terminate (see call hierarchy)
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
