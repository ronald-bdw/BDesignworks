//
//  ProfileEditingView.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 13.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

class ProfileEditingView: UITableViewController {
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailPreviewLabel: UILabel!
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTExtField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var phoneTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func photoPressed(sender: AnyObject) {
    }
    
}