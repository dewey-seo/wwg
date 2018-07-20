//
//  PTMainTabCollectionViewCell.swift
//  wwg
//
//  Created by dewey on 2018. 7. 12..
//  Copyright © 2018년 dewey. All rights reserved.
//

import UIKit

protocol PTMainTabCollectionViewCellDelegate: class {
    func delete(cell: PTMainTabCollectionViewCell)
    func edit(cell: PTMainTabCollectionViewCell)
}

enum PTMainTabCollectionViewCellType: Int {
    case empty
    case add
    case place
}

class PTMainTabCollectionViewCell: UICollectionViewCell {
    static var reuseIdentifier: String {
       return NSStringFromClass(self)
    }
    
    // Place
    @IBOutlet weak var placeView: UIView!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var placeDeleteImageView: UIImageView!
    @IBOutlet weak var editView: UIView!
    
    // Add
    @IBOutlet weak var addView: UIView!
    
    // Empty
    @IBOutlet weak var emptyView: UIView!
    
    weak var delegate: PTMainTabCollectionViewCellDelegate?
    
    var _place: PTPlace?
    var place: PTPlace? {
        get { return _place }
        set(newPlace) {
             _place = newPlace
            self.refreshPlaceView()
        }
    }
    
    var _isEditMode: Bool = false
    var isEditMode: Bool {
        get {return _isEditMode}
        set(newMode) {
            _isEditMode = newMode
            self.editView.isHidden = !_isEditMode
        }
    }
    
    var _type: PTMainTabCollectionViewCellType = .empty
    var type: PTMainTabCollectionViewCellType {
        get {
            return _type
        }
        set(newType) {
            _type = newType
            
            switch newType {
            case .empty:
                self.placeView.isHidden = true
                self.addView.isHidden = true
                self.emptyView.isHidden = false
            case .add:
                self.placeView.isHidden = true
                self.addView.isHidden = false
                self.emptyView.isHidden = true
            case .place:
                self.placeView.isHidden = false
                self.addView.isHidden = true
                self.emptyView.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func refreshPlaceView() {
        if let place = self.place {
            self.placeLabel.text = place.name
        }
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.edit(cell: self)
        }
    }
    @IBAction func deleteButtonPressed(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.delete(cell: self)
        }
    }
}
