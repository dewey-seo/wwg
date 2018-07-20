//
//  PTPopupView.swift
//  wwg
//
//  Created by dewey on 2018. 7. 18..
//  Copyright © 2018년 dewey. All rights reserved.
//

import UIKit

@objc protocol PTPopupViewDelegate: AnyObject {
    @objc optional func popupViewNeedChangeSize(_ size: CGSize)
    @objc optional func popupViewPresentViewController(_ vc: UIViewController, completion: (() -> Void)?)
}

class PTPopupView: PTXibView {
    weak var delegate: PTPopupViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.rasterizationScale = UIScreen.main.scale
        self.layer.shouldRasterize = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
