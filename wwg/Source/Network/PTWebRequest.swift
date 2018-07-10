//
//  PTWebRequest.swift
//  Path
//
//  Created by dewey on 2018. 6. 19..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit
import Alamofire

class PTWebRequest: NSObject {
    var url: String?
    var encoding: ParameterEncoding?
    var uParameters: [String: String]?
    var bParameters: [String: Any]?
    var hParameters: [String: String]?
    var observers: [PTApiObserver]?
    var header: HTTPHeaders = PTSessionManager.defaultHTTPHeader
    
    var dataRequest: DataRequest?
    
    override init() {
        super.init()
    }
    
    deinit {
        print("PTApiRequest deinit check")
    }
    
    public func deliver(method: HTTPMethod) {
        if let hParameters = self.hParameters {
            for value in hParameters {
                header[value.key] = value.value
            }
        }
        self.send(method: method)
    }
    
    public func send(method: HTTPMethod) {
        guard let url = self.url else {
            print("error : \(#function) - url is nil")
            return
        }
        
        if case method = HTTPMethod.get {
            Alamofire.request(url, method: method, parameters: self.bParameters, encoding: URLEncoding.default, headers: self.header).responseJSON { (response) in
                self.sendResponseToObservers(response)
            }
        } else if case method = HTTPMethod.post {
            Alamofire.request(url, method: method, parameters: self.bParameters, encoding: JSONEncoding.default, headers: self.header).responseJSON { (response) in
                self.sendResponseToObservers(response)
            }
        }
    }
    
    open func sendResponseToObservers(_ response: Any) {
        let convRes = PTApiResponse.init(withResponse: response)
        
        if let obserbers = self.observers {
            for observer in obserbers {
                if let completionBlock = observer.completionBlock {
                    completionBlock(convRes)
                }
            }
        }
    }
    
    public func addParameter(key: String, value: Any) {
        if self.bParameters == nil { self.bParameters = [String: Any]()}
        
        self.bParameters![key] = value
    }
    
    public func addParameters(_ parameters: Dictionary<String, Any>) {
        if self.bParameters == nil { self.bParameters = [String: Any]()}
        
        for key in parameters.keys {
            self.bParameters![key] = parameters[key]
        }
    }
    
    public func addHeaderValue(key: String, value: String) {
        if self.hParameters == nil { self.hParameters = [String: String]()}
        
        self.hParameters![key] = value
    }
    
    @discardableResult public func observeCompletion(_ response: @escaping PTApiRequestCompletionBlock)  -> Self {
        if self.observers == nil { self.observers = Array()}
        
        let requestObserver = PTApiObserver()
        requestObserver.completionBlock = response
        
        self.observers?.append(requestObserver)
        
        return self
    }
}
