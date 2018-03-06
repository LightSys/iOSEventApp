//
//  DataLoader.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 3/5/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import Foundation
import CoreData

class DataController: NSObject {
//  var managedObjectContext: NSManagedObjectContext
  var persistentContainer: NSPersistentContainer
  
  init(completionClosure: @escaping () -> ()) {
    persistentContainer = NSPersistentContainer(name: "DataModel")
    persistentContainer.loadPersistentStores() { (description, error) in
      if let error = error {
        fatalError("Failed to load Core Data stack: \(error)")
      }
      completionClosure()
    }
  }

  func loadDataFromURL(_ url: URL) {
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard error == nil else {
        print("Error: \(error!)")
        return
      }
      guard let unwrappedData = data else {
        print("There was no data")
        return
      }
      
      
//      JSONSerialization.ReadingOptions
      do {
        let jsonDict = try JSONSerialization.jsonObject(with: unwrappedData) as! [String: Any]
        let prayerPartners = jsonDict["prayer_partners"] as! [[String: Any]]
        print(prayerPartners)
        // index 0. general info? = key:"nav" value:"Prayer Partners"
        //                          key:"icon" value:"ic_group"
        
        // index 1-8 Partners = key:"students" value:"First Last\nFirst Last..."
        
        let housing = jsonDict["housing"] as! [String: Any]
        // General info
        // key:"nav" value "Housing"
        // key "icon" value:"ic_house"
        
        // Hosts:
        // key: (hostname) value ["students": "(students)", "driver": "(driver)"]
        
        let general = jsonDict["general"] as! [String: Any]
        // Keys: "time_zone" "notifications_url" "welcome_message" "year" "refresh" "refresh_expire" "logo"
        
        let contactPage = jsonDict["contact_page"] as! [String: Any]
/*    - key : "icon"
 - value : ic_contact
*/
        // key: "section_1"
        // value ["content":(string), "id":0, "header":(string)]
        // key: "section_2"
        // value ["content":(string), "id":1, "header":(string)]
        // key: "nav"
        // value "Contacts"
        
        let contacts = jsonDict["contacts"] as! [String: Any]
        // key: "name"
        // value: ["address":(address), "phone":(phone?)]
        // NO NAV?
        
        let theme = jsonDict["theme"] as! [[String: Any]]
        // array of ["key":"#XXXXXX"]
        
        
        // DATA MODEL PAUSE
        
//        let informationPage = jsonDict["information_page"] as! [String: Any]
//        // "page_1": (something), "page_2": (something)
//
//        let schedule = jsonDict["schedule"] as! [String: Any]
//        // Keyed by date "03/04/2018"
//        // Value: Array of dictionaries
//        // Dictionaries: ["category":cat, length:(minutes), start_time:(1015), description:(string), location:(string)
      }
      catch {
        print(error)
        print("Error!")
      }
//      if let jsonDict = JSONSerialization.jsonObject(with: unwrappedData)  {
//        print(jsonDict)
//      }
    }
    task.resume()
  }
  
}


// This is used to compartmentalize creating objects out of dictionaries...
extension DataController {
  /*        let jsonDict = try JSONSerialization.jsonObject(with: unwrappedData) as! [String: Any]
   let prayerPartners = jsonDict["prayer_partners"] as! [[String: Any]]
   print(prayerPartners)
   // index 0. general info? = key:"nav" value:"Prayer Partners"
   //                          key:"icon" value:"ic_group"
   
   // index 1-8 Partners = key:"students" value:"First Last\nFirst Last..."

 */
  func generatePrayerPartnerModel(from partnerGroups: [[String: Any]]) {
    
    for obj in partnerGroups {
      if if let partnerNames = obj["students"] {
        let partners = NSEntityDescription.insertNewObject(forEntityName: "PrayerPartnerGroup", into: persistentContainer.viewContext)
      }
      else {
        
      }
    }
  }
}
