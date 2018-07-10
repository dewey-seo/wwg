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
    var _place: PTPlace?
    @IBOutlet weak var addButton: UIButton!
    
    public var place: PTPlace? {
        get {
            return _place
        }
        set(newPlace) {
            _place = newPlace
            
            self.updateAddButton()
        }
    }
    
    private func updateAddButton() {
        guard let place = self.place else {
            return
        }
        
        self.addButton.removeTarget(self, action: nil, for: .allEvents)
        if let currentUser = PTUserManager.currentUser() {
            if currentUser.isMyPlace(place) {
                self.addButton.setTitle("remove", for: .normal)
                self.addButton.addTarget(self, action: #selector(deletePlaceButtonPressd(_:)), for: .touchUpInside)
            } else {
                self.addButton.setTitle("add", for: .normal)
                self.addButton.addTarget(self, action: #selector(savePlaceButtonPressed(_:)), for: .touchUpInside)
            }
        }
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
