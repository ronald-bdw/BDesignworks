//
//  NextButton.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 10/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

class RoundButton: UIButton {
    
    @IBInspectable var buttonColor = UIColor.blackColor() {
        didSet {
            self.backgroundColor = buttonColor
            self.layer.borderColor = buttonColor.CGColor
        }
    }
    @IBInspectable var textColor = UIColor.whiteColor() {
        didSet {
            self.setTitleColor(textColor, forState: .Normal)
        }
    }
    @IBInspectable var cornerRadius = CGFloat(0) {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    @IBInspectable var isFilled = true {
        didSet {
            self.layer.borderWidth = isFilled ? 2 : 0
        }
    }
}