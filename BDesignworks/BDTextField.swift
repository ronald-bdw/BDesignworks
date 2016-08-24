//
//  BDTextField.swift
//  BDesignworks
//
//  Created by Galiev Aynur on 21.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

@IBDesignable
public class BDTextField: UITextField {
    
    @IBInspectable var insetX: CGFloat = 0
    @IBInspectable var insetY: CGFloat = 0
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "",
                                                        attributes: [NSForegroundColorAttributeName : UIColor.darkGrayColor(),
                                                                     NSFontAttributeName            : UIFont.systemFontOfSize(16.0)])
    }
    
    // placeholder position
    override public func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , self.insetX , self.insetY)
    }
    
    // text position
    override public func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , self.insetX , self.insetY)
    }
    
    override public func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , self.insetX , self.insetY)
    }
}