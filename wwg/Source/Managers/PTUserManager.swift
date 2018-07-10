//
//  PTUserManager.swift
//  Path
//
//  Created by dewey on 2018. 6. 18..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit
import RealmSwift

class PTUserManager: NSObject {
    static let shared: PTUserManager = { return PTUserManager() }()
    
    static func currentUser() -> PTUser? {
        // TODO: todo
        let results = PTDBManager.shared.get(type: PTUser.self)
        
        if let user = results?.first {
            return user
        } else {
            return nil
        }
    }
}
