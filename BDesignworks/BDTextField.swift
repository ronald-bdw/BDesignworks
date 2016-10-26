//
//  BDTextField.swift
//  BDesignworks
//
//  Created by Galiev Aynur on 21.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

open class BDTextField: UITextField {
    
    @IBInspectable var insetX: CGFloat = 0
    @IBInspectable var insetY: CGFloat = 0
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "",
                                                        attributes: [NSForegroundColorAttributeName : UIColor.darkGray,
                                                                     NSFontAttributeName            : UIFont.systemFont(ofSize: 16.0)])
    }
    
    // placeholder position
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: self.insetX , dy: self.insetY)
    }
    
    // text position
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: self.insetX , dy: self.insetY)
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: self.insetX , dy: self.insetY)
    }
}
