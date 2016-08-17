//
//  SettingsScreen.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 05/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

class SettingsScreen: UITableViewController
{
    @IBOutlet var profilePhoto: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Settings"
        
        self.profilePhoto.layer.cornerRadius = self.profilePhoto.frame.size.height / 2
        self.profilePhoto.image = UIImage(named: "Image")
    }
}
