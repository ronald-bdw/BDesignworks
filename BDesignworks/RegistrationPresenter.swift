//
//  RegistrationProtocol.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 19.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol IRegistrationViewPresenter: class {
    func submitTapped()
    func getRegistrationUser() -> RegistrationUser?
    func registrationFieldUpdated(type: RegistrationCellType, text: String)
    func resendPhoneCodeTapped()
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
    
    required init() {
        InAppManager.shared.delegate = self
    }
}

extension RegistrationPresenter: InAppManagerDelegate {
    func inAppLoadingStarted() {
        self.view?.setLoadingState(.loading)
    }
    
    func inAppLoadingSucceded(productType: ProductType) {
        do {
            let realm = try Realm()
            if let authInfo = realm.objects(AuthInfo.self).first {
                self.model?.register(authData: authInfo)
            }
            else {
                self.model?.receivePhoneCode()
            }
        }
        catch let error {
            Logger.error(error)
            self.view?.setLoadingState(.failed)
        }
    }
    
    func inAppLoadingFailed(error: Swift.Error?) {
        self.view?.setLoadingState(.failed)
    }
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
    func submitTapped() {
        if let smsCode = UserDefaults.standard.string(forKey: FSUserDefaultsKey.SmsCode) {
            self.model?.register(smsCode: smsCode)
        }
        else {
            self.view?.setLoadingState(.failed)
        }
    }
    
    func getRegistrationUser() -> RegistrationUser? {
        return self.model?.getRegistrationUser()
    }
    
    func registrationFieldUpdated(type: RegistrationCellType, text: String) {
        self.model?.updateRegistrationUser(type: type, text: text)
    }
    
    func resendPhoneCodeTapped() {
        self.model?.receivePhoneCode()
    }
    
    func userFieldModified(type: RegistrationCellType, content: String) {
        self.model?.updateUser(type: type, content: content)
    }
}

extension RegistrationPresenter: MVPPresenter {
    typealias ViewProtocol = IRegistrationView
    typealias ModelProtocol = IRegistrationModel
}
