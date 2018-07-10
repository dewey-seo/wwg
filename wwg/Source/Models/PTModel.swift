//
//  PTModel.swift
//  Path
//
//  Created by dewey on 2018. 6. 29..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit
import RealmSwift

class PTModel: Object {
    @objc dynamic var id = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func save(_ objects: [PTModel]) {
        PTDBManager.shared.save(type: self, objects: objects)
    }
    
    static func delete(_ objects: [PTModel]) {
        PTDBManager.shared.delete(type: self, objects: objects)
    }
}
