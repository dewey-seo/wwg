//
//  PTApiObserver.swift
//  Path
//
//  Created by dewey on 2018. 6. 18..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit

// typealias completionBlockType = (NSString, NSError!) ->Void

typealias PTApiRequestCompletionBlock = ((PTApiResponse) -> Void);
typealias PTApiUploadingBlock = ((Float) -> Void);

class PTApiObserver: NSObject {
    
    var delegate: AnyClass?
    
    var completionSelector: Selector?
    var downloadingSelector: Selector?
    var uploadingSelector: Selector?
    
    var completionBlock: PTApiRequestCompletionBlock?
    
    deinit {
        print("PTApiObserver deinit check")
    }
}
