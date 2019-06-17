//
//  RefreshController.swift
//  iOSEventApp
//
//  Created by Nathaniel Brown on 5/14/18.
//  Copyright © 2018 LightSys. All rights reserved.
//

import Foundation

/**
 Central place to manage the refresh timer, which is static. A RefreshController should be created every time a new main container is instantiated, as the timer will not run when restart is called unless there is a main container.
 */
class RefreshController {
    var refreshRateMinutes: Int
    var refreshUntil: Date
    
    weak var containerVC: MainContainerViewController?
    
    // Static timer, so the init method can be called multiple times
    private static var refreshTimer: Timer?
    
    static func cancelRefresh() {
        refreshTimer?.invalidate()
    }
    
    init(refreshRateMinutes rate: Int, refreshUntil endDate: Date, containerVC container: MainContainerViewController) {
        refreshRateMinutes = rate
        refreshUntil = endDate
        containerVC = container
        
        restartTimer(refreshRateMinutes: rate, endDate: endDate)
    }
    
    /// Call when there is no longer a container vc to send messages to. This also cancels the timer.
    func removeContainerVC() {
        containerVC = nil
        RefreshController.cancelRefresh()
    }
    
    /// Starts the timer, if it either isn't going or the rate changes.
    func restartTimer(refreshRateMinutes rate: Int, endDate: Date) {
        
        // Do whether or not the timer starts
        let rateChanged = refreshRateMinutes != rate
        refreshUntil = endDate
        refreshRateMinutes = rate
        
        // Testing against true because it may be nil
        guard rateChanged || RefreshController.refreshTimer?.isValid != true else {
            return
        }
        
        guard shouldStartTimer() else {
            // It needs to be restarted but shouldn't be started... invalidate the timer
            RefreshController.refreshTimer?.invalidate()
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
    
    /// Checks that there is a containerVC, a valid refresh rate, and that refreshUntil is in the future.
    func shouldStartTimer() -> Bool {
        guard containerVC != nil && refreshRateMinutes > 0 else {
            return false
        }
        return Date(timeIntervalSinceNow: TimeInterval(refreshRateMinutes * 60)) < self.refreshUntil
    }
}

