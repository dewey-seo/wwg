//
//  PTFeedCollectionViewCell.swift
//  wwg
//
//  Created by dewey on 2018. 7. 12..
//  Copyright © 2018년 dewey. All rights reserved.
//

import UIKit

enum PTFeedTabCollectionViewCellType: Int {
    case empty
    case add
    case place
}

class PTFeedCollectionViewCell: UICollectionViewCell {
    static var reuseIdentifier: String {
       return NSStringFromClass(self)
    }
    
    // Place
    @IBOutlet weak var placeView: UIView!
    @IBOutlet weak var placeLabel: UILabel!
    
    // Add
    @IBOutlet weak var addView: UIView!
    
    // Empty
    @IBOutlet weak var emptyView: UIView!
    
    var _place: PTPlace?
    var place: PTPlace? {
        get { return _place }
        set(newPlace) {
             _place = newPlace
            self.refreshPlaceView()
        }
    }
    
    var _type: PTFeedTabCollectionViewCellType = .empty
    var type: PTFeedTabCollectionViewCellType {
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
    
    func refreshPlaceView() {
        if let place = self.place {
            self.placeLabel.text = place.name
        }
    }
}
