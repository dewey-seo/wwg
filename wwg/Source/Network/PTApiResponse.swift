//
//  PTApiResponse.swift
//  Path
//
//  Created by dewey on 2018. 6. 18..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit
import Alamofire

enum PTApiResponseStatus: Int {
    case PTApiStatusDefault = -1
    
    case PTApiStatusOK = 200
    case PTApiStatusUnauthorized = 401
    case PTApiStatusNotFound = 404
}

class PTApiResponse: NSObject {
    var status: PTApiResponseStatus = .PTApiStatusDefault
    var url: URL?
    var isSuccess: Bool = false
    var jsonResult: Dictionary<String, Any>?
    
    override init() {
        super.init()
    }
    
    deinit {
        print("PTApiResponse deinit check")
    }
    
    // todo: successblock and failedblock
    init(withResponse response: Any) {
        super.init()
        if let res = response as? DataResponse<Any> {
            // url
            self.url = res.request?.url
            
            // isSucess
            self.isSuccess = res.result.isSuccess
            
            // json data
            switch res.result {
            case .failure(let error):
                print("\(error.localizedDescription)")
                return
                
            case .success(let data):
                guard let json = data as? [String : AnyObject] else {
                    print("Failed to get expected response from webserver.")
                    return
                }
                
                self.jsonResult = json
            }
        }
    }
}
