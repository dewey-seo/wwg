//
//  PTPlacePopupView.swift
//  Path
//
//  Created by dewey on 2018. 6. 28..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit
import RealmSwift

class PTPlacePopupView: PTXibView {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
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

        self.scrollView.delegate = self;
        self.scrollView.isPagingEnabled = true;
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateAddButton() {
//        guard let place = self.place else {
//            return
//        }
//
//        self.addButton.removeTarget(self, action: nil, for: .allEvents)
//        if let currentUser = PTUserManager.currentUser() {
//            if currentUser.isMyPlace(place) {
//                self.addButton.setTitle("remove", for: .normal)
//                self.addButton.addTarget(self, action: #selector(deletePlaceButtonPressd(_:)), for: .touchUpInside)
//            } else {
//                self.addButton.setTitle("add", for: .normal)
//                self.addButton.addTarget(self, action: #selector(savePlaceButtonPressed(_:)), for: .touchUpInside)
//            }
//        }
    }
    
    @objc private func savePlaceButtonPressed(_ sender: UIButton) {
        print(#function)
        
        if let place = self.place {
            if let currentUser = PTUserManager.currentUser() {
                currentUser.addPlace(place, syncWithServer: false) {
                    self.updateAddButton()
                }
            }
        }
    }
    
    @objc private func deletePlaceButtonPressd(_ sender: UIButton) {
        print(#function)
        
        
        if let place = self.place {
            if let currentUser = PTUserManager.currentUser() {
                currentUser.removePlace(place, syncWithServer: false) {
                    self.updateAddButton()
                }
            }
        }
        
        self.updateAddButton()
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
