//
//  PTMyPlacesTabViewController.swift
//  wwg
//
//  Created by dewey on 2018. 7. 17..
//  Copyright © 2018년 dewey. All rights reserved.
//

import UIKit
import RealmSwift

class PTMyPlacesTabViewController: UIViewController {
    
    // TODO : Group / Location Group / Created / Distance Sort.
    // TODO : Search Empty / typing auto search
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchController : UISearchController!
    
    var searchResult = List<PTPlace>()
    var myPlaces = List<PTPlace>()
    var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchController = UISearchController(searchResultsController:  nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        
        self.navigationItem.titleView = searchController.searchBar
        self.definesPresentationContext = true
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.fetchMyplacesItems()
    }
    
    private func fetchMyplacesItems() {
        if let currentUser = PTUserManager.currentUser() {
            // remove current notification
            self.notificationToken?.invalidate()
            self.notificationToken = nil
            
            // get new result
            self.myPlaces = currentUser.favoritePlaces
            self.notificationToken = self.myPlaces.observe({ (change) in
                self.tableView.reloadData()
            })
        }
    }
    
    private func search(_ searchText: String) {
        if searchText.count != 0 {
            PTPlaceSearchHelper.shared.search(searchText) { (isSuccess, result) in
                self.showSearchResult(success: isSuccess, result: result)
            }
        }
    }
    
    private func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private func onSearching() -> Bool{
        let result = self.searchController.isActive && self.searchBarIsEmpty() == false
        
        return result
    }
    
    private func items() -> List<PTPlace> {
        return self.onSearching() ? self.searchResult : self.myPlaces
    }
    
    private func showSearchResult(success: Bool, result: [[String: Any]]?) {
        if let result = result, onSearching() == true {
            self.searchResult = PTPlace.createPlaces(placeInfos: result)
        }
        self.tableView.reloadData()
    }
}


extension PTMyPlacesTabViewController: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        self.hideSearchResult()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text, searchText.count > 0 {
            self.search(searchText)
        }
    }
    
    func hideSearchResult() {
        self.tableView.reloadData()
    }
}

extension PTMyPlacesTabViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var row = 0
        if self.onSearching() == true {
            row = self.searchResult.count
        } else {
            row = self.myPlaces.count
        }
        
        return row
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cells")
        if cell == nil {
            cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "cells")
        }
        
        let place = self.items()[indexPath.row]
        cell?.textLabel?.text = place.name
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !self.onSearching()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let place = self.items()[indexPath.row]
            if let currentUser = PTUserManager.currentUser() {
                currentUser.removePlace(type: .favorite, place: place, syncWithServer: false) {
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = self.items()[indexPath.row]
        
        if onSearching() == true {
            let popupView = PTPlacePopupView(frame: CGRect(x: 0, y: 0, width: PTPlacePopupView.defaultSize().width, height: PTPlacePopupView.defaultSize().height))
            popupView.placeType = .favorite
            popupView.place = place
            PTPopupViewManager.showPopupView(popupView, withAnimation: true)
            
            // get google info
            PTApiRequest.request().getGoogleInfo(place: place).observeCompletion { (response) in
                if response.isSuccess == true {
                    print(response)
                }
            }
        } else {
            let vc = PTPlaceInfoWebViewController(nibName: "PTPlaceInfoWebViewController", bundle: nil)
            vc.kakaoPlaceId = place.id
            
            let navc = UINavigationController.init(rootViewController: vc)
            self.present(navc, animated: true, completion: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
