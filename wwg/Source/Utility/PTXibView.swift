//
//  PTXibView.swift
//  Path
//
//  Created by dewey on 2018. 6. 28..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit

@IBDesignable
class PTXibView: UIView {
    @IBOutlet weak var view: UIView!
    
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
}
