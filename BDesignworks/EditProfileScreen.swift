//
//  EditProfileScreen.swift
//  BDesignworks
//
//  Created by Eduard Lisin on 11/08/16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

class EditProfileScreen: UITableViewController
{
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailMiniLabel: UILabel!
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTExtField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var phoneTextField: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.title = "Edit profile"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: #selector(saveInformation))
        
        self.fillTestInfo()
    }
    
    func saveInformation()
    {
        
    }
    
    func fillTestInfo()
    {
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.height / 2
        self.profileImage.image = UIImage(named: "Image")
        
        self.nameLabel.text = "Jeffrey Lebowski"
        self.emailMiniLabel.text = "dude@gmail.com"
        
        self.firstNameTextField.text = "Jeffrey"
        self.lastNameTExtField.text = "Lebowski"
        self.emailTextField.text = "dude@gmail.com"
        self.phoneTextField.text = "123456789"
    }
}
