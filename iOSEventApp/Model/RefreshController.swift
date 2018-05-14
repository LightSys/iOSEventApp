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
  
  private var refreshTimer: Timer?
  
  init(refreshRateMinutes rate: UInt, refreshUntil endDate: Date, containerVC container: MainContainerViewController) {
    refreshRateMinutes = rate
    refreshUntil = endDate
    containerVC = container
    
    let refreshInterval = TimeInterval(refreshRateMinutes * 60)
    refreshTimer = Timer(fire: Date(timeIntervalSinceNow: refreshInterval), interval: refreshInterval, repeats: true, block: { (timer) in
      self.triggerRefresh()
      if Date(timeIntervalSinceNow: refreshInterval) < self.refreshUntil {
        timer.invalidate()
      }
    })
  }
  
  func triggerRefresh() {
    containerVC?.reloadNotifications()
  }
}

