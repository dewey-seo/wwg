//
//  PTMainTabCollectionHeaderView.swift
//  wwg
//
//  Created by dewey on 2018. 7. 13..
//  Copyright © 2018년 dewey. All rights reserved.
//

import UIKit
import GoogleMobileAds
import MapKit

class PTMainTabCollectionHeaderView: UICollectionReusableView {
    static var reuseIdentifier: String {
        return NSStringFromClass(self)
    }
    
    var bannerView: GADBannerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let adSize = GADAdSizeFromCGSize(self.frameSize())
        self.bannerView = GADBannerView(adSize: adSize)

//        self.bannerView.adUnitID = "ca-app-pub-3918803652819009/7146182843"
        self.bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" // For Test
        
        /*
         * Set ad targetting
         */
        let request = GADRequest()
        let extras = GADExtras()
        
        extras.additionalParameters = ["max_ad_content_rating": "T"]
        request.register(extras)
        
        if let currentLocation = CLLocationManager().location {
            request.setLocationWithLatitude(CGFloat(currentLocation.coordinate.latitude),
                                            longitude: CGFloat(currentLocation.coordinate.longitude),
                                            accuracy: CGFloat(currentLocation.horizontalAccuracy))
        }
        
        bannerView.load(request)
        bannerView.delegate = self
        
        /*
         * Add
         */
        self.addSubview(self.bannerView)
        self.bannerView.translatesAutoresizingMaskIntoConstraints = false
        self.bannerView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.bannerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.bannerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.bannerView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
}

extension PTMainTabCollectionHeaderView: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("adViewWillPresentScreen")
    }
    
    /// Tells the delegate that the full-screen view will be dismissed.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillDismissScreen")
    }
    
    /// Tells the delegate that the full-screen view has been dismissed.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    
    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
}
