//
//  PTRecommendViewController.swift
//  Path
//
//  Created by dewey on 2018. 7. 3..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import RealmSwift
import MapKit

class PTRecommendViewController: UIViewController {

    @IBOutlet weak var googleMapView: GMSMapView!
    @IBOutlet weak var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    
    var results: Results<PTPlace>?
    var notificationToken: NotificationToken?
    
    var recommendPlaces = [PTPlace]()
    var marker: GMSMarker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.googleMapView.translatesAutoresizingMaskIntoConstraints = false
        self.googleMapView.isMyLocationEnabled = true
        self.googleMapView.delegate = self
        
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.askAuthorization()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func askAuthorization() {
        self.locationManager.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
            self.showMap()
            self.showLocationList()
        } else {
            let status = CLLocationManager.authorizationStatus()
            switch status {
            case .authorizedAlways:
                break
            case .authorizedWhenInUse:
                break
            default:
                self.locationManager.requestWhenInUseAuthorization()
            }
        }
    }
    
    private func showMap() {
        guard let locValue: CLLocationCoordinate2D = self.locationManager.location?.coordinate else { return }
        let camera = GMSCameraPosition.camera(withLatitude: locValue.latitude,
                                              longitude: locValue.longitude,
                                              zoom: 15)
        
        self.googleMapView.camera = camera
        self.view.layoutIfNeeded()
    }
    
    private func showLocationList() {
        guard let currentUser = PTUserManager.currentUser() else { return }
        self.results = PTDBManager.shared.realm.objects(PTPlace.self).filter("ANY users == %@", currentUser)
        
        self.notificationToken = self.results?.observe({ (change) in
            self.updatedDataSource(change)
        })
    }
    
    private func updatedDataSource(_ change: RealmCollectionChange<Results<PTPlace>>) {
        guard let currentLocation: CLLocation = self.locationManager.location else { return }
        
        if let results = self.results {
            self.recommendPlaces = results.sorted(by: { (placeA, placeB) -> Bool in
                placeA.distance = currentLocation.distance(from: CLLocation(latitude: placeA.latitude, longitude: placeA.longitude))
                placeB.distance = currentLocation.distance(from: CLLocation(latitude: placeB.latitude, longitude: placeB.longitude))
                
                return placeA.distance! < placeB.distance!
            })
            
            self.tableView.reloadData()
        }
    }
}

extension PTRecommendViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recommendPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cells")
        if cell == nil {
            cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "cells")
        }
        
        let place = self.recommendPlaces[indexPath.row]
        cell?.textLabel?.text = place.name
        if let distance = place.distance {
            cell?.detailTextLabel?.text = "\(distance / 1000) Km"
        }

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = self.recommendPlaces[indexPath.row]
        
        // remove
        self.marker?.map = nil
        
        // add
        self.marker = GMSMarker()
        self.marker?.position = CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude)
        self.marker?.appearAnimation = .pop
        self.marker?.title = place.name
        self.marker?.map = self.googleMapView
        
        self.googleMapView.selectedMarker = nil
        self.googleMapView.selectedMarker = self.marker
        
        self.googleMapView.animate(toLocation: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude))
        
        // change scale
        if let myLocCoordinate = self.googleMapView.myLocation?.coordinate {
            let myLoc = MKMapPointForCoordinate(myLocCoordinate)
            let targetLoc = MKMapPointForCoordinate(place.coordinate);
            
            let centerPoint = MKMapPointMake((myLoc.x + targetLoc.x) / 2, (myLoc.y + targetLoc.y) / 2);
            let centerLocation = MKCoordinateForMapPoint(centerPoint);
            
            let mapScaleWidth = Double(self.googleMapView.frame.size.width) / fabs(targetLoc.x - myLoc.x);
            let mapScaleHeight = Double(self.googleMapView.frame.size.height) / fabs(targetLoc.y - myLoc.y);
            let mapScale = min(mapScaleWidth, mapScaleHeight);
            
            let zoomLevel = (20 + log2(mapScale)) * 0.97;
            
            let camera = GMSCameraPosition.camera(withLatitude: centerLocation.latitude,
                                                  longitude: centerLocation.longitude,
                                                  zoom: Float(zoomLevel))
            self.googleMapView.animate(to: camera)
        }
    }
}

extension PTRecommendViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.askAuthorization()
    }
}

extension PTRecommendViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
    }
}
