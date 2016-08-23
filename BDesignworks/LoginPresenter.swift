//
//  LoginPresenter.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 19.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol ILoginPresenter: class {
    func login()
    
    func loginStarted()
    func loginSuccessed()
    func loginFailed()
}

class LoginPresenter {
    weak var view: ViewProtocol?
    var model: ModelProtocol?
    
    required init() {}
}

extension LoginPresenter: ILoginPresenter {
    func login() {
        self.model?.login("1234")
    }
    
    func loginStarted() {
        self.view?.setLoadingState(.Loading)
    }
    
    func loginSuccessed() {
        self.view?.setLoadingState(.Done)
    }
    
    func loginFailed() {
        self.view?.setLoadingState(.Failed)
    }
}

extension LoginPresenter: MVPPresenter {
    typealias ViewProtocol = ILoginView
    typealias ModelProtocol = ILoginModel
}