//
//  RegistrationProtocol.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 19.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol IRegistrationPresenter: class {
    func submitTapped(user: RegistrationUser?)
    func getRegistrationUser() -> RegistrationUser?
    func resendPhoneCodeTapped(user: RegistrationUser?)
    
    func registrationStarted()
    func registrationSuccessed()
    func requestFailed(error: RTError?)
    func updateValidationErrors()
    func phoneCodeReceived()
}

extension IRegistrationPresenter {
    func requestFailed(error: RTError? = nil) {}
}

class RegistrationPresenter {
    weak var view: ViewProtocol?
    var model: ModelProtocol?
    
    required init() {}
}

extension RegistrationPresenter: IRegistrationPresenter {
    func submitTapped(user: RegistrationUser?) {
        guard let lUser = user else {return}
        self.model?.register(lUser)
    }
    
    func getRegistrationUser() -> RegistrationUser? {
        return self.model?.getRegistrationUser()
    }
    
    func registrationStarted() {
        self.view?.setLoadingState(.Loading)
    }
    
    func registrationSuccessed() {
        self.view?.setLoadingState(.Done)
    }
    
    func requestFailed(error: RTError? = nil) {
        guard let lError = error else {self.view?.setLoadingState(.Failed); return}
        if case .Backend(let backendError) = lError {
            self.view?.showErrorView(backendError.humanDescription.title, content: backendError.humanDescription.text, errorType: backendError)
            return
        }
        self.view?.setLoadingState(.Failed)
    }
    
    func updateValidationErrors() {
        self.view?.updateValidationErrors()
    }
    
    func resendPhoneCodeTapped(user: RegistrationUser?) {
        self.model?.receivePhoneCode(user)
    }
    
    func phoneCodeReceived() {
        self.view?.showPhoneCodeReceivedView()
    }
}

extension RegistrationPresenter: MVPPresenter {
    typealias ViewProtocol = IRegistrationView
    typealias ModelProtocol = IRegistrationModel
}