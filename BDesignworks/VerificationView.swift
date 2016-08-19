//
//  VerificationView.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 19.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

typealias VerificationMVP = MVPContainer<VerificationView, VerificationPresenter, VerificationModel>

protocol IVerificationView: class {
    func showSuccessAlert()
}

class VerificationView: UIViewController {
    
    var presenter: IVerificationPresenter?
    
    @IBAction func submitPressed(sender: AnyObject){
        self.presenter?.submitTapped("7", phone: "9377709988")
    }
    
}

extension VerificationView: IVerificationView {
    func showSuccessAlert() {
        Logger.debug("successful verification")
    }
}

extension VerificationView: MVPView {
    typealias PresenterProtocol = IVerificationPresenter
}