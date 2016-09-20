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
    func updateView(_ user: ENUser)
    func setLoadingState(_ state: LoadingState)
    func updateFirstNameErrorView(_ isValid: Bool)
    func updateLastNameErrorView(_ isValid: Bool)
    func updateEmailErrorView(_ isValid: Bool)
    func showBackendErrorView(_ description: ErrorHumanDescription)
    func showErrorView()
}

class ProfileEditingView: UITableViewController {
    
    enum CellType {
        case header
        case empty
        case content
        case error
        
        enum ErrorCellType {
            case firstName
            case lastName
            case email
            
            static func getType(_ row: Int) -> ErrorCellType {
                switch row {
                case 3  : return firstName
                case 5  : return lastName
                case 7  : return email
                default : fatalError()
                }
            }
        }
        
        var height: CGFloat {
            switch self {
            case .header    : return 250
            case .empty     : return 20
            case .content   : return 80
            case .error     : return 60
            }
        }
        
        static func getType(_ row: Int) -> CellType {
            switch row {
            case 0      : return header
            case 1      : return empty
            case 2,4,6  : return content
            case 3,5,7  : return error
            default     : fatalError()
            }
        }
    }
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailPreviewLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTExtField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstNameErrorView: VerificationErrorView!
    @IBOutlet weak var lastNameErrorView: VerificationErrorView!
    @IBOutlet weak var emailErrorView: VerificationErrorView!
    
    var isFirstNameValid    : Bool = true
    var isLastNameValid     : Bool = true
    var isEmailValid        : Bool = true
    
    var textFields: [UITextField] = []
    var presenter: PresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = ProfileEditingMVP(controller: self)
        
        self.setValidationViews()
        self.setTextFieldTags()
        self.presenter?.viewLoaded()
    }
    
    func setTextFieldTags() {
        self.textFields = [self.firstNameTextField, self.lastNameTExtField, self.emailTextField]
        self.firstNameTextField.tag = self.textFields.index(of: self.firstNameTextField) ?? 0
        self.lastNameTExtField.tag = self.textFields.index(of: self.lastNameTExtField) ?? 0
        self.emailTextField.tag = self.textFields.index(of: self.emailTextField) ?? 0
    }
    
    func setValidationViews() {
        self.firstNameErrorView.setLabel(UserEditedValidationField.firstName.validationText)
        self.lastNameErrorView.setLabel(UserEditedValidationField.lastName.validationText)
        self.emailErrorView.setLabel(UserEditedValidationField.email.validationText)
    }
    
    @IBAction func photoPressed(_ sender: AnyObject) {
    }
    
    @IBAction func donePressed(_ sender: AnyObject) {
        self.presenter?.donePressed(self.firstNameTextField.text, lastName: self.lastNameTExtField.text, email: self.emailTextField.text)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = CellType.getType((indexPath as NSIndexPath).row)
        switch cellType {
        case .error:
            let errorCellType = CellType.ErrorCellType.getType((indexPath as NSIndexPath).row)
            switch errorCellType {
            case .firstName : return isFirstNameValid ? 0 : cellType.height
            case .lastName  : return isLastNameValid ? 0 : cellType.height
            case .email     : return isEmailValid ? 0 : cellType.height
            }
        default: return cellType.height
        }
    }
}

extension ProfileEditingView: IProfileEditingView {
    func updateView(_ user: ENUser) {
        self.nameLabel.text = user.fullname
        self.emailPreviewLabel.text = user.email
        self.emailPreviewLabel.text = user.email
        self.firstNameTextField.text = user.firstName
        self.lastNameTExtField.text = user.lastName
        self.emailTextField.text = user.email
    }
    
    
    func setLoadingState(_ state: LoadingState) {
        switch state {
        case .loading:
            SVProgressHUD.show()
        case .done:
            SVProgressHUD.dismiss()
            let _ = self.navigationController?.popViewController(animated: true)
        case .failed:
            SVProgressHUD.dismiss()
        }
    }
    
    func showBackendErrorView(_ description: ErrorHumanDescription) {
        ShowErrorAlert(description.title, message: description.text)
    }
    
    func showErrorView() {
        ShowErrorAlert()
    }
    
    func updateFirstNameErrorView(_ isValid: Bool) {
        self.isFirstNameValid = isValid
        self.tableView.reloadData()
    }
    
    func updateLastNameErrorView(_ isValid: Bool) {
        self.isLastNameValid = isValid
        self.tableView.reloadData()
    }
    
    func updateEmailErrorView(_ isValid: Bool) {
        self.isEmailValid = isValid
        self.tableView.reloadData()
    }
}

extension ProfileEditingView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.tag + 1 < self.textFields.count  {
            self.textFields[textField.tag + 1].becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
            self.donePressed(self)
        }
        
        return false
    }
}

extension ProfileEditingView: MVPView {
    typealias PresenterProtocol = IProfileEditingPresenterView
}
