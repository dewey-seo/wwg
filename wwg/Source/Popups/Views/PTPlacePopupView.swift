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

class PTPlacePopupView: PTPopupView {
    class func defaultSize() -> CGSize {
        let screenSize = UIScreen.main.bounds.size
        let width = screenSize.width * 0.8
        let height = width * 1.5
        
        return CGSize(width: width, height: height)
    }
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    var placeType: PTPlaceType = .unknown
    var _place: PTPlace?
    public var place: PTPlace? {
        get {
            return _place
        }
        set(newPlace) {
            _place = newPlace
            self.applyPlace(newPlace)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.view.layer.cornerRadius = 5
        self.view.clipsToBounds = true
        
        self.mapView.isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyPlace(_ place: PTPlace?) {
        guard let place = place else {
            return
        }
        
        // Map
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        marker.appearAnimation = .none
        marker.map = self.mapView
        
        mapView.selectedMarker = marker
        mapView.camera = GMSCameraPosition.camera(withLatitude: place.latitude, longitude: place.longitude, zoom: 17.0)
        mapView.setMinZoom(15, maxZoom: 15)
        
        // Labels
        self.nameLabel.text = place.name
        self.addressLabel.text = place.address
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
    @IBAction func SecondButtonPressed(_ sender: Any) {
        if let place = self.place {
            let vc = PTPlaceInfoWebViewController(nibName: "PTPlaceInfoWebViewController", bundle: nil)
            vc.kakaoPlaceId = place.id
            let navc = UINavigationController.init(rootViewController: vc)
            
            self.delegate?.popupViewPresentViewController!(navc, completion: nil)
        }
    }
}


extension PTPlacePopupView: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//    }
//
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        if scrollView.isEqual(self.scrollView) {
//            self.tableView.isScrollEnabled = false
//        } else if scrollView.isEqual(self.tableView) {
//            self.scrollView.isScrollEnabled = false
//        }
//    }
//
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        self.tableView.isScrollEnabled = true
//        self.scrollView.isScrollEnabled = true
//
//        if scrollView.isEqual(self.scrollView) {
//            // control page
//        } else if scrollView.isEqual(self.tableView) {
//
//        }
//    }
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
