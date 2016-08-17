//
//  ProfileScreen.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 05/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

class ProfileScreen: UITableViewController
{
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailMiniLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Profile"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: #selector(editProfilePressed))
        
        self.testSetup()
    }
    
    func editProfilePressed()
    {
        self.performSegueWithIdentifier("toEditProfile", sender: nil)
    }
    
    func testSetup()
    {
        self.avatarImageView.image = UIImage(named: "Image")
        self.nameLabel.text = "Jeffrey Lebowski"
        self.emailMiniLabel.text = "dude@gmail.com"
        self.emailLabel.text = "dude@gmail.com"
        self.phoneLabel.text = "123456789"
    }
}
