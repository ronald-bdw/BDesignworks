//
//  RegistrationProtocol.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 19.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol IRegistrationViewPresenter: class {
    func viewLoaded()
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
        if let smsCode = UserDefaults.standard.string(forKey: FSUserDefaultsKey.SmsCode) {
            self.model?.register(smsCode: smsCode)
        }
        else {
            self.view?.setLoadingState(.failed)
            self.view?.showErrorView()
        }
    }
    
    func inAppLoadingFailed(error: Swift.Error?) {
        self.view?.setLoadingState(.failed)
        if let error = error as? InAppErrors {
            guard error != .noSubscriptionPurchased else {return}
            self.view?.showErrorView("Sorry", content: error.localizedDescription, errorType: nil)
        } else {
            self.view?.showErrorView()
        }
    }
    
    func subscriptionStatusUpdated(value: Bool) {
        self.view?.changeButtonState(subscribed: value)
    }
}

extension RegistrationPresenter: IRegistrationModelPresenter {
    func loadingStarted() {
        self.view?.setLoadingState(.loading)
    }
    
    func loadingSuccessed(user: ENUser) {
        ZendeskManager.sharedInstance.trigerTimezoneOnZendesk()
        
        self.view?.setLoadingState(.done)
        self.view?.presentNextScreen()
    }
    
    func requestFailed(_ error: RTError?) {
        self.view?.setLoadingState(.failed)
        guard let lError = error else {self.view?.showErrorView(); return}
        if case .backend(let backendError) = lError {
            self.view?.showErrorView(backendError.humanDescription.title, content: backendError.humanDescription.text, errorType: backendError)
            return
        }
        self.view?.showErrorView()
    }
    
    func updateValidationErrors() {
        self.view?.updateValidationErrors()
    }
    
    func phoneCodeReceived() {
        self.view?.showPhoneCodeReceivedView()
    }
}

extension RegistrationPresenter: IRegistrationViewPresenter {
    func viewLoaded() {
        self.view?.changeButtonState(subscribed: InAppManager.shared.isSubscriptionAvailable)
    }
    
    func submitTapped() {
        if InAppManager.shared.isSubscriptionAvailable {
            if let smsCode = UserDefaults.standard.string(forKey: FSUserDefaultsKey.SmsCode) {
                self.model?.register(smsCode: smsCode)
            }
            else {
                self.view?.setLoadingState(.failed)
                self.view?.showErrorView()
            }
        }
        else {
            self.view?.presentInappAlert()
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
        self.model?.updateRegistrationUser(type: type, text: content)
    }
}

extension RegistrationPresenter: MVPPresenter {
    typealias ViewProtocol = IRegistrationView
    typealias ModelProtocol = IRegistrationModel
}
