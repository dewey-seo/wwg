//
//  PTDBManager.swift
//  Path
//
//  Created by dewey on 2018. 6. 28..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit
import RealmSwift

let RealmQueue = DispatchQueue(label: "realm_queue", attributes: .concurrent)

class PTDBManager: NSObject {
    static let shared: PTDBManager = { return PTDBManager() }()
    
    let realm = try! Realm()
    
    func deleteAll() {
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func save<Element: Object>(type: Element.Type, object: PTModel) {
        try! realm.write {
            if realm.object(ofType: type, forPrimaryKey: object.id) != nil {
                realm.add(object, update: true)
            } else {
                realm.add(object, update: false)
            }
        }
    }
    
    func save<Element: Object>(type: Element.Type, objects: [PTModel]) {    
        for object in objects {
            self.save(type: type, object: object)
        }
    }
    
    func get<Element: Object>(type: Element.Type, id: String) -> Object? {
        let object = realm.object(ofType: type, forPrimaryKey: id)
        return object
    }
    
    func get<Element: Object>(type: Element.Type, query: String? = nil) -> Results<Element>? {
        let results = realm.objects(type)
        
        if results.count > 0 {
            return results
        } else {
            return nil
        }
    }
    
    
    func delete<Element: Object>(type: Element.Type, objects: [PTModel]){
        let ids = objects.map { $0.id }
        let results = realm.objects(type).filter("id IN %@", ids)
            
        if results.count > 0 {
            try! realm.write {
                realm.delete(results)
            }
        }
    }
}
