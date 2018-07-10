//
//  PTAnimation.swift
//  Path
//
//  Created by dewey on 2018. 6. 25..
//  Copyright © 2018년 path. All rights reserved.
//

import Foundation

typealias PTAnimationDelegateStartBlock = () -> Void
typealias PTAnimationDelegateFinishBlock = (_ finished: Bool) -> Void

class PTAnimationDelegate: NSObject, CAAnimationDelegate {
    var startBlock:PTAnimationDelegateStartBlock?
    var finishBlock:PTAnimationDelegateFinishBlock?
    
    func animationDidStart(_ anim: CAAnimation) {
        debugPrint(#function)
        if let startBlock = self.startBlock {
            startBlock()
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        debugPrint(#function)
        if let finishBlock = self.finishBlock {
            finishBlock(flag)
        }
    }
    
    deinit {
        debugPrint("PTAnimationDelegate deinit check")
    }
}

extension CALayer {
    func addAnimation(_ anim: CAAnimation, forKey key: String?, startBlock:PTAnimationDelegateStartBlock? = nil, finishBlock:PTAnimationDelegateFinishBlock? = nil) {
        let animationDelegate = PTAnimationDelegate()
        
        animationDelegate.startBlock = startBlock
        animationDelegate.finishBlock = finishBlock
        anim.delegate = animationDelegate
        
        self.add(anim, forKey: key)
    }
}
