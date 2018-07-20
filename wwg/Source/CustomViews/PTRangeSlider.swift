//
//  PTRangeSlider.swift
//  wwg
//
//  Created by dewey on 2018. 7. 20..
//  Copyright © 2018년 dewey. All rights reserved.
//

import UIKit

class PTRangeSlider: UIControl {
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var trackView: UIView!
    @IBOutlet weak var lowerThumb: UIButton!
    @IBOutlet weak var upperThumb: UIButton!
    @IBOutlet weak var selectedRange: UIButton!
    @IBOutlet weak var selectedRangeView: UIView!
    @IBOutlet weak var selectedRangeTrackView: UIView!
    
    @IBOutlet weak var trackViewLeading: NSLayoutConstraint!
    @IBOutlet weak var trackViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var lowerThumbLeading: NSLayoutConstraint!
    @IBOutlet weak var upperThumbLeading: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createViewFromXib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.createViewFromXib()
    }
    
    private func nibName() -> String {
        let thisType = type(of: self)
        return String(describing: thisType)
    }
    
    private func createViewFromXib() {
        if let view = Bundle.main.loadNibNamed(self.nibName(), owner: self, options: nil)?.first as? UIView {
            self.view = view
        } else {
            print("view is not created using xib")
            self.view = UIView()
        }
        
        self.addSubview(self.view)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    private var previouslocation = CGPoint()
    
    @IBInspectable var minimumValue: Double = 0.0 {
        willSet(newValue){}
        didSet {
        }
    }
    @IBInspectable var maximumValue: Double = 1.0 {
        willSet(newValue){}
        didSet {
        }
    }
    @IBInspectable var lowerValue: Double = 0.0{
        willSet(newValue){}
        didSet(newValue) {
        }
    }
    @IBInspectable var upperValue: Double = 1.0{
        willSet(newValue){}
        didSet {
        }
    }
    @IBInspectable var trackTintColor: UIColor = .gray {
        didSet {
            
        }
    }
    @IBInspectable var trackthickness: CGFloat = 10.0 {
        didSet {
            
        }
    }
    
    @IBInspectable var trackHighlightTintColor: UIColor = .darkGray {
        didSet {
            
        }
    }
    @IBInspectable var selectedRangeTrackColor: UIColor = .orange {
        didSet {
            
        }
    }
    @IBInspectable var thumbTintColor: UIColor = .white{
        didSet {
            
        }
    }
    @IBInspectable var thumbBorderColor: UIColor = .black {
        didSet {
            
        }
    }
    @IBInspectable var thumbBorderWidth: CGFloat = 0.5{
        didSet {
            
        }
    }
    @IBInspectable var lowerThumbSize: CGSize = CGSize(width: 30.0, height: 30.0) {
        didSet {
            
        }
    }
    @IBInspectable var upperThumbSize: CGSize = CGSize(width: 30.0, height: 30.0) {
        didSet {
            
        }
    }
    @IBInspectable var lowerThumbImage: UIImage? {
        didSet {
            
        }
    }
    @IBInspectable var upperThumbImage: UIImage? {
        didSet {
            
        }
    }
    
    private func reArrangeViewsFromValues() {
        
    }
}

extension PTRangeSlider {
    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        self.previouslocation = touch.location(in: self.trackView)

        if lowerThumb.frame.contains(previouslocation) {
            lowerThumb.isHighlighted = true
        } else if upperThumb.frame.contains(previouslocation) {
            upperThumb.isHighlighted = true
        } else if selectedRangeView.frame.contains(previouslocation) {
            selectedRange.isHighlighted = true
        }

        return lowerThumb.isHighlighted || upperThumb.isHighlighted || selectedRange.isHighlighted
    }

    override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self.trackView)

        // Determine by how much the user has dragged
        let delta = location.x - previouslocation.x

        previouslocation = location
        
        // Update the values
        if lowerThumb.isHighlighted {
            self.lowerThumbChange(delta)
        } else if upperThumb.isHighlighted {
            self.upperThumbWillChange(delta)
        } else if selectedRange.isHighlighted {
            self.selectedRangeMoved(delta)
        }

        sendActions(for: .valueChanged)

        return true
    }

    override public func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        lowerThumb.isHighlighted = false
        upperThumb.isHighlighted = false
        selectedRange.isHighlighted = false
    }
}

extension PTRangeSlider {
    private func lowerThumbChange(_ delta: CGFloat) {
        let canMoveToLeft = -(self.lowerThumbLeading.constant)
        let canMoveToRight = self.upperThumbLeading.constant - (self.lowerThumbLeading.constant + self.lowerThumbSize.width)
        
        let willMoveValue = min(max(canMoveToLeft, delta), canMoveToRight)
        
        self.lowerThumbLeading.constant = self.lowerThumbLeading.constant + willMoveValue

        self.sliderChanged()
    }
    
    private func upperThumbWillChange(_ delta: CGFloat) {
        let canMoveToLeft = -(self.upperThumbLeading.constant - (self.lowerThumbLeading.constant + self.lowerThumbSize.width))
        let canMoveToRight = self.frameWidth() - (self.upperThumbLeading.constant + self.upperThumbSize.width)
        
        let willMoveValue = min(max(canMoveToLeft, delta), canMoveToRight)

        self.upperThumbLeading.constant = self.upperThumbLeading.constant + willMoveValue
        
        self.sliderChanged()
    }
    
    private func selectedRangeMoved(_ delta: CGFloat) {
        let canMoveToLeft = -self.lowerThumbLeading.constant
        let canMoveToRight = self.frameWidth() - self.upperThumbLeading.constant - self.upperThumbSize.width
        
        let willMoveValue = min(max(canMoveToLeft, delta), canMoveToRight)
        
        self.lowerThumbLeading.constant = self.lowerThumbLeading.constant + willMoveValue
        self.upperThumbLeading.constant = self.upperThumbLeading.constant + willMoveValue
        
        self.sliderChanged()
    }
    
    private func sliderChanged() {
        
    }
}
