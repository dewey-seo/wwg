//
//  PTPlaceSaveViewController.swift
//  wwg
//
//  Created by dewey on 2018. 8. 23..
//  Copyright © 2018년 dewey. All rights reserved.
//

import UIKit

class PTPlaceSaveViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navCancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeVC))
        self.navigationItem.leftBarButtonItem = navCancelButton
    }

    @objc func closeVC() {
        self.dismiss(animated: true, completion: nil)
    }
}
