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
    func showErrorView()
    func showErrorView(_ title: String, content: String, errorType: BackendError?)
    func showPhoneCodeReceivedView()
    func presentNextScreen()
    func presentInappAlert()
    func changeButtonState(subscribed: Bool)
}


class RegistrationView: UIViewController {
    var presenter: PresenterProtocol?
    
    @IBOutlet weak var tableView: UITableView!
    weak var submitButton: UIButton?
    
    var shouldShowErrors = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.accessibilityLabel = "Registration screen"
        
        InAppManager.shared.loadProducts()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        let _ = RegistrationMVP(view: self)
        self.tableView.reloadData()

        self.tableView.register(UINib(nibName: RegistrationTableViewCell.fs_className, bundle: nil), forCellReuseIdentifier: RegistrationTableViewCell.fs_className)
        self.tableView.register(UINib(nibName: ValidationErrorCell.fs_className, bundle: nil), forCellReuseIdentifier: ValidationErrorCell.fs_className)
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter?.viewLoaded()
    }
    
    @IBAction func submitPressed(_ sender: AnyObject){
        self.shouldShowErrors = true
        self.presenter?.submitTapped()
    }
    
    @IBAction func backPressed(_ sender: AnyObject) {
        ShowInitialViewController()
    }
    
    @IBAction func didChangeState(_ sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        guard let userInfo: NSDictionary = (notification as NSNotification).userInfo as NSDictionary?,
            let keyboardSize = (userInfo.object(forKey: UIKeyboardFrameBeginUserInfoKey) as? NSValue)?.cgRectValue.size else {return}
        let contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height + 20, 0)
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
    }
    
    func keyboardWillHide(_ notification: Notification) {
        self.tableView.contentInset = UIEdgeInsets.zero
        self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
}

extension RegistrationView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row != 6 else {
            return self.tableView.dequeueReusableCell(withIdentifier: "emptyCell")!
        }
        guard indexPath.row != 7 else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "registrationFooter") as! RegistrationFooter
            self.submitButton = cell.submitButton
            return cell
        }
        if let cellType = RegistrationCellType(rawValue: indexPath.row) {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: RegistrationTableViewCell.fs_className) as! RegistrationTableViewCell
            cell.prepareCell(cellType, user: self.presenter?.getRegistrationUser())
            
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
        guard indexPath.row != 6 else {
            let cellsHeight = Array(0..<indexPath.row)
                .map({IndexPath(row:$0, section: 0)})
                .map({self.tableView(tableView, heightForRowAt: $0)})
                .reduce(0, {$0 + $1}) + 100
            
            let emptySpaceHeight = self.tableView.fs_height - cellsHeight
            return emptySpaceHeight > 0 ? emptySpaceHeight : 0
        }
        guard indexPath.row != 7 else {
            return 100
        }
        switch (indexPath as NSIndexPath).row % 2 {
        case 0:
            return 78
        default:
            return self.shouldShowErrors ?
            (self.presenter?.getRegistrationUser()?.isFieldValid(indexPath.row) ?? false) ? 0 : 60 :
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
        let newString = nsString.replacingCharacters(in: range, with: string)
        self.presenter?.registrationFieldUpdated(type: cellType, text: newString)
        
        return true
    }
}

extension RegistrationView: IRegistrationView {
    func updateValidationErrors() {
        self.tableView.reloadData()
        SVProgressHUD.dismiss()
    }
    
    func setLoadingState(_ state: LoadingState) {
        switch state {
        case .loading:
            SVProgressHUD.show()
        case .done:
            SVProgressHUD.dismiss()
        case .failed:
            SVProgressHUD.dismiss()
        }
    }
    
    func showErrorView() {
        ShowErrorAlert()
    }
    
    func showErrorView(_ title: String, content: String, errorType: BackendError?) {
        if errorType == .smsCodeExpired ||
            errorType == .smsCodeInvalid {
            ShowAlertWithHandler(title, message: content) { [weak self] (action) in
                self?.presenter?.resendPhoneCodeTapped()
            }
        }
        else {
            ShowErrorAlert(title, message: content)
        }
    }
    
    func showPhoneCodeReceivedView() {
        SVProgressHUD.dismiss()
        ShowOKAlert("Success!", message: "Please wait for sms with code.")
    }
    
    func presentNextScreen() {
        ShowTourAppViewController()
    }
    
    func presentInappAlert() {
        ShowInAppAlert()
    }
    
    func changeButtonState(subscribed: Bool) {
        if subscribed {
            self.submitButton?.setTitle("Submit", for: .normal)
        } else {
            self.submitButton?.setTitle("Choose your plan", for: .normal)
        }
        self.tableView.reloadData()
    }
}

extension RegistrationView: MVPView {
    typealias PresenterProtocol = IRegistrationViewPresenter
}
