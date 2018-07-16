//
//  PTFeedTabViewController.swift
//  Path
//
//  Created by dewey on 2018. 7. 2..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit
import RealmSwift
import KakaoNavi


class PTFeedTabViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    var items: List<PTPlace>?
    var notificationToken: NotificationToken?
    
    let lineWidth: CGFloat = 2.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: "PTFeedCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: PTFeedCollectionViewCell.reuseIdentifier)
        self.collectionView.register(UINib(nibName: "PTFeedTabCollectionHeaderView", bundle:nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: PTFeedTabCollectionHeaderView.reuseIdentifier)
        
        self.collectionViewFlowLayout.minimumLineSpacing = lineWidth
        self.collectionViewFlowLayout.minimumInteritemSpacing = lineWidth

        let navRightButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
        self.navigationItem.rightBarButtonItem = navRightButton

        self.fetchItems()
    }
    
    func fetchItems() {
        if let currentUser = PTUserManager.currentUser() {
            // remove current notification
            self.notificationToken?.invalidate()
            self.notificationToken = nil

            // get new result
            self.items = currentUser.significantPlaces
            self.notificationToken = self.items?.observe({ (change) in
                self.collectionView.reloadData()
            })
        }
    }
}

extension PTFeedTabViewController {
//    @objc func getPlaceList() {
//        if let currentUser = PTUserManager.currentUser() {
//
//            PTApiRequest.request().getPlaceList(userId: currentUser.id).observeCompletion { (response) in
//                if response.isSuccess {
//                    if let jsonData = response.jsonResult {
//                        if let placeInfoList = jsonData["data"] as? [[String: Any]]{
//                            if let currentUser = PTUserManager.currentUser() {
//                                if let placeList = PTPlace.createPlaces(placeInfos: placeInfoList) {
//                                    try! PTDBManager.shared.realm.write {
//                                        currentUser.places.removeAll()
//                                    }
//
//                                    for place in placeList {
//                                        currentUser.addPlace(place, syncWithServer: false, {
//                                        })
//                                    }
//
//                                    self.fetchResult()
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
}
extension PTFeedTabViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionViewHeaderHeight() -> CGFloat {
        let height = self.collectionView.frameHeight() - (2 * lineWidth) - (self.collectionViewCellHeight() * 3)
        let maximumHeight = collectionView.frameWidth() * 3 / 4
        
        return min(maximumHeight, height)
    }
    
    func collectionViewCellHeight() -> CGFloat {
        let baseWidth = (self.collectionView.frameWidth() - (2 * lineWidth))
        let height = baseWidth / 3
        
        return height
    }
    
    func collectionViewCellWidth(index: Int) -> CGFloat {
        let baseWidth = (self.collectionView.frameWidth() - (2 * lineWidth))
        var width = baseWidth / 3
        
        if index % 3 == 0 {
            width = baseWidth - (2 * width)
        }
        
        return width
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frameWidth(), height: self.collectionViewHeaderHeight())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionViewCellWidth(index: indexPath.row), height: self.collectionViewCellHeight())
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PTFeedTabCollectionHeaderView.reuseIdentifier, for: indexPath)
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: PTFeedCollectionViewCell.reuseIdentifier, for: indexPath) as! PTFeedCollectionViewCell
        
        cell.type = self.indexPathToCellType(indexPath: indexPath)
        
        if case cell.type = PTFeedTabCollectionViewCellType.place {
            cell.place = items?[indexPath.row]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let type = self.indexPathToCellType(indexPath: indexPath)
        switch type {
        case .place:
            self.placeCellPressed(indexPath)
        case .add:
            self.addCellPressed(indexPath)
        case .empty:
            break
        }
    }
    
    func indexPathToCellType(indexPath: IndexPath) -> PTFeedTabCollectionViewCellType {
        let contentSize = self.items?.count ?? 0
        
        if contentSize > indexPath.row {
            return .place
        } else if indexPath.row == contentSize {
            return .add
        } else {
            return .empty
        }
    }
}

// MARK: - Edit Mode
extension PTFeedTabViewController {
    @objc func editButtonPressed() {
        
    }
    
    func placeCellPressed(_ indexPath: IndexPath) {
        if let cell = self.collectionView.cellForItem(at: indexPath) as? PTFeedCollectionViewCell, cell.type == .place, let place = cell.place {
            // 목적지 생성
            
            let destination = KNVLocation(name: place.name, x: NSNumber(floatLiteral: place.longitude), y: NSNumber(floatLiteral: place.latitude))
            
            let option = KNVOptions()
            option.coordType = .WGS84
            option.rpOption = .fast
            option.vehicleType = .first
            
            let params = KNVParams(destination: destination, options: option)
            KNVNaviLauncher.shared().navigate(with: params) { (error) in
                debugPrint("gogogo")
            }
        }
    }
    
    func addCellPressed(_ indexPath: IndexPath) {
        let placeSearchViewController = PTPlaceSearchViewController(nibName: "PTPlaceSearchViewController", bundle: nil)
        placeSearchViewController.placeType = .significant
        self.present(placeSearchViewController, animated: true, completion: nil)
    }
}







