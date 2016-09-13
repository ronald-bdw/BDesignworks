//
//  ProfileView.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 13.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

class ProfileView: UITableViewController {
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailPreviewLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.testSetup()
    }
    
    func testSetup(){
        self.avatarImageView.image = UIImage(named: "Image")
        self.nameLabel.text = "Jeffrey Lebowski"
        self.emailPreviewLabel.text = "dude@gmail.com"
        self.emailLabel.text = "dude@gmail.com"
        self.phoneLabel.text = "123456789"
    }
}