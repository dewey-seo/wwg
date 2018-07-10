//
//  PTSessionManager.swift
//  Path
//
//  Created by dewey on 2018. 6. 27..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit
import Alamofire

class PTSessionManager: NSObject {
    static let sharedInstance: PTSessionManager = { return PTSessionManager() }()
    
    static let defaultHTTPHeader: HTTPHeaders = Alamofire.SessionManager.defaultHTTPHeaders
    /*
    static let defaultHTTPHeader: HTTPHeaders = {
        let acceptEncoding: String = "gzip;q=1.0, compress;q=0.5"
        let acceptLanguage = Locale.preferredLanguages.prefix(6).enumerated().map { index, languageCode in
            let quality = 1.0 - (Double(index) * 0.1)
            return "\(languageCode);q=\(quality)"
            }.joined(separator: ", ")
        
        let contentType: String = "multipart/form-data; boundary=------\(PTDeviceInfo.UUID)"
        let userAgent: String = "Path/1 CFNetwork/758.1.6 Darwin/15.6.0"
        let appString: String = "shr"
        let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let bundleId: String = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
        let location: String = NSLocale.current.languageCode ?? "en_US"
        let deviceModel: String = UIDevice.current.model
        let Platform: String = {
            let version = ProcessInfo.processInfo.operatingSystemVersion
            let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
            
            let osName: String = {
                #if os(iOS)
                return "iOS"
                #elseif os(watchOS)
                return "watchOS"
                #elseif os(tvOS)
                return "tvOS"
                #elseif os(macOS)
                return "OS X"
                #elseif os(Linux)
                return "Linux"
                #else
                return "Unknown"
                #endif
            }()
            return "\(osName) \(versionString)"
        }()
        
        let defaultHeaderSet = [
            "Accept-Language": acceptLanguage,
            "Accept-Encoding": acceptEncoding,
            "Content-Type": contentType,
            "User-Agent": userAgent,
            "X-PATH-APP": appString,
            "X-PATH-BUNDLE-ID": bundleId,
            "X-PATH-CLIENT": appVersion,
            "X-PATH-DEVICE": deviceModel,
            "X-PATH-LANGUAGE": PTDeviceInfo.currentLanguage,
            "X-PATH-LOCALE": PTDeviceInfo.currentLocale,
            "X-PATH-PLATFORM": Platform,
            "X-PATH-UUID": PTDeviceInfo.UUID
        ]
        
        return defaultHeaderSet as! HTTPHeaders
    }()
     */
}
