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
    @objc dynamic var isCustomId: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func get<T: PTModel>(_ id: String) -> T? {
        if let model = PTDBManager.shared.get(type: self, id: id) as? T {
            return model
        } else {
            return nil
        }
    }
    
    static func save<T: PTModel>(_ objects: [T]) {
        PTDBManager.shared.save(type: self, objects: objects)
    }
    
    static func delete<T: PTModel>(_ objects: [T]) {
        PTDBManager.shared.delete(type: self, objects: objects)
    }
}
