//
//  PTSettingViewController.swift
//  Path
//
//  Created by dewey on 2018. 7. 2..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit

class PTSettingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(_ sender: Any) {
        PTLoginManager.shared.kakaoLogout { (success, logoutInfo) in
            AppDelegate.rootViewController().mainVC?.close()
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
