//
//  PTPlacePopupView.swift
//  Path
//
//  Created by dewey on 2018. 6. 28..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMaps

class PTPlacePopupView: PTXibView {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var placeType: PTPlaceType = .unknown
    var _place: PTPlace?
    public var place: PTPlace? {
        get {
            return _place
        }
        set(newPlace) {
            _place = newPlace
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.mapView.isUserInteractionEnabled = false
        
        self.scrollView.delegate = self;
        self.scrollView.isPagingEnabled = true;
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @IBAction func addPlaceButtonPressed(_ sender: Any) {
        debugPrint(#function)
        
        if let place = self.place {
            if let currentUser = PTUserManager.currentUser() {
                currentUser.addPlace(type: self.placeType, place: place, syncWithServer: false) {
                    PTPopupViewManager.hidePopupView(animated: true)
                }
            }
        }
    }
}


extension PTPlacePopupView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.isEqual(self.scrollView) {
            self.tableView.isScrollEnabled = false
        } else if scrollView.isEqual(self.tableView) {
            self.scrollView.isScrollEnabled = false
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.tableView.isScrollEnabled = true
        self.scrollView.isScrollEnabled = true
        
        if scrollView.isEqual(self.scrollView) {
            // control page
        } else if scrollView.isEqual(self.tableView) {
            
        }
    }
}

extension PTPlacePopupView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return  UITableViewCell.init(style: .subtitle, reuseIdentifier: "cells")
    }
}
