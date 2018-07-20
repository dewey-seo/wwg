//
//  PTPlaceInfoWebViewController.swift
//  wwg
//
//  Created by dewey on 2018. 7. 17..
//  Copyright © 2018년 dewey. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

class PTPlaceInfoWebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    var kakaoPlaceId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let kakaoPlaceId = self.kakaoPlaceId {
            if let url = URL(string: "https://place.map.daum.net/\(kakaoPlaceId)") {
                self.webView.load(URLRequest(url: url))
            }
        }
        
        let barButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc private func close() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
