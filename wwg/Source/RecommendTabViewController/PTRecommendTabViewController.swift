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
import JTChartView

class PTRecommendTabViewController: UIViewController {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var baseViewTop: NSLayoutConstraint!
    @IBOutlet weak var baseViewBottom: NSLayoutConstraint!
    
    // top
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var chartBaseView: UIView!
    @IBOutlet weak var distanceRangeSlider: PTRangeSlider!
    @IBOutlet weak var topviewHeight: NSLayoutConstraint!
    
    // map
    @IBOutlet weak var googleMapView: GMSMapView!
    
    // bottom
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    
    var chartView: JTChartView?
    
    let locationManager = CLLocationManager()
    
    var items = List<PTPlace>()
    var sortedItems = [PTPlace]()
    var groupItems = [[PTPlace]]()
    var notificationToken: NotificationToken?
    
    var marker: GMSMarker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initChartView()
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
        
        self.showTopViewIfNeeded()
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

// MARK: - Chart
extension PTRecommendTabViewController {
    private func initChartView() {
        self.baseViewTop.constant = -self.topviewHeight.constant
    }
    
    private func showTopViewIfNeeded() {
        if self.sortedItems.count > 10 {
            if self.sortedItems.count > 0 {
                if #available(iOS 11, *) {
                    self.baseViewTop.constant = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
                } else {
                    self.baseViewTop.constant = 0
                }
            }
            
            self.makePlaceGroupBasedDistance()
            
            let (values, minY, maxY) = self.makeCharValuesUsingGroupItems()
            self.chartView = JTChartView(frame: self.chartBaseView.bounds, values: values, curve: .gray, curveWidth: 2, topGradientColor: .gray, bottomGradientColor: .gray, minY: CGFloat(minY), maxY: CGFloat(maxY), topPadding: 10)
            if let chartView = self.chartView {
                self.chartBaseView.addSubview(chartView)
                chartView.translatesAutoresizingMaskIntoConstraints = false
                chartView.leadingAnchor.constraint(equalTo: self.chartBaseView.leadingAnchor).isActive = true
                chartView.topAnchor.constraint(equalTo: self.chartBaseView.topAnchor).isActive = true
                chartView.bottomAnchor.constraint(equalTo: self.distanceRangeSlider.topAnchor).isActive = true
                chartView.trailingAnchor.constraint(equalTo: self.chartBaseView.trailingAnchor).isActive = true
            }
        }
    }
    
    private func makePlaceGroupBasedDistance() {
        let divKm = 5
        guard let maxDistance = self.sortedItems.last?.distance else {return}
        guard let minDistance = self.sortedItems.first?.distance else {return}
        
        self.groupItems.removeAll()
        
        for place in self.sortedItems {
            if let distance = place.distance {
                let km = (Int)((distance - minDistance) * 0.001)
                let groupIndex: Int = km % divKm
                
                if self.groupItems.indices.contains(groupIndex) {
                    self.groupItems[groupIndex].append(place)
                } else {
                    self.groupItems.append([place])
                }
            }
        }
    }
    
    private func makeCharValuesUsingGroupItems() -> ([Any], Int, Int) {
        
        var values = [Any]()
        var maxCount = 0
        var minCount = self.groupItems[0].count
        
        for places:[PTPlace] in self.groupItems {
            values.append(places.count)
            maxCount = max(maxCount, places.count)
            minCount = min(minCount, places.count)
        }
        
        return (values, minCount, maxCount)
    }
}
