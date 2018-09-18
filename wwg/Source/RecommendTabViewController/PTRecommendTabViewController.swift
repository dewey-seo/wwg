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

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var baseViewTop: NSLayoutConstraint!
    @IBOutlet weak var baseViewBottom: NSLayoutConstraint!
    
    // map
    @IBOutlet weak var googleMapView: GMSMapView!
    
    // bottom
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    let locationManager = CLLocationManager()
    
    var currentIndex = 0
    var targetIndex = 0
    
    var items = List<PTPlace>()
    var sortedItems = [PTPlace]()
    var notificationToken: NotificationToken?
    
    var marker: GMSMarker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initGoogleMapView()
        self.initCollectionView()
        
        self.baseViewBottom.constant = self.tabBarController?.tabBar.frameHeight() ?? 0
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
    
    private func initGoogleMapView() {
        self.googleMapView.translatesAutoresizingMaskIntoConstraints = false
        self.googleMapView.isMyLocationEnabled = true
        self.googleMapView.delegate = self
    }
    
    private func initCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "PTRecommendTabPlaceCell", bundle: nil), forCellWithReuseIdentifier: PTRecommendTabPlaceCell.reuseIdentifier)
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
    func cellSize() -> CGSize {
        return CGSize(width: ceil(self.collectionView.frameWidth() - 30*2), height: self.collectionView.frameHeight() - 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.cellSize()
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
            let mapScaleHeight = Double(self.googleMapView.frame.size.height - self.bottomViewHeight.constant) / fabs(targetLoc.y - myLoc.y);
            let mapScale = min(mapScaleWidth, mapScaleHeight);
            
            let zoomLevel = (20 + log2(mapScale)) * 0.97;
            
            let camera = GMSCameraPosition.camera(withLatitude: centerLocation.latitude,
                                                  longitude: centerLocation.longitude,
                                                  zoom: Float(zoomLevel))
            self.googleMapView.animate(to: camera)
        }
    }
}

extension PTRecommendTabViewController: UIScrollViewDelegate {
    func pointToIndex(scrollView: UIScrollView, point: CGPoint) -> Int {
        let centerPoint = CGPoint(x: point.x + scrollView.frameWidth()*0.5, y: point.y)
        let index = self.collectionView.indexPathForItem(at: centerPoint)?.item ?? currentIndex
        
        return index
    }
    
    func indexToPoint(scrollView: UIScrollView, index: Int) -> CGPoint {
        let index = min(max(0, index), (self.collectionView.numberOfItems(inSection: 0) - 1))
        
        if index == 0 {
            return CGPoint(x: 0, y: 0)
        } else if index == (self.collectionView.numberOfItems(inSection: 0) - 1) {
            return CGPoint(x: scrollView.contentSize.width - scrollView.frameWidth(), y: 0)
        } else {
            return CGPoint(x: CGFloat(index) * (self.cellSize().width + 10.0) - 20, y: 0)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        currentIndex = self.pointToIndex(scrollView: scrollView, point: scrollView.contentOffset)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print(#function)
        targetIndex = currentIndex
        
        if scrollView.contentOffset.x < targetContentOffset.pointee.x {
            if self.pointToIndex(scrollView: scrollView, point:targetContentOffset.pointee) != currentIndex {
                targetIndex = currentIndex + 1
            }
        } else if scrollView.contentOffset.x > targetContentOffset.pointee.x {
            if self.pointToIndex(scrollView: scrollView, point:targetContentOffset.pointee) != currentIndex {
                targetIndex = currentIndex - 1
            }
        }
        
        targetContentOffset.pointee.x = self.indexToPoint(scrollView: scrollView, index: targetIndex).x
    }
}

extension PTRecommendTabViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
    }
}


