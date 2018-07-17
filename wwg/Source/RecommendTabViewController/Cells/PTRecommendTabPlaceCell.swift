//
//  PTRecommendTabPlaceCell.swift
//  wwg
//
//  Created by dewey on 2018. 7. 17..
//  Copyright © 2018년 dewey. All rights reserved.
//

import UIKit

class PTRecommendTabPlaceCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var _place: PTPlace?
    var place: PTPlace? {
        get { return _place }
        set(newPlace) {
            _place = newPlace
            self.applyNewPlace()
        }
    }
    
    static var reuseIdentifier: String {
        return NSStringFromClass(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func applyNewPlace() {
        if let place = self.place {
            self.nameLabel.text = place.name
            self.addressLabel.text = place.address
            self.distanceLabel.text = "\(place.distance ?? 0.0)"
        }
    }
}
