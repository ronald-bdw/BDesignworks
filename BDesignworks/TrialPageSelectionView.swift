//
//  TrialPageSelectionView.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 06.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

@IBDesignable
class TrialPageSelectionView: UIView {
    private let selectedColor = UIColor.whiteColor()
    private let deselectedColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
    
    @IBInspectable var selected: Bool = false {
        willSet(newValue) {
            self.backgroundColor = newValue ? self.selectedColor : self.deselectedColor
        }
    }
}