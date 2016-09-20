//
//  RoundImage.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 15/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

class RoundImage: UIImageView
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.layer.masksToBounds = false
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = self.frame.size.height/2
    }
}
