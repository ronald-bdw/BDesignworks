//
//  LoginPresenter.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 19.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol ILoginViewPresenter: class {
    func resendPhoneCodeTapped()
    func viewLoaded()
}

protocol ILoginModelPresenter: class {
    func loadingStarted()
    func loginSuccessed(user: ENUser)
    func loadingFailed(error: Swift.Error?)
    func phoneCodeSent()
}

class LoginPresenter {
    weak var view: ViewProtocol?
    var model: ModelProtocol?
    
    required init() {}
}

extension LoginPresenter: ILoginModelPresenter {
    
    func loadingStarted() {
        self.view?.setLoadingState(.loading)
    }
    
    func loginSuccessed(user: ENUser) {
        self.view?.setLoadingState(.done)
        if let loggedInUsers = UserDefaults.standard.array(forKey: FSUserDefaultsKey.LoggedInUsers) as? Array<String>,
            loggedInUsers.contains(user.phoneNumber) {
            SmoochHelper.sharedInstance.startWithParameters(user)
            ZendeskManager.sharedInstance.trigerTimezoneOnZendesk()
            FSDispatch_after_short(2.0) { [weak self] in
                self?.view?.presentConversation()
            }
        }
        else {
            self.view?.presentTourApp()
        }
    }
    
    func loadingFailed(error: Swift.Error?) {
        self.view?.setLoadingState(.failed)
        guard let lError = error as? RTError else {self.view?.showErrorView(); return}
        switch lError {
        case .backend(let backendError):
            self.view?.showErrorView(backendError.humanDescription.title, content: backendError.humanDescription.text, errorType: backendError)
            return
        case .request: // when cancelled
            return
        default:
            self.view?.showErrorView()
        }
    }
    
    func phoneCodeSent() {
        self.view?.showPhoneCodeSentView()
    }
}

extension LoginPresenter: ILoginViewPresenter {
    func viewLoaded() {
        
// commented due to logo marketing reasons
//        self.view?.changeProviderLogoState(logoExist: UserDefaults.standard.bool(forKey:FSUserDefaultsKey.IsProviderChosen))
        if let smsCode = UserDefaults.standard.string(forKey: FSUserDefaultsKey.SmsCode) {
            self.model?.login(smsCode)
        }
    }
    
    func resendPhoneCodeTapped() {
        self.model?.resendSmsCode()
    }
}

extension LoginPresenter: MVPPresenter {
    typealias ViewProtocol = ILoginView
    typealias ModelProtocol = ILoginModel
}
