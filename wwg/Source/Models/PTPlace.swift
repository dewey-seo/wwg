//
//  PTPlace.swift
//  Path
//
//  Created by dewey on 2018. 6. 28..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit
import RealmSwift
import CoreLocation

class PTPlace: PTModel {
    
    // Dynamic
    @objc dynamic var name: String = ""
    @objc dynamic var address: String = ""
    @objc dynamic var roadAddress: String = ""
    
    @objc dynamic var placeUrl: String?
    @objc dynamic var webUrl: String?
    @objc dynamic var phone: String?
    
    @objc dynamic var latitude: Double = 0.0 // 위도
    @objc dynamic var longitude: Double = 0.0 // 경도
    
    let favoriteUsers = LinkingObjects(fromType: PTUser.self, property: "favoritePlaces")
    let significantUsers = LinkingObjects(fromType: PTUser.self, property: "significantPlaces")
    
    // instantv
    var distance: Double?
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static func createPlace(placeInfo: [String: Any]) -> PTPlace? {
        let place = PTPlace()
        if let name = (placeInfo["place_name"] as? String ?? placeInfo["address_name"] as? String), let longitude = (placeInfo["x"] as? NSString)?.doubleValue, let latitue = (placeInfo["y"] as? NSString)?.doubleValue {
            
            if let id = placeInfo["id"] as? String {
                place.id = id
            } else {
                place.id = NSUUID().uuidString
                place.isCustomId = true
            }
            
            place.name = name
            place.latitude = latitue
            place.longitude = longitude
            
            if let placeUrl = placeInfo["place_url"] as? String { place.placeUrl = placeUrl }
            if let webUrl = placeInfo["web_url"] as? String { place.webUrl = webUrl }
            if let phone = placeInfo["phone"] as? String { place.phone = phone }

            PTPlace.save([place])
            
            return place
        } else {
            return nil
        }
    }
    
    static func createPlaces(placeInfos: [[String: Any]]) -> List<PTPlace> {
        let places = List<PTPlace>()
        for placeInfo in placeInfos {
            if let place = PTPlace.createPlace(placeInfo: placeInfo) {
                places.append(place)
            }
        }
        
        return places
    }
    
    func dictionary() -> Dictionary<String, Any> {
        var postDictionary = Dictionary<String, Any>()
        
        postDictionary["id"] = self.id
        postDictionary["name"] = self.name
        postDictionary["address"] = self.address
        postDictionary["roadAddress"] = self.roadAddress
        postDictionary["placeUrl"] = self.placeUrl
        postDictionary["webUrl"] = self.webUrl
        postDictionary["phone"] = self.phone
        postDictionary["latitude"] = self.latitude
        postDictionary["longitude"] = self.longitude
       
        return postDictionary
    }
}

extension PTPlace {
    static public func distance(placeA: PTPlace, placeB: PTPlace) -> CLLocationDistance{
        let locA = CLLocation(latitude: placeA.latitude, longitude: placeA.longitude)
        let locB = CLLocation(latitude: placeB.latitude, longitude: placeB.longitude)
        
        let distance = locA.distance(from: locB)
        
        return distance
    }
}
