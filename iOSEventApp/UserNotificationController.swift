//
//  UserNotificationController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 6/30/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import Foundation
import UserNotifications

/// Central place to send notifications from. The system does not play sounds for notifications from the foreground.
class UserNotificationController: NSObject {
    
    static let sharedInstance = UserNotificationController()
    
    /// Immediately send user notifications
    ///
    /// - Parameter notifications: Each notification will send a separate user notification. If zero notifications are provided no notifications will be sent.
    /// - completion: Notifications must be sent asynchronously
    static func sendNotifications(_ notifications: [Notification], completion: (() -> Void)? = nil) {
        
        guard notifications.count > 0 else {
            completion?()
            return
        }
        
        // This information was getting lost when notifications was passed forward
        let titleBodyDates = notifications.map({ ($0.title, $0.body, $0.date) })
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { (settings) in
            // Do not schedule notifications if not authorized.
            guard settings.authorizationStatus == .authorized else {return}
            
            for titleBodyDate in titleBodyDates {
                
                let content = UNMutableNotificationContent()
                content.title = titleBodyDate.0 ?? ""
                content.body = titleBodyDate.1 ?? ""
                content.sound = UNNotificationSound.default
                
                let request = UNNotificationRequest(identifier: "notification\(titleBodyDate.0 ?? "")\(titleBodyDate.2 ?? "")", content: content, trigger: nil)
                notificationCenter.add(request, withCompletionHandler: nil)
            }
            completion?()
        }
    }
    
    /// Display a message to the user indicating that a background fetch failed.
    ///
    /// - Parameters:
    ///   - failureMessage: The content to display below "Notification fetch failed"
    ///   - completion: Notifications must be sent asynchronously
    static func sendFailedFetchNotification(failureMessage: String, completion: @escaping (() -> Void)) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { (settings) in
            // Do not schedule notifications if not authorized.
            guard settings.authorizationStatus == .authorized else {return}
            
            let content = UNMutableNotificationContent()
            content.title = "Notification fetch failed"
            content.body = failureMessage
            content.sound = UNNotificationSound.default
            
            let request = UNNotificationRequest(identifier: "failedFetchNotification", content: content, trigger: nil)
            notificationCenter.add(request, withCompletionHandler: nil)
            
            completion()
        }
    }
}

// Keeps the clutter out of the app delegate
extension UserNotificationController: UNUserNotificationCenterDelegate {
    
    func requestPermissions() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound]) { (_, _) in }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}
