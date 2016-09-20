//
//  NextButton.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 10/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

@IBDesignable
open class RoundButton: UIButton {
    
    @IBInspectable var buttonColor = UIColor.black {
        didSet {
            self.backgroundColor = buttonColor
            self.layer.borderColor = buttonColor.cgColor
        }
    }
    @IBInspectable var textColor = UIColor.white {
        didSet {
            self.setTitleColor(textColor, for: UIControlState())
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
