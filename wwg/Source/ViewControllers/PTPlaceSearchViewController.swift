//
//  PTPlaceSearchViewController.swift
//  wwg
//
//  Created by dewey on 2018. 7. 16..
//  Copyright © 2018년 dewey. All rights reserved.
//

import UIKit
import RealmSwift

class PTPlaceSearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var placeType: PTPlaceType = .unknown
    
    var searchResult: List<PTPlace>?
    var currentSearchText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchBar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.searchBar.becomeFirstResponder()
    }
    
    func close() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension PTPlaceSearchViewController: UITableViewDelegate, UITableViewDataSource {
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
        self.searchBar.resignFirstResponder()
        
        if let place = searchResult?[indexPath.row] {
            let popupView = PTPlacePopupView(frame: CGRect(x: 0, y: 0, width: PTPlacePopupView.defaultSize().width, height: PTPlacePopupView.defaultSize().height))
            popupView.placeType = self.placeType
            popupView.place = place
            PTPopupViewManager.showPopupView(popupView, withAnimation: true)
            PTPopupViewManager.delegate = self
            
            // get google info
            PTApiRequest.request().getGoogleInfo(place: place).observeCompletion { (response) in
                if response.isSuccess == true {
                    print(response)
                }
            }
        }
    }
}

extension PTPlaceSearchViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.close()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let currentText = self.currentSearchText {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(search), object: currentText)
        }
        
        self.currentSearchText = searchText
        self.perform(#selector(search), with: self.currentSearchText, afterDelay: 0.5)
    }
    
    @objc func search(_ searchText: String) {
        self.currentSearchText = nil
        
        debugPrint("search: \(searchText)")
        
        if searchText.count != 0 {
            PTPlaceSearchHelper.shared.search(searchText) { (isSuccess, result) in
                self.showSearchResult(success: isSuccess, result: result)
            }
        }
    }
    
    func showSearchResult(success: Bool, result: [[String: Any]]?) {
        if let json = result, json.count > 0 && success == true {
            debugPrint("success search")
            self.searchResult = PTPlace.createPlaces(placeInfos: json)
            self.tableView.reloadData()
        } else {
            debugPrint("failed search")
            // show empty or failed search display
        }
    }
}

extension PTPlaceSearchViewController: PTPopupViewShareDelegate {
    func popupViewStateShare(state: PTPopupViewState) {
        if case .closed = state {
            self.searchBar.becomeFirstResponder()
        }
    }
}
