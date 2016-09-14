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
    func updateFirstNameErrorView(isValid: Bool)
    func updateLastNameErrorView(isValid: Bool)
    func updateEmailErrorView(isValid: Bool)
}

class ProfileEditingView: UITableViewController {
    
    enum CellType {
        case Header
        case Empty
        case Content
        case Error
        
        enum ErrorCellType {
            case FirstName
            case LastName
            case Email
            
            static func getType(row: Int) -> ErrorCellType {
                switch row {
                case 3  : return FirstName
                case 5  : return LastName
                case 7  : return Email
                default : fatalError()
                }
            }
        }
        
        var height: CGFloat {
            switch self {
            case .Header    : return 250
            case .Empty     : return 20
            case .Content   : return 80
            case .Error     : return 60
            }
        }
        
        static func getType(row: Int) -> CellType {
            switch row {
            case 0      : return Header
            case 1      : return Empty
            case 2,4,6  : return Content
            case 3,5,7  : return Error
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
    
    var presenter: PresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = ProfileEditingMVP(controller: self)
        
        self.setValidationViews()
        self.setTextFieldTags()
        self.presenter?.viewLoaded()
    }
    
    func setTextFieldTags() {
        self.firstNameTextField.tag = 0
        self.lastNameTExtField.tag = 1
        self.emailTextField.tag = 2
    }
    
    func setValidationViews() {
        self.firstNameErrorView.setLabel(UserEditedValidationField.FirstName.validationText)
        self.lastNameErrorView.setLabel(UserEditedValidationField.LastName.validationText)
        self.emailErrorView.setLabel(UserEditedValidationField.Email.validationText)
    }
    
    @IBAction func photoPressed(sender: AnyObject) {
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        self.presenter?.donePressed(self.firstNameTextField.text, lastName: self.lastNameTExtField.text, email: self.emailTextField.text)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cellType = CellType.getType(indexPath.row)
        switch cellType {
        case .Error:
            let errorCellType = CellType.ErrorCellType.getType(indexPath.row)
            switch errorCellType {
            case .FirstName : return isFirstNameValid ? 0 : cellType.height
            case .LastName  : return isLastNameValid ? 0 : cellType.height
            case .Email     : return isEmailValid ? 0 : cellType.height
            }
        default: return cellType.height
        }
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
    
    func updateFirstNameErrorView(isValid: Bool) {
        self.isFirstNameValid = isValid
        self.tableView.reloadData()
    }
    
    func updateLastNameErrorView(isValid: Bool) {
        self.isLastNameValid = isValid
        self.tableView.reloadData()
    }
    
    func updateEmailErrorView(isValid: Bool) {
        self.isEmailValid = isValid
        self.tableView.reloadData()
    }
}

extension ProfileEditingView: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let nextTextField = self.view.viewWithTag(textField.tag + 1) as? UITextField {
            nextTextField.becomeFirstResponder()
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