//
//  ProfileView.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 13.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

typealias ProfileMVP = MVPContainer<ProfileView, ProfilePresenter, ProfileModel>

protocol IProfileView: class {
    func updateView(_ with: ENUser)
}

class ProfileView: UITableViewController {
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailPreviewLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var phoneLabel: UILabel!

    var presenter: PresenterProtocol?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        let _ = ProfileMVP(controller: self)
        self.presenter?.viewLoaded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter?.viewLoaded()
    }
    
    @IBAction func backPressed(sender: AnyObject) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension ProfileView: IProfileView {
    func updateView(_ user: ENUser) {
        self.nameLabel.text = user.fullname
        self.emailPreviewLabel.text = user.email
        self.emailLabel.text = user.email
        self.phoneLabel.text = user.phoneNumber
        
        guard let url = URL(string: user.avatarUrl) else {return}
        self.avatarImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "Profile/Avatar"))
    }
}

extension ProfileView: MVPView {
    typealias PresenterProtocol = IProfilePresenterView
}
