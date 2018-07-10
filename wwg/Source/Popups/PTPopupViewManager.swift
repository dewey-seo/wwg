//
//  PTPopupViewManager.swift
//  Path
//
//  Created by dewey on 2018. 6. 22..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit

typealias PTPopupViewControllerPresentBlock = (PTPopupViewController) -> Void

class PTPopupViewManager: NSObject {

    static let sharedInstance: PTPopupViewManager = { return PTPopupViewManager() }()
    
    var popupViewState: PTPopupViewState = .closed
    
    var popupViewController: PTPopupViewController?
    var baseViewController: UIViewController {
        return AppDelegate.topViewController()
    }
    
    static func showPopupView(_ popupView: UIView, withAnimation animated:Bool) {
        let shared = PTPopupViewManager.sharedInstance
        
        shared.presentPopupViewControllerIfNeeded { (popupViewController) in
            popupViewController.showPopupView(popupView, animated: animated)
        }
    }
    
    static func hidePopupView(animated: Bool, hideContext: PTPopupViewHideContext = .unknown) {
        let shared = PTPopupViewManager.sharedInstance
        
        if let popupViewController = shared.popupViewController {
            popupViewController.hidePopupView(animated: animated, hideContext: hideContext)
        }
    }
    
    private func presentPopupViewControllerIfNeeded(_ completion:@escaping PTPopupViewControllerPresentBlock) {
        if let popupViewController = self.popupViewController {
            completion(popupViewController)
        } else {
            self.popupViewController = PTPopupViewController(nibName: "PTPopupViewController", bundle: nil)
            if let popupViewController = self.popupViewController {
                
                popupViewController.delegate = self
                
                self.preparePresentPopupViewController()
                self.baseViewController.present(popupViewController, animated: false) {
                    completion(popupViewController)
                }
            }
        }
    }
    
    private func preparePresentPopupViewController() {
        if let popupViewController = self.popupViewController {
            popupViewController.providesPresentationContextTransitionStyle = true
            popupViewController.definesPresentationContext = true
            popupViewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
            popupViewController.view.backgroundColor = popupViewController.backgroundColor(alpha: PTPopupViewControllerBGAlpha)
        }
    }
}

extension PTPopupViewManager: PTPopupViewShareDelegate {
    func popupViewStateShare(state: PTPopupViewState) {
        self.popupViewState = state
        
        if case .closed = state {
            self.popupViewController = nil
        }
    }
}
