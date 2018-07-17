//
//  PTKakaoLocationSearchViewController.swift
//  Path
//
//  Created by dewey on 2018. 6. 26..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit
import RealmSwift

class PTKakaoLocationSearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var searchResult: List<PTPlace>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    @IBAction func searchAction(_ sender: Any) {
        if let inputString = searchTextField.text, inputString.count != 0 {
            self.keywordSearch(inputString) { (found) in
                if found != true {
                    self.addressSearch(inputString)
                }
            }
        }
        
        if let searchString = searchTextField.text, searchString.count != 0 {
            
        }
    }
    
    func keywordSearch(_ searchString: String, completion: @escaping (Bool) -> Void) {
        PTApiRequest.request().placeKeywordSearchForKakao(search: searchString).observeCompletion { (response) in
            if let json = response.jsonResult, let documents = json["documents"] as? [[String: Any]], documents.count > 0 {
                self.searchResult = PTPlace.createPlaces(placeInfos: documents)
                self.tableView.reloadData()
                
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func addressSearch(_ searchString: String) {
        PTApiRequest.request().placeAddressSearchForKakao(search: searchString).observeCompletion { (response) in
            if let json = response.jsonResult, let documents = json["documents"] as? [[String: Any]], documents.count > 0 {
                self.searchResult = PTPlace.createPlaces(placeInfos: documents)
            } else {
                self.searchResult = List<PTPlace>()
            }
            self.tableView.reloadData()
        }
    }
}


extension PTKakaoLocationSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cells")
        if cell == nil {
            cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "cells")
        }
        
        if let place = searchResult?[indexPath.row] {
            cell?.textLabel?.text = place.name
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchTextField?.resignFirstResponder()
        
        if let place = searchResult?[indexPath.row] {
            let popupView = PTPlacePopupView(frame: CGRect(x: 0, y: 0, width: 200, height: 300))
            popupView.place = place
            PTPopupViewManager.showPopupView(popupView, withAnimation: true)
            
            // get google info
            PTApiRequest.request().getGoogleInfo(place: place).observeCompletion { (response) in
                if response.isSuccess == true {
                    print(response)
                }
            }
        }
    }
}

