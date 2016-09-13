//
//  ProfileEditingView.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 13.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

typealias ProfileEditingMVP = MVPContainer<ProfileEditingView,ProfileEditingPresenter,ProfileEditingModel>

protocol IProfileEditingView: class {
    func updateView(user: User)
    func setLoadingState(state: LoadingState)
}

class ProfileEditingView: UITableViewController {
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailPreviewLabel: UILabel!
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var lastNameTExtField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    
    var presenter: PresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = ProfileEditingMVP(controller: self)
        self.presenter?.viewLoaded()
    }
    
    @IBAction func photoPressed(sender: AnyObject) {
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        self.presenter?.donePressed(self.firstNameTextField.text, lastName: self.lastNameTExtField.text, email: self.emailTextField.text)
    }
}

extension ProfileEditingView: IProfileEditingView {
    func updateView(user: User) {
        self.nameLabel.text = user.fullname
        self.emailPreviewLabel.text = user.email
        self.emailPreviewLabel.text = user.email
        self.firstNameTextField.text = user.firstName
        self.lastNameTExtField.text = user.lastName
        self.emailTextField.text = user.email
    }
    
    
    func setLoadingState(state: LoadingState) {
        switch state {
        case .Loading:
            SVProgressHUD.show()
        case .Done:
            SVProgressHUD.dismiss()
            self.navigationController?.popViewControllerAnimated(true)
        case .Failed:
            SVProgressHUD.dismiss()
            ShowErrorAlert()
        }
    }
}

extension ProfileEditingView: MVPView {
    typealias PresenterProtocol = IProfileEditingPresenterView
}