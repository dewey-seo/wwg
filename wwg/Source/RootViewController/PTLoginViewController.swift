//
//  PTLoginViewController.swift
//  Path
//
//  Created by dewey on 2018. 7. 2..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit

class PTLoginViewController: UIViewController {

    var dismissBlock: PTRootViewRefreshBlock?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func close() {
        self.dismiss(animated: true) {
            if let block = self.dismissBlock {
                block()
            }
        }
    }
    
    @IBAction func kakaoLogin(_ sender: Any) {
        PTLoginManager.shared.kakaoLogin { (success, loginInfo) in
            if success == true {
            } else {
                print("login Error")
            }
            self.close()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
