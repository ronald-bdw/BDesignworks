//
//  RegistrationProtocol.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 19.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol IRegistrationViewPresenter: class {
    func submitTapped(_ user: RegistrationUser?)
    func getRegistrationUser() -> RegistrationUser?
    func resendPhoneCodeTapped(_ user: RegistrationUser?)
    func viewDidLoad()
}

protocol IRegistrationModelPresenter: class {
    func loadingStarted()
    func loadingSuccessed(user: ENUser)
    func requestFailed(_ error: RTError?)
    func updateValidationErrors()
    func phoneCodeReceived()
}

class RegistrationPresenter {
    weak var view: ViewProtocol?
    var model: ModelProtocol?
    
    required init() {}
}

extension RegistrationPresenter: IRegistrationModelPresenter {
    func loadingStarted() {
        self.view?.setLoadingState(.loading)
    }
    
    func loadingSuccessed(user: ENUser) {
        self.view?.setLoadingState(.done)
    }
    
    func requestFailed(_ error: RTError?) {
        guard let lError = error else {self.view?.setLoadingState(.failed); return}
        if case .backend(let backendError) = lError {
            self.view?.showErrorView(backendError.humanDescription.title, content: backendError.humanDescription.text, errorType: backendError)
            return
        }
        self.view?.setLoadingState(.failed)
    }
    
    func updateValidationErrors() {
        self.view?.updateValidationErrors()
    }
    
    func phoneCodeReceived() {
        self.view?.showPhoneCodeReceivedView()
    }
}

extension RegistrationPresenter: IRegistrationViewPresenter {
    func submitTapped(_ user: RegistrationUser?) {
        guard let lUser = user else {self.view?.setLoadingState(.failed); return}
        do {
            let realm = try Realm()
            if let authInfo = realm.objects(AuthInfo.self).first {
                self.model?.register(lUser, authData: authInfo)
            }
            else {
                self.model?.receivePhoneCode(lUser)
            }
        }
        catch let error {
            Logger.error(error)
            self.view?.setLoadingState(.failed)
        }
    }
    
    func getRegistrationUser() -> RegistrationUser? {
        return self.model?.getRegistrationUser()
    }
    
    func resendPhoneCodeTapped(_ user: RegistrationUser?) {
        guard let lUser = user else {self.view?.setLoadingState(.failed); return}
        self.model?.receivePhoneCode(lUser)
    }
    
    func viewDidLoad() {
        self.model?.registerIfNeeded()
    }
}

extension RegistrationPresenter: MVPPresenter {
    typealias ViewProtocol = IRegistrationView
    typealias ModelProtocol = IRegistrationModel
}
