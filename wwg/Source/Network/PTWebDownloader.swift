//
//  PTWebDownloader.swift
//  Path
//
//  Created by dewey on 2018. 6. 19..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit
import Alamofire

typealias PTWebDownloadingBlock = ((Float) -> Void);

class PTWebDownloader: NSObject {
    var url: String?
    var observers: [PTApiObserver]?
    
    var request: DownloadRequest?
    
    public func start() {
        if let url = self.url {
            let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
            self.request = Alamofire.download(url, to: destination).downloadProgress { (progress) in
                print(progress)
                }.response { (response) in
                    print(response)
            }
        }
    }
    
    public func cancel() {
        self.request?.cancel()
    }
    
    public func pause() {
        self.request?.suspend()
    }
    
    public func resume() {
        self.request?.resume()
    }
}

extension PTWebDownloader {
    public func testDownload(_ url: String) -> Self {
        self.url = url
        
        self.start()
        return self
    }
}
