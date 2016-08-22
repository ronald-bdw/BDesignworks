//
//  BDTextField.swift
//  BDesignworks
//
//  Created by Galiev Aynur on 21.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

@IBDesignable
class BDTextField: UITextField {
    
    @IBInspectable var insetX: CGFloat = 0
    @IBInspectable var insetY: CGFloat = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "",
                                                        attributes: [NSForegroundColorAttributeName : UIColor.darkGrayColor(),
                                                                     NSFontAttributeName            : UIFont.systemFontOfSize(16.0)])
    }
    
    // placeholder position
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , self.insetX , self.insetY)
    }
    
    // text position
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , self.insetX , self.insetY)
    }
    
    override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , self.insetX , self.insetY)
    }
}