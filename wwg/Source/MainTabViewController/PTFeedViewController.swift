//
//  PTFeedViewController.swift
//  Path
//
//  Created by dewey on 2018. 7. 2..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit
import RealmSwift

class PTFeedViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var results: Results<PTPlace>?
    var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        let navRightButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(getPlaceList))
        self.navigationItem.rightBarButtonItem = navRightButton
        
        self.fetchResult()
    }
    
    func fetchResult() {
        if let currentUser = PTUserManager.currentUser() {
            self.notificationToken?.invalidate()
            self.results = PTDBManager.shared.realm.objects(PTPlace.self).filter("ANY users == %@", currentUser)
            self.notificationToken = self.results?.observe({ (change) in
                self.updatedDataSource(change)
            })
            
            self.tableView.reloadData()
        }
    }
    
    deinit {
        print("\(self) deinit")
        self.notificationToken = nil
    }
}

extension PTFeedViewController {
    @objc func getPlaceList() {
        if let currentUser = PTUserManager.currentUser() {
            
            PTApiRequest.request().getPlaceList(userId: currentUser.id).observeCompletion { (response) in
                if response.isSuccess {
                    if let jsonData = response.jsonResult {
                        if let placeInfoList = jsonData["data"] as? [[String: Any]]{
                            if let currentUser = PTUserManager.currentUser() {
                                if let placeList = PTPlace.createPlaces(placeInfos: placeInfoList) {
                                    try! PTDBManager.shared.realm.write {
                                        currentUser.places.removeAll()
                                    }
                                    
                                    for place in placeList {
                                        currentUser.addPlace(place, syncWithServer: false, {
                                        })
                                    }
                                    
                                    self.fetchResult()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
extension PTFeedViewController: UITableViewDelegate, UITableViewDataSource {
    func updatedDataSource(_ change: RealmCollectionChange<Results<PTPlace>>) {
        print(change)
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cells")
        if cell == nil {
            cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "cells")
        }
        
        if let place = self.results?[indexPath.row] {
            cell?.textLabel?.text = place.name
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
