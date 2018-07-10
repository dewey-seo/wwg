//
//  PTColor.swift
//  Path
//
//  Created by dewey on 2018. 6. 18..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit

class PTColor: UIColor {
    
}


extension UIColor {
    public convenience init(R: CGFloat, G: CGFloat, B: CGFloat, A: CGFloat) {
        self.init(red: R/255, green: R/255, blue: R/255, alpha: A)
    }
}
