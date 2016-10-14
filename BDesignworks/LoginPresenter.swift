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
}

protocol ILoginModelPresenter: class {
    func loginStarted()
    func loginSuccessed(user: ENUser)
    func loginFailed()
}

class LoginPresenter {
    weak var view: ViewProtocol?
    var model: ModelProtocol?
    
    required init() {}
}

extension LoginPresenter: ILoginModelPresenter {
    
    func loginStarted() {
        self.view?.setLoadingState(.loading)
    }
    
    func loginSuccessed(user: ENUser) {
        if let loggedInUsers = UserDefaults.standard.array(forKey: FSUserDefaultsKey.LoggedInUsers) as? Array<String>,
            loggedInUsers.contains(user.phoneNumber) {
            SmoochHelper.sharedInstance.startWithParameters(user)
            FSDispatch_after_short(2.0) { [weak self] in
                self?.view?.setLoadingState(.done)
                self?.view?.presentConversation()
            }
        }
        else {
            var loggedInUsers = UserDefaults.standard.array(forKey: FSUserDefaultsKey.LoggedInUsers) as? Array<String> ?? Array<String> ()
            loggedInUsers.append(user.phoneNumber)
            UserDefaults.standard.set(loggedInUsers, forKey: FSUserDefaultsKey.LoggedInUsers)
            UserDefaults.standard.synchronize()
            self.view?.setLoadingState(.done)
            self.view?.presentTourApp()
        }
    }
    
    func loginFailed() {
        self.view?.setLoadingState(.failed)
    }
}

extension LoginPresenter: ILoginViewPresenter {
    func login() {
        self.model?.login("1234")
    }
}

extension LoginPresenter: MVPPresenter {
    typealias ViewProtocol = ILoginView
    typealias ModelProtocol = ILoginModel
}
