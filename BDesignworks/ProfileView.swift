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
    func updateView(with: User)
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter?.viewLoaded()
    }
}

extension ProfileView: IProfileView {
    func updateView(user: User) {
        self.nameLabel.text = user.fullname
        self.emailPreviewLabel.text = user.email
        self.emailLabel.text = user.email
        self.phoneLabel.text = user.phoneNumber
    }
}

extension ProfileView: MVPView {
    typealias PresenterProtocol = IProfilePresenterView
}