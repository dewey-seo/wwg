//
//  PTDeviceInfo.swift
//  Path
//
//  Created by dewey on 2018. 6. 21..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit

class PTDeviceInfo: NSObject {
    static public let UUID: String! = {
        return UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
    }()
    
    static public let currentLocale: String! = {
        return NSLocale.current.identifier
    }()
    
    static public let currentLanguage: String! = {
        return NSLocale.preferredLanguages.first ?? "en"
    }()
}
