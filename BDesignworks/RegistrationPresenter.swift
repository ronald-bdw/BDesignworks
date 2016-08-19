//
//  RegistrationProtocol.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 19.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol IRegistrationPresenter: class {
    func submitTapped(firstName: String, lastname: String, email: String, phone: String)
    
    func registrationStarted()
    func registrationSuccessed()
    func registrationFailed()
}

class RegistrationPresenter {
    weak var view: IRegistrationView?
    var model: IRegistrationModel?
    
    required init() {}
}

extension RegistrationPresenter: IRegistrationPresenter {
    func submitTapped(firstName: String, lastname: String, email: String, phone: String) {
        self.model?.register(firstName, lastName: lastname, email: email, phone: phone)
    }
    
    func registrationStarted() {
        self.view?.setLoadingState(.Loading)
    }
    
    func registrationSuccessed() {
        self.view?.setLoadingState(.Done)
    }
    
    func registrationFailed() {
        self.view?.setLoadingState(.Failed)
    }
}

extension RegistrationPresenter: MVPPresenter {
    typealias ViewProtocol = IRegistrationView
    typealias ModelProtocol = IRegistrationModel
}