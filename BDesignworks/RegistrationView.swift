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
    var presenter: IRegistrationPresenter?
    
    @IBAction func submitPressed(sender: AnyObject){
        self.presenter?.submitTapped("firstname", lastname: "lastname", email: "user@t.t", phone: "12345678900")
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