//
//  PTRecommendTabViewController.swift
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

class PTRecommendTabViewController: UIViewController {

    @IBOutlet weak var googleMapView: GMSMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var bottomViewBottom: NSLayoutConstraint!
    
    let locationManager = CLLocationManager()
    
    var items = List<PTPlace>()
    var sortedItems = [PTPlace]()
    var notificationToken: NotificationToken?
    
    var marker: GMSMarker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.googleMapView.translatesAutoresizingMaskIntoConstraints = false
        self.googleMapView.isMyLocationEnabled = true
        self.googleMapView.delegate = self
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "PTRecommendTabPlaceCell", bundle: nil), forCellWithReuseIdentifier: PTRecommendTabPlaceCell.reuseIdentifier)
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
            
            guard let locValue: CLLocationCoordinate2D = self.locationManager.location?.coordinate else { return }
            self.showMap(latitude: locValue.latitude, longitude: locValue.longitude)
            self.fetchItems()
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
    
    private func fetchItems() {
        if let currentUser = PTUserManager.currentUser() {
            // remove current notification
            self.notificationToken?.invalidate()
            self.notificationToken = nil
            
            // get new result
            self.items = currentUser.favoritePlaces
            self.notificationToken = self.items.observe({ (change) in
                self.updatedDataSource(change)
            })
        }
    }

    private func updatedDataSource(_ change: RealmCollectionChange<List<PTPlace>>) {
        guard let currentLocation: CLLocation = self.locationManager.location else { return }
        
        self.sortedItems = items.sorted(by: { (placeA, placeB) -> Bool in
            placeA.distance = currentLocation.distance(from: CLLocation(latitude: placeA.latitude, longitude: placeA.longitude))
            placeB.distance = currentLocation.distance(from: CLLocation(latitude: placeB.latitude, longitude: placeB.longitude))
            
            return placeA.distance! < placeB.distance!
        })
        
        self.collectionView.reloadData()
    }
    
    private func showMap(latitude: Double, longitude: Double, scale: Float = 15) {
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: scale)
        self.googleMapView.camera = camera
        self.view.layoutIfNeeded()
    }
}

extension PTRecommendTabViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        debugPrint("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.askAuthorization()
    }
}

extension PTRecommendTabViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frameWidth() * 0.65, height: self.collectionView.frameHeight())
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.sortedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PTRecommendTabPlaceCell.reuseIdentifier, for: indexPath) as! PTRecommendTabPlaceCell
        
        let place = self.sortedItems[indexPath.row]
        cell.place = place
        cell.contentView.backgroundColor = .red
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let place = self.sortedItems[indexPath.row]
        
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



extension PTRecommendTabViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
    }
}
