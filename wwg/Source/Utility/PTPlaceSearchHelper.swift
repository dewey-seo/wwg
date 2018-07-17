//
//  PTPlaceSearchHelper.swift
//  wwg
//
//  Created by dewey on 2018. 7. 17..
//  Copyright © 2018년 dewey. All rights reserved.
//

import UIKit

typealias PTPlaceSearchCompletion = (_ success: Bool, _ result: [[String: Any]]?) -> Void

class PTPlaceSearchHelper: NSObject {
    static let shared: PTPlaceSearchHelper = { return PTPlaceSearchHelper() }()
    
    func search(_ searchText: String, completion: @escaping PTPlaceSearchCompletion) {
        if searchText.count != 0 {
            self.keywordSearch(searchText) { (found, json) in
                if found != true {
                    self.addressSearch(searchText) { (found, json) in
                        completion(found, json)
                    }
                } else {
                    completion(found, json)
                }
            }
        }
    }
    
    func keywordSearch(_ searchString: String, _ completion: @escaping (Bool, [[String: Any]]?) -> Void) {
        PTApiRequest.request().placeKeywordSearchForKakao(search: searchString).observeCompletion { (response) in
            if let json = response.jsonResult, let documents = json["documents"] as? [[String: Any]], documents.count > 0 {
                completion(true, documents)
            } else {
                completion(false, nil)
            }
        }
    }
    
    func addressSearch(_ searchString: String, _ completion: @escaping (Bool, [[String: Any]]?) -> Void) {
        PTApiRequest.request().placeAddressSearchForKakao(search: searchString).observeCompletion { (response) in
            if let json = response.jsonResult, let documents = json["documents"] as? [[String: Any]], documents.count > 0 {
                completion(true, documents)
            } else {
                completion(false, nil)
            }
        }
    }
}
