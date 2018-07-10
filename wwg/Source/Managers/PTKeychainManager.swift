//
//  PTKeychainManager.swift
//  Path
//
//  Created by dewey on 2018. 6. 18..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

public enum PTKeychainAccessibility {

    @available(iOS 4, *)
    case afterFirstUnlock

    @available(iOS 4, *)
    case afterFirstUnlockThisDeviceOnly

    @available(iOS 4, *)
    case always

    @available(iOS 8, *)
    case whenPasscodeSetThisDeviceOnly

    @available(iOS 4, *)
    case alwaysThisDeviceOnly

    @available(iOS 4, *)
    case whenUnlocked

    @available(iOS 4, *)
    case whenUnlockedThisDeviceOnly
    
    func convert() -> KeychainItemAccessibility {
        switch self {
        case .afterFirstUnlock: return .afterFirstUnlock
        
        case .afterFirstUnlockThisDeviceOnly:  return .afterFirstUnlockThisDeviceOnly
        
        case .always: return .always

        case .whenPasscodeSetThisDeviceOnly: return .whenPasscodeSetThisDeviceOnly

        case .alwaysThisDeviceOnly: return .alwaysThisDeviceOnly

        case .whenUnlocked: return .whenUnlocked

        case .whenUnlockedThisDeviceOnly: return .whenUnlockedThisDeviceOnly
        }
    }
}

class PTKeychainManager: NSObject {
    static let sharedInstance: PTKeychainManager = { return PTKeychainManager()}()
    
    var keychainWrapper: KeychainWrapper
    
    override init() {
        self.keychainWrapper = KeychainWrapper.init(serviceName: "com.path.Path", accessGroup: "H2FYDT52EK.com.path.keychain.sharedaccessgroup")
        super.init()
    }
    
    //
    // MARK: - SET
    //
    @discardableResult open func set(_ value: Int, forKey key: String, withAccessibility accessibility: PTKeychainAccessibility? = nil) -> Bool {
        return self.keychainWrapper.set(value, forKey: key, withAccessibility: accessibility?.convert())
    }

    @discardableResult open func set(_ value: Float, forKey key: String, withAccessibility accessibility: PTKeychainAccessibility? = nil) -> Bool {
        return self.keychainWrapper.set(value, forKey: key, withAccessibility: accessibility?.convert())
    }

    @discardableResult open func set(_ value: Double, forKey key: String, withAccessibility accessibility: PTKeychainAccessibility? = nil) -> Bool {
        return self.keychainWrapper.set(value, forKey: key, withAccessibility: accessibility?.convert())
    }

    @discardableResult open func set(_ value: Bool, forKey key: String, withAccessibility accessibility: PTKeychainAccessibility? = nil) -> Bool {
        return self.keychainWrapper.set(value, forKey: key, withAccessibility: accessibility?.convert())
    }

    @discardableResult open func set(_ value: String, forKey key: String, withAccessibility accessibility: PTKeychainAccessibility? = nil) -> Bool {
        return self.keychainWrapper.set(value, forKey: key, withAccessibility: accessibility?.convert())
    }

    @discardableResult open func set(_ value: NSCoding, forKey key: String, withAccessibility accessibility: PTKeychainAccessibility? = nil) -> Bool {
        return self.keychainWrapper.set(value, forKey: key, withAccessibility: accessibility?.convert())
    }

    @discardableResult open func set(_ value: Data, forKey key: String, withAccessibility accessibility: PTKeychainAccessibility? = nil) -> Bool {
        return self.keychainWrapper.set(value, forKey: key, withAccessibility: accessibility?.convert())
    }
    
    //
    // MARK: - GET
    //
    open func integer(forKey key: String, withAccessibility accessibility: PTKeychainAccessibility? = nil) -> Int? {
        return self.keychainWrapper.integer(forKey: key, withAccessibility: accessibility?.convert())
    }
    
    open func float(forKey key: String, withAccessibility accessibility: PTKeychainAccessibility? = nil) -> Float? {
        return self.keychainWrapper.float(forKey: key, withAccessibility: accessibility?.convert())
    }
    
    open func double(forKey key: String, withAccessibility accessibility: PTKeychainAccessibility? = nil) -> Double? {
        return self.keychainWrapper.double(forKey: key, withAccessibility: accessibility?.convert())
    }
    
    open func bool(forKey key: String, withAccessibility accessibility: PTKeychainAccessibility? = nil) -> Bool? {
        return self.keychainWrapper.bool(forKey: key, withAccessibility: accessibility?.convert())
    }
    
    open func string(forKey key: String, withAccessibility accessibility: PTKeychainAccessibility? = nil) -> String? {
        return self.keychainWrapper.string(forKey: key, withAccessibility: accessibility?.convert())
    }
    
    open func object(forKey key: String, withAccessibility accessibility: PTKeychainAccessibility? = nil) -> NSCoding? {
        return self.keychainWrapper.object(forKey: key, withAccessibility: accessibility?.convert())
    }
    
    open func data(forKey key: String, withAccessibility accessibility: PTKeychainAccessibility? = nil) -> Data? {
        return self.keychainWrapper.data(forKey: key, withAccessibility: accessibility?.convert())
    }
    
    //
    // MARK: - REMOVE
    //
    @discardableResult open func removeObject(forKey key: String, withAccessibility accessibility: PTKeychainAccessibility? = nil) -> Bool {
        return self.keychainWrapper.removeObject(forKey: key, withAccessibility: accessibility?.convert())
    }
    
   
    open func removeAllKeys() -> Bool {
        return self.keychainWrapper.removeAllKeys()
    }
    
    //
    // MARK: - TEST
    //
}
