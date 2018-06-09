//
//  RefreshController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 5/14/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import Foundation

class RefreshController {
  var refreshRateMinutes: UInt
  var refreshUntil: Date
  
  weak var containerVC: MainContainerViewController?
  
  private static var refreshTimer: Timer?
  
  init(refreshRateMinutes rate: UInt, refreshUntil endDate: Date, containerVC container: MainContainerViewController) {
    refreshRateMinutes = rate
    refreshUntil = endDate
    containerVC = container
    
    let refreshInterval = TimeInterval(refreshRateMinutes * 60)
    
    guard shouldStartTimer() else {
      return
    }
    RefreshController.refreshTimer?.invalidate()
    RefreshController.refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true, block: { (timer) in
      self.containerVC?.reloadNotifications()
      if !self.shouldStartTimer() {
        timer.invalidate()
      }
    })
  }
  
  func shouldStartTimer() -> Bool {
    return Date(timeIntervalSinceNow: TimeInterval(refreshRateMinutes * 60)) < self.refreshUntil
  }
}

