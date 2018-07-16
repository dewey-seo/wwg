//
//  PTUser.swift
//  Path
//
//  Created by dewey on 2018. 6. 28..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit
import RealmSwift

enum PTPlaceType: Int {
    case unknown
    case favorite
    case significant
    
    func storage(_ user: PTUser) -> List<PTPlace>? {
        switch self {
        case .unknown:
            return nil
        case .favorite:
            return user.favoritePlaces
        case .significant:
            return user.significantPlaces
        }
    }
}

class PTUser: PTModel {
    @objc dynamic var nickName = "unknown"
    @objc dynamic var profileImageUrl: String?
    @objc dynamic var thumbnailImageUrl: String?
    
    var favoritePlaces = List<PTPlace>()
    var significantPlaces = List<PTPlace>()

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
    
    func isMyPlace(type: PTPlaceType, place: PTPlace) -> Bool {
        guard let storage = type.storage(self) else {
            print("place type is not defined")
            return false
        }
        
        let result = storage.filter("id = %@", place.id)
        
        if result.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    func addPlace(type: PTPlaceType, place: PTPlace, syncWithServer: Bool, _ completion: (() -> Void)?) {
        guard let storage = type.storage(self) else {
            assert(false, "place type is not defined")
        }
        
        if self.isMyPlace(type: type, place: place) == false {
            try! PTDBManager.shared.realm.write {
                storage.append(place)
            }
        }
        
        if let block = completion {
            block()
        }
    }
    
    func removePlace(type: PTPlaceType, place: PTPlace, syncWithServer: Bool, _ completion: (() -> Void)?) {
        guard let storage = type.storage(self) else {
            assert(false, "place type is not defined")
        }
        
        if let index = storage.index(matching: "id = %@", place.id) {
            try! PTDBManager.shared.realm.write {
                storage.remove(at: index)
            }
        }
        
        if let block = completion {
            block()
        }
    }
}
