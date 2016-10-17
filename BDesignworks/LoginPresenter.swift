//
//  LoginPresenter.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 19.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol ILoginViewPresenter: class {
    func login()
    func resendPhoneCodeTapped()
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
        if case .backend(let backendError) = lError {
            self.view?.showErrorView(backendError.humanDescription.title, content: backendError.humanDescription.text, errorType: backendError)
            return
        }
        self.view?.showErrorView()
    }
    
    func phoneCodeSent() {
        self.view?.showPhoneCodeSentView()
    }
}

extension LoginPresenter: ILoginViewPresenter {
    func login() {
        self.model?.login("1234")
    }
    
    func resendPhoneCodeTapped() {
        self.model?.resendSmsCode()
    }
}

extension LoginPresenter: MVPPresenter {
    typealias ViewProtocol = ILoginView
    typealias ModelProtocol = ILoginModel
}
