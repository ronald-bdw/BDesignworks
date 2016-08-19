//
//  CustomNavigationController.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 11/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationBar.barTintColor = AppColors.MainColor
        self.navigationBar.tintColor = UIColor.whiteColor()
        
    }
}
