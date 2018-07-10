//
//  PTRootViewController.swift
//  wwg
//
//  Created by dewey on 2018. 7. 10..
//  Copyright © 2018년 dewey. All rights reserved.
//

import UIKit

typealias PTRootViewRefreshBlock = () -> Void

class PTRootViewController: UIViewController {

    var isFirstAccess: Bool = true
    var mainVC: PTMainViewController?
    var loginVC: PTLoginViewController?
    var navC: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if isFirstAccess == true {
            self.prepareChangeViewController()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.isFirstAccess = false
    }
    
    private func prepareChangeViewController() {
        if KOSession.shared().isOpen() {
            self.mainVC = PTMainViewController(nibName: "PTMainViewController", bundle: nil)
            if self.mainVC != nil {
                self.showVC(self.mainVC!)
                self.mainVC?.dismissBlock = {
                    self.prepareChangeViewController()
                }
            }
        } else {
            self.loginVC = PTLoginViewController(nibName: "PTLoginViewController", bundle: nil)
            if self.loginVC != nil {
                self.showVC(self.loginVC!)
                self.loginVC?.dismissBlock = {
                    self.prepareChangeViewController()
                }
            }
        }
    }
    private func showVC(_ vc: UIViewController) {
        vc.providesPresentationContextTransitionStyle = true
        vc.definesPresentationContext = true
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
        
        vc.view.alpha = 0.0
        self.present(vc, animated: false) {
            UIView.animate(withDuration: 0.2, animations: {
                vc.view.alpha = 1.0
            })
        }
    }
}
