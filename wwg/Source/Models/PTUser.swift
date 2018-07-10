//
//  PTUser.swift
//  Path
//
//  Created by dewey on 2018. 6. 28..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit
import RealmSwift

class PTUser: PTModel {
    @objc dynamic var nickName = "unknown"
    @objc dynamic var profileImageUrl: String?
    @objc dynamic var thumbnailImageUrl: String?
    
    var places = List<PTPlace>()
    
    static func createUser(userInfo: KOUserMe) -> PTUser {
        let user = PTUser()
        
        if let id = userInfo.id {
            user.id = id
        }
        
        if let properties = userInfo.properties {
            user.nickName = properties["nickname"] ?? user.nickName
            user.profileImageUrl = properties["profile_image"]
            user.thumbnailImageUrl = properties["thumbnail_image"]
        }
        
        return user
    }
    
    func isMyPlace(_ place: PTPlace) -> Bool {
        let result = self.places.filter("id = %@", place.id)
        if result.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    func addPlace(_ place: PTPlace, syncWithServer: Bool, _ completion: @escaping () -> Void) {
        if syncWithServer == true {
            PTApiRequest.request().savePlace(place: place, userId: self.id).observeCompletion { (response) in
                if response.isSuccess == true {
                    print(response)
                    
                    if self.isMyPlace(place) == false {
                        try! PTDBManager.shared.realm.write {
                            self.places.append(place)
                        }
                    }
                }
                completion()
            }
        } else {
            if self.isMyPlace(place) == false {
                try! PTDBManager.shared.realm.write {
                    self.places.append(place)
                }
            }
            completion()
        }

    }
    
    func removePlace(_ place: PTPlace, syncWithServer: Bool, _ completion: @escaping () -> Void) {
        if syncWithServer == true {
            PTApiRequest.request().deletePlace(place: place, userId: self.id).observeCompletion { (response) in
                if response.isSuccess == true {
                    if let index = self.places.index(matching: "id = %@", place.id) {
                        try! PTDBManager.shared.realm.write {
                            self.places.remove(at: index)
                        }
                    }
                }
                completion()
            }
        } else {
            if let index = self.places.index(matching: "id = %@", place.id) {
                try! PTDBManager.shared.realm.write {
                    self.places.remove(at: index)
                }
            }
            completion()
        }
        
    }
}
