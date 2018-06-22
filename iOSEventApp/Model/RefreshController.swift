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
  
  // Static timer, so the init method can be called multiple times
  private static var refreshTimer: Timer?
  
  init(refreshRateMinutes rate: UInt, refreshUntil endDate: Date, containerVC container: MainContainerViewController) {
    refreshRateMinutes = rate
    refreshUntil = endDate
    containerVC = container
    
    restartTimer(refreshRateMinutes: rate)
  }
  
  func restartTimer(refreshRateMinutes rate: UInt) {
    refreshRateMinutes = rate
    
    guard shouldStartTimer() else {
      return
    }
    
    let refreshInterval = TimeInterval(refreshRateMinutes * 60)
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

