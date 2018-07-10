//
//  PTGeometry.swift
//  Path
//
//  Created by dewey on 2018. 6. 22..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit

extension Double {
    func toRadians() -> Double {
        return self * .pi / 180.0
    }
}

extension UIView {
    func convertRectToThisView(_ view: UIView) -> CGRect {
        return CGRect(x: 0, y: 0, width: 0, height: 0)
    }
}

extension CGRect {
    func center() -> CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
}
