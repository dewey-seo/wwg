//
//  PTMainTabViewController.swift
//  Path
//
//  Created by dewey on 2018. 7. 2..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit
import RealmSwift
import KakaoNavi


class PTMainTabViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    var navRightButton: UIBarButtonItem?
    
    var items: List<PTPlace>?
    var notificationToken: NotificationToken?
    
    var _isEditMode: Bool = false
    var isEditMode: Bool {
        get { return _isEditMode }
        set(newMode) {
            self.changeEditMode(newMode)
        }
    }
    
    var longPressGesture: UILongPressGestureRecognizer?
    
    let lineWidth: CGFloat = 2.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: "PTMainTabCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: PTMainTabCollectionViewCell.reuseIdentifier)
        self.collectionView.register(UINib(nibName: "PTMainTabCollectionHeaderView", bundle:nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: PTMainTabCollectionHeaderView.reuseIdentifier)
        
        self.collectionViewFlowLayout.minimumLineSpacing = lineWidth
        self.collectionViewFlowLayout.minimumInteritemSpacing = lineWidth

        self.fetchItems()
        self.setNavigationBarButton(isEditMode: self.isEditMode)
    }
    
    private func setNavigationBarButton(isEditMode: Bool) {
        if isEditMode == true {
            self.navRightButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editButtonPressed))
        } else {
            self.navRightButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
        }
        self.navigationItem.rightBarButtonItem = navRightButton
    }
    
    private func fetchItems() {
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

extension PTMainTabViewController {
    // get from server
}

extension PTMainTabViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
            if let reusableHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PTMainTabCollectionHeaderView.reuseIdentifier, for: indexPath) as? PTMainTabCollectionHeaderView {
                reusableHeaderView.bannerView.rootViewController = self
                return reusableHeaderView
            }
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: PTMainTabCollectionViewCell.reuseIdentifier, for: indexPath) as! PTMainTabCollectionViewCell
        
        cell.type = self.indexPathToCellType(indexPath: indexPath)
        
        if case cell.type = PTMainTabCollectionViewCellType.place {
            cell.place = items?[indexPath.row]
            cell.isEditMode = self.isEditMode
            cell.delegate = self
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isEditMode == true {
            return
        } else {
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
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if self.indexPathToCellType(indexPath: indexPath) == .place {
            return true
        } else {
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let currentUser = PTUserManager.currentUser() {
            let startIndexRow = sourceIndexPath.row
            let endIndexRow = destinationIndexPath.row
            
            let targetPlace = currentUser.significantPlaces[startIndexRow]
            
            PTDBManager.write {
                currentUser.significantPlaces.remove(at: startIndexRow)
                currentUser.significantPlaces.insert(targetPlace, at: endIndexRow)
            }
        }
    }
    
    func indexPathToCellType(indexPath: IndexPath) -> PTMainTabCollectionViewCellType {
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
extension PTMainTabViewController {
    func placeCellPressed(_ indexPath: IndexPath) {
        if let cell = self.collectionView.cellForItem(at: indexPath) as? PTMainTabCollectionViewCell, cell.type == .place, let place = cell.place {
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


extension PTMainTabViewController {
    @objc func editButtonPressed() {
        self.isEditMode = !self.isEditMode
    }
    
    private func changeEditMode(_ newMode: Bool) {
        _isEditMode = newMode
        self.setNavigationBarButton(isEditMode: self.isEditMode)
        
        if self.isEditMode == true {
            self.longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleCollectionViewLongPressed(gesture:)))
            self.collectionView.addGestureRecognizer(self.longPressGesture!)
        } else {
            if let gesture = self.longPressGesture {
                self.collectionView.removeGestureRecognizer(gesture)
            }
        }
        
        self.collectionView.reloadData()
    }
    
    @objc private func handleCollectionViewLongPressed(gesture: UILongPressGestureRecognizer) {
        let state = gesture.state
        guard let selectedCellIndex = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {return}
        
        if self.collectionView(self.collectionView, canMoveItemAt: selectedCellIndex) == false {
            return
        }
        
        switch state {
        case .began:
            self.collectionView.beginInteractiveMovementForItem(at: selectedCellIndex)
        case .changed:
            guard let moveTargetIndex = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {return}
            if self.indexPathToCellType(indexPath: moveTargetIndex) == .place {
                self.collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: self.collectionView))
            }
        case .ended:
            self.collectionView.endInteractiveMovement()
        default:
            self.collectionView.cancelInteractiveMovement()
        }
        
    }
}

extension PTMainTabViewController: PTMainTabCollectionViewCellDelegate {
    func edit(cell: PTMainTabCollectionViewCell) {
        if let editIndex = self.collectionView.indexPath(for: cell)?.row, let items = self.items {
            let place = items[editIndex]
            
            let alert = UIAlertController(title: place.name, message: "", preferredStyle: .alert)
            alert.addTextField { (textField) in
            }
            
            let editButton = UIAlertAction(title: "Edit", style: .default) { (ok) in
                PTDBManager.write {
                    if let text = alert.textFields?[0].text {
                        if text.count > 0 {
                            place.name = text
                        }
                    }
                }
            }
            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(cancelButton)
            alert.addAction(editButton)
            
            self.present(alert, animated: true, completion: nil)
        }

    }
    
    func delete(cell: PTMainTabCollectionViewCell) {
        if let deleteIndex = self.collectionView.indexPath(for: cell)?.row, let currentUser = PTUserManager.currentUser() {
            PTDBManager.write {
                currentUser.significantPlaces.remove(at: deleteIndex)
            }
        }
    }
}



