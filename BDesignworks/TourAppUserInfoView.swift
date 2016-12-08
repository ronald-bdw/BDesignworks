//
//  TourAppUserInfoView.swift
//  BDesignworks
//
//  Created by Ellina Kuznecova on 28.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation
import UserNotifications

typealias TourAppUserInfoMVP = MVPContainer<TourAppUserInfoView, TourAppUserInfoPresenter, TourAppUserInfoModel>

protocol ITourAppUserInfoView: class {
    func setLoadingState (_ state: LoadingState)
    func updateValidationErrors()
    
    func showErrorView(_ title: String, content: String, errorType: BackendError)
}

class TourAppUserInfoView: UIViewController {
    
    enum SegueIdentifier: String {
        case toSecondStep = "toSecondStep"
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var presenter: PresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.accessibilityLabel = "Tour app user info screen"
        
        let _ = TourAppUserInfoMVP(controller: self)
        
        self.tableView.register(UINib(nibName: RegistrationTableViewCell.fs_className, bundle: nil), forCellReuseIdentifier: RegistrationTableViewCell.fs_className)
        self.tableView.register(UINib(nibName: ValidationErrorCell.fs_className, bundle: nil), forCellReuseIdentifier: ValidationErrorCell.fs_className)
        
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        center.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        center.addObserver(self, selector: #selector(self.healthKitRegistered(_:)), name: NSNotification.Name(rawValue: FSNotificationKey.FitnessDataIntegration.HealthKit) , object: nil)
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        self.presenter?.viewAppeared()
    }
    
    @IBAction func nextPressed(_ sender: AnyObject) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                UIApplication.shared.registerForRemoteNotifications()
                HealthKitManager.sharedInstance.authorize()
            }
        }else{
            let notificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        }
        
    }
    
    func healthKitRegistered(_ notification: Notification) {
        DispatchQueue.main.async {[weak self] in
            self?.presenter?.showNextView()
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        guard let userInfo: NSDictionary = (notification as NSNotification).userInfo as NSDictionary?,
            let keyboardSize = (userInfo.object(forKey: UIKeyboardFrameBeginUserInfoKey) as? NSValue)?.cgRectValue.size else {return}
        let contentInsets = UIEdgeInsetsMake(0, 0, keyboardSize.height - (self.view.fs_height - self.tableView.fs_height - 40), 0)
        self.tableView.contentInset = contentInsets
        self.tableView.scrollIndicatorInsets = contentInsets
    }
    
    func keyboardWillHide(_ notification: Notification) {
        self.tableView.contentInset = UIEdgeInsets.zero
        self.tableView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
}

extension TourAppUserInfoView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return self.tableView.dequeueReusableCell(withIdentifier: "profileHeader")!
        }
        if indexPath.row == 7 {
            return self.tableView.dequeueReusableCell(withIdentifier: "profileFooter")!
        }
        if let cellType = TourAppUserInfoCellType(rawValue: indexPath.row) {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: RegistrationTableViewCell.fs_className) as! RegistrationTableViewCell
            cell.prepareCell(cellType, user: self.presenter?.getUser())
            
            cell.contentTextField.tag = cellType.rawValue
            cell.contentTextField.delegate = self
            
            return cell
        }
        else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: ValidationErrorCell.fs_className) as! ValidationErrorCell
            let contentCellRow = indexPath.row - 1
            guard let cellType = TourAppUserInfoCellType(rawValue: contentCellRow) else {fatalError()}
            cell.prepareCell(cellType)
            return cell
        }
    }
}

extension TourAppUserInfoView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row != 0 else {return 260}
        guard indexPath.row != 7 else {return 100}
        switch (indexPath as NSIndexPath).row % 2 {
        case 0:
            return (self.presenter?.getUser()?.isFieldValid(indexPath.row) ?? false) ? 0 : 60 
        default:
            return 78
        }
    }
}

extension TourAppUserInfoView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        guard let textFields = (self.tableView.visibleCells.filter({$0 is RegistrationTableViewCell}) as? [RegistrationTableViewCell])?.map({$0.contentTextField!}) else {return false}
        
        // 2 - because of error views between content cells
        if textFields.map({$0.tag}).contains(textField.tag + 2) {
            textFields.filter({$0.tag == textField.tag + 2}).first?.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
            self.nextPressed(self)
        }
        
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let cellType = TourAppUserInfoCellType(rawValue: textField.tag) else {fatalError("cannot init registration cell with tag: \(textField.tag)")}
        
        let nsString = (textField.text ?? "") as NSString
        let newString = nsString.replacingCharacters(in: range,
                                                     with: string)
        self.presenter?.fieldsUpdated(cellType: cellType, content: newString)
        
        return true
    }
}

extension TourAppUserInfoView: ITourAppUserInfoView {
    
    func updateValidationErrors() {
        self.tableView.reloadData()
    }
    
    func setLoadingState(_ state: LoadingState) {
        switch state {
        case .loading:
            SVProgressHUD.show()
        case .done:
            SVProgressHUD.dismiss()
            self.performSegue(withIdentifier: SegueIdentifier.toSecondStep.rawValue, sender: self)
        case .failed:
            SVProgressHUD.dismiss()
            ShowErrorAlert()
        }
    }
    
    func showErrorView(_ title: String, content: String, errorType: BackendError) {
        SVProgressHUD.dismiss()
        ShowErrorAlert(title, message: content)
    }
}

extension TourAppUserInfoView: MVPView {
    typealias PresenterProtocol = ITourAppUserInfoPresenterView
}
