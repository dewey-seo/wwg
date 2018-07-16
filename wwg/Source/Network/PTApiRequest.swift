//
//  PTApiRequest.swift
//  Path
//
//  Created by dewey on 2018. 6. 18..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit
import Alamofire

let TEST_API_HOST = "http://127.0.0.1:8000"
let GOOLE_MAP_HOST = "https://maps.googleapis.com/maps/api"
let KAKAO_REST_API_APPKEY = "KakaoAK ab6bd6892062c5907d07bf9859247295"

class PTApiRequest: PTWebRequest {
    static public func request() -> PTApiRequest {
        return PTApiRequest.init()
    }
    
    func setKakaoAuthorization(_ authorization: Bool) {
        if authorization == true {
            self.addHeaderValue(key: "Authorization", value: KAKAO_REST_API_APPKEY)
        }
    }
}


// MARK: - API List
extension PTApiRequest {
    func kakaoLogin(token: String) -> Self {
        self.url = "\(TEST_API_HOST)/account/login/kakao"
        self.addParameter(key: "token", value: token)
        
        self.deliver(method: .post)
        return self
    }
    
    func placeKeywordSearchForKakao(search: String) -> Self{
       
        self.url = "https://dapi.kakao.com/v2/local/search/keyword.json"
        self.setKakaoAuthorization(true)
        
        self.addParameter(key: "query", value: search)
        
        self.encoding = URLEncoding.default
        self.deliver(method: .get)
        
        return self
    }
    
    func placeAddressSearchForKakao(search: String) -> Self {
        self.url = "https://dapi.kakao.com//v2/local/search/address.json"
        self.setKakaoAuthorization(true)
        
        self.addParameter(key: "query", value: search)
        
        self.encoding = URLEncoding.default
        self.deliver(method: .get)
        
        return self
    }
    
    func savePlace(place: PTPlace, userId: String) -> Self {
        self.url = "\(TEST_API_HOST)/place/save"
        
        self.addParameters(place.dictionary())
        self.addParameter(key: "userId", value: userId)
        
        self.deliver(method: .post)
        
        return self
    }
    
    func deletePlace(place: PTPlace, userId: String) -> Self {
        self.url = "\(TEST_API_HOST)/place/delete"
        
        self.addParameter(key: "id", value: place.id)
        self.addParameter(key: "userId", value: userId)
        
        self.deliver(method: .post)
        
        return self
    }
    
    func getPlaceList(userId: String) -> Self {
        self.url = "\(TEST_API_HOST)/place/list"
        
        self.addParameter(key: "userId", value: userId)
        self.deliver(method: .get)
        
        return self
    }
    
    func getGoogleInfo(place: PTPlace) -> Self {
        self.url = "\(GOOLE_MAP_HOST)/place/nearbysearch/json"

        self.addParameter(key: "location", value: "\(place.latitude),\(place.longitude)")
        self.addParameter(key: "radius", value: "20")
        self.addParameter(key: "keyword", value: place.name)
        self.addParameter(key: "key", value: GOOGLE_API_KEY)
        
        self.deliver(method: .get)
        
        return self
    }
}
