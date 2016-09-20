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
    func loginSuccessed()
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
    
    func loginSuccessed() {
        self.view?.setLoadingState(.done)
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
