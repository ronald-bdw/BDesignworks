//
//  RegistrationView.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 19.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

typealias RegistrationMVP = MVPContainer<RegistrationView, RegistrationPresenter, RegistrationModel>

protocol IRegistrationView: class {
    func setLoadingState (_ state: LoadingState)
    func updateValidationErrors()
    
    func showErrorView(_ title: String, content: String, errorType: BackendError)
    func showPhoneCodeReceivedView()
}


class RegistrationView: UIViewController {
    var presenter: PresenterProtocol?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var user: RegistrationUser?
    var shouldShowErrors = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = RegistrationMVP(view: self)
        self.user = self.presenter?.getRegistrationUser()
        self.tableView.reloadData()

        self.tableView.register(UINib(nibName: RegistrationTableViewCell.fs_className, bundle: nil), forCellReuseIdentifier: RegistrationTableViewCell.fs_className)
        self.tableView.register(UINib(nibName: ValidationErrorCell.fs_className, bundle: nil), forCellReuseIdentifier: ValidationErrorCell.fs_className)
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.presenter?.viewDidLoad()
    }
    
    @IBAction func submitPressed(_ sender: AnyObject){
        self.shouldShowErrors = true
        self.presenter?.submitTapped(self.user)
    }
    
    @IBAction func backPressed(_ sender: AnyObject) {
        ShowInitialViewController()
    }
    
    func keyboardWillShow(_ notification: Notification) {
        guard let userInfo: NSDictionary = (notification as NSNotification).userInfo as NSDictionary?,
            let keyboardSize = (userInfo.object(forKey: UIKeyboardFrameBeginUserInfoKey) as? NSValue)?.cgRectValue.size else {return}
        let contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height + 20, 0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func keyboardWillHide(_ notification: Notification) {
        self.scrollView.contentInset = UIEdgeInsets.zero
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
}

extension RegistrationView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cellType = RegistrationCellType(rawValue: indexPath.row) {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: RegistrationTableViewCell.fs_className) as! RegistrationTableViewCell
            cell.prepareCell(cellType, user: self.user)
            
            cell.contentTextField.tag = cellType.rawValue
            cell.contentTextField.delegate = self
            
            return cell
        }
        else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: ValidationErrorCell.fs_className) as! ValidationErrorCell
            let contentCellRow = indexPath.row - 1
            guard let cellType = RegistrationCellType(rawValue: contentCellRow) else {fatalError()}
            cell.prepareCell(cellType)
            return cell
        }
    }
}

extension RegistrationView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath as NSIndexPath).row % 2 {
        case 0:
            return 78
        default:
            return self.shouldShowErrors ?
            (self.user?.isFieldValid(indexPath.row) ?? false) ? 0 : 49 :
            0
        }
    }
}

extension RegistrationView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let textFields = (self.tableView.visibleCells.filter({$0 is RegistrationTableViewCell}) as? [RegistrationTableViewCell])?.map({$0.contentTextField!}) else {return false}
        
        // 2 - because of error views between content cells
        if textFields.map({$0.tag}).contains(textField.tag + 2) {
            textFields.filter({$0.tag == textField.tag + 2}).first?.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
            self.submitPressed(self)
        }
        
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let cellType = RegistrationCellType(rawValue: textField.tag) else {fatalError("cannot init registration cell with tag: \(textField.tag)")}
        
        let nsString = (textField.text ?? "") as NSString
        let newString = nsString.replacingCharacters(in: range,
                                                                    with: string)
        switch cellType {
        case .firstName: self.user?.firstName.content = newString
        case .lastName: self.user?.lastName.content = newString
        case .email: self.user?.email.content = newString
        case .phone: self.user?.phone.content = newString
        }
        
        return true
    }
}

extension RegistrationView: IRegistrationView {
    func updateValidationErrors() {
        self.tableView.reloadData()
    }
    
    func setLoadingState(_ state: LoadingState) {
        switch state {
        case .loading:
            SVProgressHUD.show()
        case .done:
            SVProgressHUD.dismiss()
            ShowConversationViewController()
        case .failed:
            SVProgressHUD.dismiss()
            ShowErrorAlert()
        }
    }
    
    func showErrorView(_ title: String, content: String, errorType: BackendError) {
        SVProgressHUD.dismiss()
        if errorType == .smsCodeNotExist {
            ShowAlertWithHandler(title, message: content) { [weak self] (action) in
                self?.presenter?.resendPhoneCodeTapped(self?.user)
            }
        }
        else {
            ShowErrorAlert(title, message: content)
        }
    }
    
    func showPhoneCodeReceivedView() {
        SVProgressHUD.dismiss()
    }
}

extension RegistrationView: MVPView {
    typealias PresenterProtocol = IRegistrationViewPresenter
}
