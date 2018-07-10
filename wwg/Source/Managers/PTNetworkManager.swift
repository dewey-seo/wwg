//
//  PTNetworkManager.swift
//  Path
//
//  Created by dewey on 2018. 6. 18..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit
import Reachability
import Alamofire
import AlamofireNetworkActivityLogger

class PTNetworkManager: NSObject {
    static let sharedInstance: PTNetworkManager = { return PTNetworkManager() }()
    
    var reachability: Reachability!
    
    override init() {
        super.init()
    }
    
    public func start() {
        self.startNetworkMonitoring()
        
        #if DEBUG
        NetworkActivityLogger.shared.startLogging()
        #endif
    }
    
    public func stop() {
        self.stopNetworkMonitoring()
        
        #if DEBUG
        NetworkActivityLogger.shared.stopLogging()
        #endif
    }
}


extension PTNetworkManager {
    private func startNetworkMonitoring() {
        if self.reachability == nil {
            self.reachability = Reachability()
        }
        
        guard let reachability = self.reachability else {return}
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(networkStatusChanged(_:)),
                                               name: .reachabilityChanged,
                                               object: reachability)
        
        do {// Start the network status notifier
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    private func stopNetworkMonitoring() {
        guard let reachability = self.reachability else {return}
        reachability.stopNotifier()
    }
    
    @objc func networkStatusChanged(_ notification: Notification) {
        print("network status changed : \(notification.description)")
    }
    
    static func stopNotifier() -> Void {
        do {
            // Stop the network status notifier
            try (PTNetworkManager.sharedInstance.reachability).startNotifier()
        } catch {
            print("Error stopping notifier")
        }
    }
    
    // Network is reachable
    static func isReachable(completed: @escaping (PTNetworkManager) -> Void) {
        if (PTNetworkManager.sharedInstance.reachability).connection != .none {
            completed(PTNetworkManager.sharedInstance)
        }
    }
    
    // Network is unreachable
    static func isUnreachable(completed: @escaping (PTNetworkManager) -> Void) {
        if (PTNetworkManager.sharedInstance.reachability).connection == .none {
            completed(PTNetworkManager.sharedInstance)
        }
    }
    
    // Network is reachable via WWAN/Cellular
    static func isReachableViaWWAN(completed: @escaping (PTNetworkManager) -> Void) {
        if (PTNetworkManager.sharedInstance.reachability).connection == .cellular {
            completed(PTNetworkManager.sharedInstance)
        }
    }
    
    // Network is reachable via WiFi
    static func isReachableViaWiFi(completed: @escaping (PTNetworkManager) -> Void) {
        if (PTNetworkManager.sharedInstance.reachability).connection == .wifi {
            completed(PTNetworkManager.sharedInstance)
        }
    }
}
