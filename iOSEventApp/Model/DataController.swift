//
//  DataController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/5/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

/*
 This document contains the process of loading data into the various pages
    from the database. It is sortd by page loading into. I dont necessarily
    know which section is which but Imma do my best.
 
 DataController also starts the refresh timer in the refreshController, which it keeps a static reference to. The refresh timer triggers a reload of notifications.
 */

import Foundation
import CoreData

/// An explanation of what went wrong. As this is expected to be displayed in an array, additional formatting will be required before showing to the user.
///
/// - unableToRetrieveData: An error was returned when performing the data task to load data.
/// - noData: No error was returned, but there was no data returned.
/// - unableToSerializeJSON: An error was thrown while trying to serialize the json returned.
/// - unableToParse: The associated string is expected to be the name of the part of the model that was unable to be loaded because a required piece of information was missing, e.g. "Notifications" or "Contacts".
/// - unableToSave: The persistent container's context's save failed; see error for more information.
/// - partiallyMalformed: A non-necessary part of the model was unable to be loaded.
/// - unableToRetrieveNotifications: An error was returned when performing the data task to load notification data.
/// - noNotifications: No error was returned when loading notification data, but there was no data returned.
/// - unableToSerializeNotificationsJSON: An error was thrown while trying to serialize the notifications json returned.
/// - unableToParseNotifications: No Notifications were loaded because the data was in the wrong format.
/// - partiallyMalformedNotification: A non-necessary part of the model was unable to be loaded.
enum DataLoadingError: Error {
  case unableToRetrieveData(Error)
  case noData
  case unableToSerializeJSON
  case unableToParse(String)
  case unableToSave(NSError)
  case partiallyMalformed(MalformedDataInformation)
  case unableToRetrieveNotifications(Error)
  case noNotifications
  case unableToSerializeNotificationsJSON
  case unableToParseNotifications
  case partiallyMalformedNotification(MalformedDataInformation)
}

/// Indicates what data is malformed. Supply at least one of the fields other than object name.
struct MalformedDataInformation: CustomStringConvertible {
  
  /// The object the property belongs to.
  var objectName: String
  /// If a property of a property is malformed, connect the two using a . as in "property1.property2"
  var propertyName: String?
  /// If a key is missing from an object, this is what the key should have been.
  var missingProperty: String?

  /// "objectName.propertyName" or "propertyName" if no objectName
  var description: String {
    var stringToReturn = objectName
    if let malformedProperty = propertyName {
      stringToReturn.append(".\(malformedProperty)")
    }
    if let missing = missingProperty {
      stringToReturn.append(" property \(missing) is missing")
    }
    else {
      stringToReturn.append(" is in the wrong format")
    }
    return stringToReturn
  }
}

class DataController: NSObject {
  
  static var refreshController: RefreshController?
  
  var persistentContainer: NSPersistentContainer
  let sidebarNameKey = "nav"
  let sidebarIconKey = "icon"
  let sidebarAppearanceEntityName = "SidebarAppearance"
  let orderKey = "order"
  
  init(newPersistentContainer: NSPersistentContainer) {
    persistentContainer = newPersistentContainer
  }

  /// Retrieve data for an event and load it into the core data model. If a url for notifications is loaded, then the notifications will also be retrieved and loaded in this call.
  ///
  /// When loading data, any old data is deleted only after the new data is parsed correctly. To start from a 'clean slate' clear all data from the persistentContainer before calling this method.
  ///
  /// - Parameters:
  ///   - url: url linking to a webpage of json
  ///   - completion: This will be on a background thread.
  func loadDataFromURL(_ url: URL, completion: @escaping ((_ success: Bool, _ error: [DataLoadingError]?, _ newNotifications: [Notification]) -> Void)) {
    
    let task = URLSession.shared.dataTask(with: url) { (data, response, err) in
      guard err == nil else {
        completion(false, [.unableToRetrieveData(err!)], [])
        return
      }
      guard let unwrappedData = data else {
        completion(false, [.noData], [])
        return
      }
      
      var jsonDict: [String: Any]
      do {
        guard let json = try JSONSerialization.jsonObject(with: unwrappedData) as? [String: Any] else {
          completion(false, [.partiallyMalformed(MalformedDataInformation(objectName: "Data json", propertyName: nil, missingProperty: nil))], [])
          return
        }
        jsonDict = json
      }
      catch {
        completion(false, [.unableToSerializeJSON], [])
        return
      }
      self.persistentContainer.performBackgroundTask({ (context) in
        
        var dataLoadingErrors = [[DataLoadingError]?]()
        
        // The "generate" methods insert data on the given context without saving. 
        dataLoadingErrors.append(self.generatePrayerPartnerModel(onContext: context, from: jsonDict["prayer_partners"]))
        dataLoadingErrors.append(self.generateHousingModel(onContext: context, from: jsonDict["housing"]))
        let general = jsonDict["general"]
        dataLoadingErrors.append(self.generateGeneralModel(onContext: context, from: general))
        dataLoadingErrors.append(self.generateContactPageModel(onContext: context, from: jsonDict["contact_page"]))
        dataLoadingErrors.append(self.generateContactModel(onContext: context, from: jsonDict["contacts"]))
        dataLoadingErrors.append(self.generateThemeModel(onContext: context, from: jsonDict["theme"]))
        dataLoadingErrors.append(self.generateInformationPageModel(onContext: context, from: jsonDict["information_page"]))
        dataLoadingErrors.append(self.generateSchedulePageModel(onContext: context, from: jsonDict["schedule"]))
        
        if let general = self.fetchAllObjects(onContext: context, forName: "General")?.first as? General, general.refresh != 0 {
          UserDefaults.standard.set(general.refresh, forKey: "defaultRefreshRateMinutes")
          UserDefaults.standard.set(general.refresh_expire, forKey: "refreshExpireString")
        }

        var errors = dataLoadingErrors.compactMap({ $0 }).joined().map({ $0 }) as [DataLoadingError]

        // This should be set regardless of success or failure
        UserDefaults.standard.set(url, forKey: "loadedDataURL")
        
        guard let generalDict = general as? [String: Any], let notificationsURLString = generalDict["notifications_url"] as? String else {
          self.trySave(onContext: context, currentErrors: errors) { (success, errorArray) in
            if success {
              UserDefaults.standard.set(Date(), forKey: "dataLastUpdatedAt")
            }
            completion(success, errorArray, [])
          }
          return
        }
        
//        self.loadNotificationsFromURL(context: context, url: URL(string: notificationsURLString)!) { (success, nErrors) in
        self.loadNotificationsFromURL(context: context, url: URL(string: "http://192.168.1.126:8081")!) { (success, nErrors, newNotifications)  in
          if success {
            UserDefaults.standard.set(Date(), forKey: "dataLastUpdatedAt")
          }
          if let additionalErrors = nErrors {
            if case .unableToSave(_)? = additionalErrors.first {
              // The save error is the only error (the others were removed)
              errors = additionalErrors
            }
            else {
              errors.append(contentsOf: additionalErrors)
            }
          }
          // Notifications' success is the same as success for the data load, because they share a save.
          completion(success, errors, newNotifications)
        }
      })
    }
    task.resume()
  }
  
  /// Attempt to save, then execute the completion block. If the context has no objects after the save, failure will be passed into the completion block.
  ///
  /// - Parameters:
  ///   - context: The context that may need to be saved.
  ///   - currentErrors: The errors generated up to the point of the save. They will be replaced by a single error in the case of a save failure.
  ///   - completion: Will be called in both success and failure cases.
  private func trySave(onContext context: NSManagedObjectContext, currentErrors: [DataLoadingError]?, completion: ((_ success: Bool, _ error: [DataLoadingError]?) -> Void)) {
    do {
      if context.hasChanges {
        try context.save()
      }
      let success = objectsInDataModel(onContext: context)
      completion(success, (currentErrors?.count != 0) ? currentErrors : nil)
    }
    catch let error as NSError {
      completion(false, [.unableToSave(error)])
    }
  }
 
  
  /// Loads the data for notifications. This method will be called periodically to refresh the notifications.
  ///
  /// If a new notification contains the refresh key with a value of true, this method also triggers a reload of ALL data.
  ///
  /// - Parameters:
  ///   - url: URL to load data from
  ///   - completion: To be run after save.
  func loadNotificationsFromURL(context: NSManagedObjectContext, url: URL, allowReload: Bool = false, completion: @escaping ((_ success: Bool, _ error: [DataLoadingError]?, _ newNotifications: [Notification]) -> Void)) {
    
    let task = URLSession.shared.dataTask(with: url) { (data, response, err) in
      guard err == nil else {
        completion(false, [.unableToRetrieveNotifications(err!)], [])
        return
      }
      guard let unwrappedData = data else {
        completion(false, [.noNotifications], [])
        return
      }
      
      var jsonDict: [String: Any]
      do {
        guard let json = try JSONSerialization.jsonObject(with: unwrappedData) as? [String: Any] else {
          completion(false, [.partiallyMalformed(MalformedDataInformation(objectName: "Notifications json", propertyName: nil, missingProperty: nil))], [])
          return
        }
        jsonDict = json
      }
      catch {
        completion(false, [.unableToSerializeNotificationsJSON], [])
        return
      }
      
      guard let notificationDict = jsonDict["notifications"] as? [String: Any] else {
        completion(false, [.partiallyMalformed(MalformedDataInformation(objectName: "Notifications json", propertyName: "notifications", missingProperty: nil))], [])
        return
      }
      let existingNotifications = self.fetchAllObjects(onContext: context, forName: "Notification") as? [Notification]
      let errors = self.generateNotificationsModel(onContext: context, from: notificationDict)
      
      UserDefaults.standard.set(url, forKey: "loadedNotificationsURL")
      
      // If data is reloaded, it will be on a new context, so it is necessary to save here.
      self.trySave(onContext: context, currentErrors: errors) { (success, errors) in
        // TODO: TEST!!!
        if success {
          UserDefaults.standard.set(Date(), forKey: "notificationsLastUpdatedAt")
        }
        if allowReload {
          let notifications = self.fetchAllObjects(onContext: context, forName: "Notification") as? [Notification]
          var newNotifications = notifications?.filter({ !(existingNotifications?.contains($0) ?? false) })
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
          let lastRefreshDate = UserDefaults.standard.object(forKey: "dataLastUpdatedAt") as! Date
          // If a (true) refresh key newer than the dataLastUpdatedAt date in defaults, load data.
          // There should be no refresh notifications without dates.
          if newNotifications?.contains(where: { $0.refresh == true && (dateFormatter.date(from: $0.date!)! > lastRefreshDate) }) ?? false {
            self.reloadAllData(completion: { (success, errors, returnNotifications) in
              newNotifications?.append(contentsOf: returnNotifications)
              completion(success, errors, newNotifications!)
            })
          }
          else {
            completion(success, errors, [])
          }
        }
        else {
          completion(success, errors, [])
        }
      }
    }
    
    task.resume()
  }
  
  func reloadAllData(completion: @escaping ((_ success: Bool, _ error: [DataLoadingError]?, _ newNotifications: [Notification]) -> Void)) {
    guard let url = UserDefaults.standard.url(forKey: "loadedDataURL") else {
      completion(false, [DataLoadingError.unableToRetrieveData(NSError(domain: "URL Not Saved", code: 0, userInfo: ["message": "Please scan the event's qr code to reload data"]))], [])
      return
    }
    loadDataFromURL(url, completion: completion)
  }
  
  func reloadNotifications(completion: @escaping ((_ success: Bool, _ error: [DataLoadingError]?, _ newNotifications: [Notification]) -> Void)) {
        guard let url = URL(string: "http://192.168.1.126:8081") else {
//    guard let url = UserDefaults.standard.url(forKey: "loadedNotificationsURL") else {
      // Fallback to attempting to reload all data
      reloadAllData(completion: completion)
      return
    }
    self.persistentContainer.performBackgroundTask({ (context) in
      self.loadNotificationsFromURL(context: context, url: url, allowReload: true, completion: completion)
    })
  }
  
  /// Sends the refresh rate and end date to the timer. If the timer is not going or receives a new refresh rate, it will restart.
  ///
  /// - Parameter mainContainer: Only include for a new main container. The main container is tasked with updating whatever view controller is on top.
  static func startRefreshTimer(mainContainer: MainContainerViewController? = nil) {
    var rateMinutes = UserDefaults.standard.integer(forKey: "chosenRefreshRateMinutes")
    if rateMinutes == 0 {
      rateMinutes = UserDefaults.standard.integer(forKey: "defaultRefreshRateMinutes")
    }
    var endDate: Date
    if let endDateString = UserDefaults.standard.object(forKey: "refreshExpireString") as? String {
      endDate = DataController.dateForExpireString(endDateString)
    }
    else {
      endDate = Date(timeIntervalSince1970: 0) // Needed to create the timer; if this happens it will not be started until the end date is updated.
    }
    if let container = mainContainer {
      DataController.refreshController = RefreshController(refreshRateMinutes: rateMinutes, refreshUntil: endDate, containerVC: container)
    }
    else {
      DataController.refreshController?.restartTimer(refreshRateMinutes: rateMinutes, endDate: endDate)
    }
  }
  
  static func dateForExpireString(_ dateString: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    return dateFormatter.date(from: dateString)!
  }
  
  /// Gives error messages in one string for at most 5 errors. Each message will be on a new line. If there are more than 5, the number of errors will come be provided before the error messages.
  static func messageForErrors(_ errors: [DataLoadingError]?) -> String {
    var errorMessage = ""
    if let count = errors?.count, count > 5 {
      errorMessage = "The first 5 of \(count) errors are:\n"
    }
    if let loadingErrors = errors, loadingErrors.count > 0 {
      for (index, error) in loadingErrors.enumerated() where index < 5 {
        switch error {
        case .unableToRetrieveData(let err):
          errorMessage.append("\(err.localizedDescription)\n")
        case .noData:
          errorMessage.append("No data found to load\n")
        case .unableToSerializeJSON:
          errorMessage.append("Event data failed json serialization\n")
        case .unableToParse(let objectName):
          errorMessage.append("\(objectName) was in the wrong format\n")
        case .unableToSave(let err):
          errorMessage.append("Save failed with error: \(err.localizedDescription)\n")
        case .partiallyMalformed(let malformedInfo):
          errorMessage.append("\(malformedInfo.description)\n")
        case .unableToRetrieveNotifications(let err):
          errorMessage.append("\(err.localizedDescription)\n")
        case .noNotifications:
          errorMessage.append("No notifications found to load\n")
        case .unableToSerializeNotificationsJSON:
          errorMessage.append("Notifications data failed json serialization\n")
        case .unableToParseNotifications:
          errorMessage.append("Notifications was in the wrong format\n")
        case .partiallyMalformedNotification(let malformedInfo):
          errorMessage.append("\(malformedInfo.description)\n")
        }
      }
    }
    if errorMessage.count > 0 {
      return String(errorMessage.dropLast()) // the last is a new line character
    }
    return errorMessage
  }

}

/*
 This extension contains the helper methods used to load the different parts of the data model.
 These methods all follow the same basic format:
 
 1. Verify that data exists and is in the right format
 2. Parse the data into dictionaries to later be used for creation
 3. Guard against the lack of sidebar information (if it should be present)
 4. Remove the old objects, if there either were no errors or there is at least one object to create
 5. Return any errors, otherwise return nil.
 
 Most methods call replaceOldDataWithNew which handles steps 4 and 5, but some have more complicated data, in which case they handle all steps themselves.
 */
extension DataController {
  func generatePrayerPartnerModel(onContext context: NSManagedObjectContext, from partnerGroups: Any?) -> [DataLoadingError]? {
    let alertModelName = "Prayer Partners"
    guard partnerGroups == nil || partnerGroups is [[String: Any]] else {
      return [.unableToParse(alertModelName)]
    }
    if partnerGroups == nil {
      return nil // No errors
    }
    
    var errors = [DataLoadingError]()
    var groupstoCreate = [[String: Any]]()
    var sidebarKVPairs = [String: String]()
    let groupDicts = partnerGroups as! [[String: Any]]
    
    for obj in groupDicts {
      if let partnerNames = obj["students"] {
        if partnerNames is String {
          groupstoCreate.append(["students": partnerNames])
        }
        else {
          errors.append(.partiallyMalformed(MalformedDataInformation(objectName: "PrayerPartnerGroup", propertyName: "students", missingProperty: nil)))
        }
      }
      else if obj[sidebarNameKey] != nil || obj[sidebarIconKey] != nil {
        // The icon is not required, but the nav name is.
        if let navName = obj[sidebarNameKey] as? String {
          sidebarKVPairs[sidebarNameKey] = navName
          if let iconName = obj[sidebarIconKey] as? String {
            sidebarKVPairs[sidebarIconKey] = iconName
          }
        }
        else {
          errors.append(.partiallyMalformed(MalformedDataInformation(objectName: "PrayerPartners", propertyName: "nav", missingProperty: "name")))
        }
      }
      else {
        errors.append(.partiallyMalformed(MalformedDataInformation(objectName: "PrayerPartnerGroup", propertyName: nil, missingProperty: "students")))
      }
    }
    
    guard sidebarKVPairs.keys.contains(sidebarNameKey) else {
      return [.partiallyMalformed(MalformedDataInformation(objectName: "PrayerPartners", propertyName: nil, missingProperty: sidebarNameKey))]
    }
  
    let prayerPartnerGroupEntityName = "PrayerPartnerGroup"
    sidebarKVPairs[orderKey] = "4"

    return replaceOldDataWithNew(onContext: context, errors: errors, alertModelName: alertModelName, entityName: prayerPartnerGroupEntityName, newObjectDicts: groupstoCreate, sidebarKVPairs: sidebarKVPairs)
  }

  func generateContactModel(onContext context: NSManagedObjectContext, from contacts: Any?) -> [DataLoadingError]? {
    let alertModelName = "Contacts"
    guard contacts == nil || contacts is [String: Any] else {
      return [.unableToParse(alertModelName)]
    }
    if contacts == nil {
      return nil // No errors
    }

    var errors = [DataLoadingError]()
    var contactstoCreate = [[String: Any]]()
    let contactDict = contacts as! [String: Any]

    for (key, value) in contactDict {
      if var kvDict = value as? [String:Any] {
        kvDict["name"] = key
        contactstoCreate.append(kvDict)
      }
      else {
        errors.append(.partiallyMalformed(MalformedDataInformation(objectName: "Contact", propertyName: nil, missingProperty: nil)))
      }
    }
    
    // No sidebar, as this is contacts, not the contact page.
    let contactEntityName = "Contact"
    
    return replaceOldDataWithNew(onContext: context, errors: errors, alertModelName: alertModelName, entityName: contactEntityName, newObjectDicts: contactstoCreate, sidebarKVPairs: nil)
  }
  
  func generateHousingModel(onContext context: NSManagedObjectContext, from housingDict: Any?) -> [DataLoadingError]? {
    let alertModelName = "Housing"
    guard housingDict == nil || housingDict is [String: Any] else {
      return [.unableToParse(alertModelName)]
    }
    if housingDict == nil {
      return nil // No errors
    }

    var errors = [DataLoadingError]()
    var housingsToCreate = [[String: Any]]()
    var sidebarKVPairs = [String: String]()
    let housing = housingDict as! [String: Any]
    
    guard let navName = housing[sidebarNameKey] as? String else {
      return [.partiallyMalformed(MalformedDataInformation(objectName: "Housing", propertyName: nil, missingProperty: sidebarNameKey))]
    }
    sidebarKVPairs[sidebarNameKey] = navName
    sidebarKVPairs[orderKey] = "3"
    if let iconName = housing[sidebarIconKey] as? String {
      sidebarKVPairs[sidebarIconKey] = iconName
    }

    for (key, value) in housing where key != sidebarNameKey
      && key != sidebarIconKey {
        if var kvDict = value as? [String:Any] {
          kvDict["hostName"] = key
          housingsToCreate.append(kvDict)
        }
        else {
          errors.append(.partiallyMalformed(MalformedDataInformation(objectName: "Housing", propertyName: nil, missingProperty: nil)))
        }
    }

    let housingEntityName = "HousingUnit"
    
    return replaceOldDataWithNew(onContext: context, errors: errors, alertModelName: alertModelName, entityName: housingEntityName, newObjectDicts: housingsToCreate, sidebarKVPairs: sidebarKVPairs)
  }
  
  func generateGeneralModel(onContext context: NSManagedObjectContext, from generalDict: Any?) -> [DataLoadingError]? {
    let alertModelName = "General [Event Information]"
    guard generalDict == nil || generalDict is [String: Any] else {
      return [.unableToParse(alertModelName)]
    }
    if generalDict == nil {
      return nil // No errors
    }

    var errors = [DataLoadingError]()
    var newGeneral = generalDict as! [String: Any]

    if let refresh = newGeneral["refresh"] {
      if let refreshString = refresh as? String {
        let refreshNumber = NSNumber(value: Int16(refreshString)!)
        newGeneral["refresh"] = refreshNumber
      }
      else {
        newGeneral["refresh"] = nil
        errors.append(.partiallyMalformed(MalformedDataInformation(objectName: "General", propertyName: "refresh", missingProperty: nil)))
      }
    }
    if let logoImage = newGeneral["logo"] {
      if let logoImageString = logoImage as? String {
        newGeneral["logo"] = logoImageString.data(using: .utf8)
      }
      else {
        errors.append(.partiallyMalformed(MalformedDataInformation(objectName: "General", propertyName: "logo", missingProperty: nil)))
      }
    }
   
    let generalEntityName = "General"
    return replaceOldDataWithNew(onContext: context, errors: errors, alertModelName: alertModelName, entityName: generalEntityName, newObjectDicts: [newGeneral], sidebarKVPairs: nil)
  }
  
  func generateContactPageModel(onContext context: NSManagedObjectContext, from contactPages: Any?) -> [DataLoadingError]? {
    let alertModelName = "Contact Page"
    guard contactPages == nil || contactPages is [String: Any] else {
      return [.unableToParse(alertModelName)]
    }
    if contactPages == nil {
      return nil // No errors
    }

    var errors = [DataLoadingError]()
    var contactPagesToCreate = [[String: Any]]()
    var sidebarKVPairs = [String: String]()
    let contactPageDict = contactPages as! [String: Any]
    
    guard let sidebarName = contactPageDict[sidebarNameKey] as? String else {
      return [.partiallyMalformed(MalformedDataInformation(objectName: "ContactPage", propertyName: nil, missingProperty: sidebarNameKey))]
    }
    sidebarKVPairs[sidebarNameKey] = sidebarName
    sidebarKVPairs[orderKey] = "1"
    if let iconName = contactPageDict[sidebarIconKey] as? String {
      sidebarKVPairs[sidebarIconKey] = iconName
    }

    for (key, value) in contactPageDict where key != sidebarIconKey && key != sidebarNameKey {
      if var kvDict = value as? [String: Any] {
        kvDict["key"] = key
        contactPagesToCreate.append(kvDict)
      }
      else {
        errors.append(.partiallyMalformed(MalformedDataInformation(objectName: "ContactPage", propertyName: nil, missingProperty: nil)))
      }
    }
    
    if let navName = contactPageDict[sidebarNameKey] as? String {
      sidebarKVPairs[sidebarNameKey] = navName
    }
    
    let contactPageEntityName = "ContactPageSection"

    return replaceOldDataWithNew(onContext: context, errors: errors, alertModelName: alertModelName, entityName: contactPageEntityName, newObjectDicts: contactPagesToCreate, sidebarKVPairs: sidebarKVPairs)
  }
  
  func generateThemeModel(onContext context: NSManagedObjectContext, from themes: Any?) -> [DataLoadingError]? {
    let alertModelName = "Themes"
    guard themes == nil || themes is [[String: Any]] else {
      return [.unableToParse(alertModelName)]
    }
    if themes == nil {
      return nil // No errors
    }

    let themeDictArray = themes as! [[String: Any]]
    var errors = [DataLoadingError]()
    var themesToCreate = [[String: Any]]()
    
    for theme in themeDictArray {
      guard let themeName = theme.keys.first, let themeValue = theme.values.first else {
        errors.append(.partiallyMalformed(MalformedDataInformation(objectName: "Theme", propertyName: theme.keys.first, missingProperty: nil)))
        continue
      }
      themesToCreate.append(["themeName": themeName, "themeValue": themeValue])
    }
    
    guard errors.count == 0 || themesToCreate.count > 0 else {
      // Do not clear old data and return a single error
      return [.unableToParse(alertModelName)]
    }
    
    for theme in themesToCreate {
      _ = createObject(onContext: context, entityName: "Theme", with: theme)
    }
    
    return (errors.count > 0) ? errors : nil
  }
  
  /// This method does not call replaceOldDataWithNew to end, as it must delete multiple sidebars, multiple information pages, and many info page sections.
  ///
  /// - Parameter informationPages: Should be a dictionary where each value is an array of dictionaries. Each array of dictionaries should contain information about the sidebar and the information page sections.
  /// - Returns: Errors generated or nil if no errors
  func generateInformationPageModel(onContext context: NSManagedObjectContext, from informationPages: Any?) -> [DataLoadingError]? {
    let alertModelName = "Information Pages"
    guard informationPages == nil || informationPages is [String: [[String: Any]]] else {
      return [.unableToParse(alertModelName)]
    }
    if informationPages == nil {
      return nil // No errors
    }

    var errors = [DataLoadingError]()
    let informationPageDict = (informationPages as! [String: [[String: Any]]]).sorted(by: { $0.key < $1.key})
    let infoPageEntityName = "InformationPage"
    let infoSectionEntityName = "InformationPageSection"
    var pageNum = -1 // To offset the pre-increment
    var sidebarNum = pageNum+5 // The information pages are the last loadable pages, starting at order 5
    for (key, value) in informationPageDict {
      pageNum += 1 // Do first in case data cannot be loaded
      sidebarNum += 1
      
      let pageIdentifier = key
      // Ideally this wouldn't be hardcoded for an index of 0
      guard let sidebarName = value[0][sidebarNameKey] as? String else {
        errors.append(.partiallyMalformed(MalformedDataInformation(objectName: "Information Page \(pageNum)", propertyName: pageIdentifier, missingProperty: sidebarNameKey)))
        continue
      }
      var kvDict = ["optionalIdentifier": pageIdentifier, sidebarNameKey: sidebarName, orderKey: String(sidebarNum)]
      if let sidebarIconName = value[0][sidebarIconKey] as? String {
        kvDict[sidebarIconKey] = sidebarIconName
      }

      deleteAllInfoPageData(onContext: context, withSidebarPredictate: NSPredicate(format: "order == %@", kvDict[orderKey]!))

      let createdAppearance = createObject(onContext: context, entityName: sidebarAppearanceEntityName, with: kvDict) as! SidebarAppearance
      
      let infoPageDict = ["pageName": pageIdentifier, "infoNav": createdAppearance] as [String : Any]
      let createdPage = createObject(onContext: context, entityName: infoPageEntityName, with: infoPageDict) as! InformationPage
      // Sidebar info was at index 0
      for i in 1..<value.count {
        let section = value[i]
        guard let title = section["title"], let description = section["description"] else {
          errors.append(.partiallyMalformed(MalformedDataInformation(objectName: "Information Page \(pageIdentifier)", propertyName: "\(i)", missingProperty: "title and/or description")))
          continue
        }
        let sectionDict = ["title": title, "information": description, "infoPage": createdPage, "order": i] // Here the order will happen to start at 1
        _ = createObject(onContext: context, entityName: infoSectionEntityName, with: sectionDict) as! InformationPageSection
      }
    }
    
    //TODO: TEST
    deleteAllInfoPageData(onContext: context, withSidebarPredictate: NSPredicate(format: "order.intValue > %i", sidebarNum))

    return (errors.count > 0) ? errors : nil
  }
  
  func deleteAllInfoPageData(onContext context: NSManagedObjectContext, withSidebarPredictate sbPredicate: NSPredicate) {
    let infoPageEntityName = "InformationPage"
    let infoSectionEntityName = "InformationPageSection"
    for oldSidebar in fetchAllObjects(onContext: context, forName: sidebarAppearanceEntityName, withPredicate: sbPredicate) ?? [] {
      for oldInfoPage in fetchAllObjects(onContext: context, forName: infoPageEntityName, withPredicate: NSPredicate(format: "infoNav == %@", oldSidebar)) ?? [] {
        deleteAll(onContext: context, forEntityName: infoSectionEntityName, withPredicate: NSPredicate(format: "infoPage == %@", oldInfoPage))
        context.delete(oldInfoPage)
        context.delete(oldSidebar)
      }
    }
  }
  
  func generateNotificationsModel(onContext context: NSManagedObjectContext, from notifications: Any?) -> [DataLoadingError]? {
    let alertModelName = "Notifications"
    guard notifications == nil || notifications is [String: Any] else {
      return [.unableToParse(alertModelName)]
    }
    if notifications == nil {
      return nil // No errors
    }

    var errors = [DataLoadingError]()
    var notificationsToCreate = [[String: Any]]()
    var sidebarKVPairs = [String: String]()
    let notificationsDict = notifications as! [String: Any]
    
    guard let sidebarName = notificationsDict[sidebarNameKey] as? String else {
      return [.partiallyMalformed(MalformedDataInformation(objectName: "Notifications", propertyName: nil, missingProperty: sidebarNameKey))]
    }
    sidebarKVPairs[sidebarNameKey] = sidebarName
    if let sidebarIcon = notificationsDict[sidebarIconKey] as? String {
      sidebarKVPairs[sidebarIconKey] = sidebarIcon
    }

    for (key, value) in notificationsDict where key != sidebarNameKey && key != sidebarIconKey {
      if let valueDict = value as? [String: Any] {
        guard let num = Int(key), let title = valueDict["title"], let body = valueDict["body"], let date = valueDict["date"], let refresh = valueDict["refresh"] else {
          errors.append(.partiallyMalformed(MalformedDataInformation(objectName: "Notification", propertyName: nil, missingProperty: nil)))
          continue
        }
        let notificationDict = ["notificationNumber": num, "title": title, "body": body, "date": date, "refresh": refresh]
        notificationsToCreate.append(notificationDict)
      }
      else {
        errors.append(.partiallyMalformed(MalformedDataInformation(objectName: "Notification", propertyName: nil, missingProperty: nil)))
      }
    }
    
    let notificationEntityName = "Notification"
    sidebarKVPairs[orderKey] = "0"
    
    return replaceOldDataWithNew(onContext: context, errors: errors, alertModelName: alertModelName, entityName: notificationEntityName, newObjectDicts: notificationsToCreate, sidebarKVPairs: sidebarKVPairs)
  }

  func generateSchedulePageModel(onContext context: NSManagedObjectContext, from schedulePages: Any?) -> [DataLoadingError]? {
    let alertModelName = "Schedule"
    guard schedulePages == nil || schedulePages is [String: Any] else {
      return [.unableToParse(alertModelName)]
    }
    if schedulePages == nil {
      return nil // No errors
    }

    let schedulePageDict = schedulePages as! [String: Any]
    var sidebarKVPairs = [String: String]()

    guard let sidebarName = schedulePageDict[sidebarNameKey] as? String else {
      return [.partiallyMalformed(MalformedDataInformation(objectName: "Schedule", propertyName: nil, missingProperty: sidebarNameKey))]
    }
    sidebarKVPairs[sidebarNameKey] = sidebarName
    if let sidebarIcon = schedulePageDict[sidebarIconKey] as? String {
      sidebarKVPairs[sidebarIconKey] = sidebarIcon
    }

    var errors = [DataLoadingError]()
    var dayDictArray = [[String: Any]]()
    var daySchedules = [[[String: Any]]]()
    var index = -1 // To enable incrementing index at the start of the loop
    var scheduleItemsToCreate = false
    
    for (date, values) in schedulePageDict where date != sidebarNameKey && date != sidebarIconKey {
      dayDictArray.append(["date": date] as [String : Any])
      
      index+=1
      daySchedules.append([[String: Any]]()) // To avoid accessing an uncreated array
      for value in values as! [[String: Any]] {
        guard let description = value["description"], let category = value["category"], let length = value["length"], let location = value["location"], let startTime = value["start_time"] else {
          errors.append(.partiallyMalformed(MalformedDataInformation(objectName: "Schedule", propertyName: "day (\(date))", missingProperty: nil)))
          continue
        }
        let itemsDict = ["startTime": String(describing: startTime),
                         "itemDescription": description,
                         "category": category,
                         "length": String(describing: length),
                         "location": location]
        daySchedules[index].append(itemsDict)
        scheduleItemsToCreate = true
      }
    }

    // If errors and no schedule items, don't modify schedule
    // Else delete ENTIRE schedule.
    
    if errors.count != 0 && scheduleItemsToCreate == false {
      // Schedule failed to load
      return [.unableToParse(alertModelName)]
    }

    sidebarKVPairs[orderKey] = "2"
    deleteAll(onContext: context, forEntityName: sidebarAppearanceEntityName, withPredicate: NSPredicate(format: "order == %@", sidebarKVPairs["order"]!))
    _ = createObject(onContext: context, entityName: sidebarAppearanceEntityName, with: sidebarKVPairs)
    
    
    let scheduleDayEntityName = "ScheduleDay"
    let scheduleItemEntityName = "ScheduleItem"
    deleteAll(onContext: context, forEntityName: scheduleDayEntityName)
    deleteAll(onContext: context, forEntityName: scheduleItemEntityName)

    for i in 0...index {
      let createdDay = createObject(onContext: context, entityName: scheduleDayEntityName, with: dayDictArray[i])
      let scheduleItemsArray = daySchedules[i]
      for var scheduleItemDict in scheduleItemsArray {
        scheduleItemDict["day"] = createdDay
        _ = createObject(onContext: context, entityName: scheduleItemEntityName, with: scheduleItemDict)
      }
    }

    return (errors.count > 0) ? errors : nil
  }
  
  /// This method prematurely returns a single error if there is at least one error and there are no objects to create. In this case, no old data will be deleted and no new data will be made.
  ///
  /// All entities of the given name will be deleted, a new entity for each dict in the array will be created, and the sidebar appearance entry will be replaced.
  ///
  /// - Parameters:
  ///   - errors: Any errors generated earlier in the process. It is possible that a single error will be returned in their place.
  ///   - alertModelName: The name of the model to be returned, in case a single error is returned for the model.
  ///   - entityName: The name of the entities to be deleted.
  ///   - newObjectDicts: An array of key value pairs containing information for new entities. Pass in an empty array if no new entities should be created.
  ///   - sidebarKVPairs: Information about the sidebar appearance. Only required if a sidebar appearance needs to be replaced, but if supplied, it is assumed that it at least has a value for the key sidebarNameKey.
  /// - Returns: Either the array of errors passed in or a single error for the model.
  func replaceOldDataWithNew(onContext context: NSManagedObjectContext, errors: [DataLoadingError], alertModelName: String, entityName: String, newObjectDicts: [[String: Any]], sidebarKVPairs: [String: String]?) -> [DataLoadingError]? {
    
    // If malformed data and no groups to create
    guard errors.count == 0 || newObjectDicts.count > 0 else {
      // Do not clear old data and return a single error
      return [.unableToParse(alertModelName)]
    }
    
    deleteAll(onContext: context, forEntityName: entityName)
    for kvDict in newObjectDicts {
      _ = createObject(onContext: context, entityName: entityName, with: kvDict)
    }

    if let sidebarInfo = sidebarKVPairs {
      deleteAll(onContext: context, forEntityName: sidebarAppearanceEntityName, withPredicate: NSPredicate(format: "order == %@", sidebarInfo["order"]!))
      _ = createObject(onContext: context, entityName: sidebarAppearanceEntityName, with: sidebarInfo)
    }
    
    return (errors.count > 0) ? errors : nil
  }
}

// This extension contains the methods used create, retrieve, and delete managed objects.
extension DataController {
  
  /// Does not save the context after creation
  ///
  /// - Parameters:
  ///   - entityName: <#entityName description#>
  ///   - keyValuePairs: <#keyValuePairs description#>
  /// - Returns: The created object
  func createObject(onContext context: NSManagedObjectContext, entityName: String, with keyValuePairs:
    [String: Any]) -> NSManagedObject? {
    
    let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)!
    let object = NSManagedObject(entity: entity, insertInto: context)
    
    object.setValuesForKeys(keyValuePairs)
    return object
  }
  
  func fetchAllObjects(onContext context: NSManagedObjectContext, forName entityName: String, withPredicate predicate: NSPredicate? = nil, includePropertyValues: Bool = true) -> [NSManagedObject]? {

    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
    fetchRequest.predicate = predicate
    fetchRequest.includesPropertyValues = includePropertyValues
    do {
      let entities = try context.fetch(fetchRequest)
      return entities
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
      return nil
    }
  }
  
  /// A helper method to determine if there has been any data loaded.
  ///
  /// - Parameter context: The context to check this on.
  /// - Returns: True as soon as an entity is found with a non-zero count. False if none are found.
  func objectsInDataModel(onContext context: NSManagedObjectContext) -> Bool {
    let dataModelEntities =
      persistentContainer.managedObjectModel.entitiesByName.keys
    for entityName in dataModelEntities {
      let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
      let count = try? context.count(for: fetchRequest)
      if count ?? 0 > 0 {
        return true
      }
    }
    return false
  }
  
  /// Delete all objects in the context, one at a time, and then save the context.
  func deleteAllObjects(onContext context: NSManagedObjectContext) {
    let dataModelEntities =
        persistentContainer.managedObjectModel.entitiesByName.keys
    for entityName in dataModelEntities {
      deleteAll(onContext: context, forEntityName: entityName)
    }
    do {
      try context.save()
    }
    catch {
      print("error saving data after deleting all objects")
    }
  }

  /// Delete all objects of the entity name matching the (optional) predicate. Does not save afterward.
  func deleteAll(onContext context: NSManagedObjectContext, forEntityName entityName: String, withPredicate predicate: NSPredicate? = nil) {
    
    // Iterates over all objects for the entity name and deletes them.
    // An alternative to this is to do a batch delete. However, this directly modifies the persistent store, which causes merge conflicts (as it doesn't update the context).
    // There should be no noticeable performance loss deleting objects one at a time, because this app deals with a relatively small amount of data.
    
//    print("fetch pre-delete")
    // TODO: The following line periodically crashes.
    let objects = fetchAllObjects(onContext: context, forName: entityName, withPredicate: predicate, includePropertyValues: false)
//    print("starting delete for in")
    for toDelete in objects ?? [NSManagedObject]() {
      context.delete(toDelete)
    }
  }
}
