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
    func setLoadingState (state: LoadingState)
}

class RegistrationView: UIViewController {
    var presenter: PresenterProtocol?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: RegistrationTableViewCell.fs_className, bundle: nil), forCellReuseIdentifier: RegistrationTableViewCell.fs_className)
    }
    
    @IBAction func submitPressed(sender: AnyObject){
        self.presenter?.submitTapped("firstname", lastname: "lastname", email: "user@t.t", phone: "12345678900")
    }
}

extension RegistrationView: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(RegistrationTableViewCell.fs_className) as! RegistrationTableViewCell
        guard let cellType = RegistrationCellType(rawValue: indexPath.row) else {fatalError("cannot init registration cell with indexPath: \(indexPath)")}
        cell.prepareCell(cellType)
        
        cell.contentTextField.tag = cellType.rawValue
        cell.contentTextField.delegate = self
        
        return cell
    }
}

extension RegistrationView: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        guard let textFields = (self.tableView.visibleCells as? [RegistrationTableViewCell])?.map({$0.contentTextField}) else {return false}
        if textFields.map({$0.tag}).contains(textField.tag + 1) {
            textFields.filter({$0.tag == textField.tag + 1}).first?.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
            self.submitPressed(self)
        }
        
        return false
    }
}

extension RegistrationView: IRegistrationView {
    func setLoadingState(state: LoadingState) {
        switch state {
        case .Loading:
            Logger.debug("loading")
        case .Done:
            Logger.debug("done")
        case .Failed:
            Logger.debug("failed")
        }
    }
}

extension RegistrationView: MVPView {
    typealias PresenterProtocol = IRegistrationPresenter
}