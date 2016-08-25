//
//  VerificationPresenter.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 19.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol IVerificationPresenter: class {
    func submitTapped(code: String, phone: String?)
    
    func phoneNotValid()
    func phoneCodeReceived()
    func errorOccured()
    func loadingStarted()
}

class VerificationPresenter {
    weak var view: ViewProtocol?
    var model: ModelProtocol?
    
    required init() {}
}

extension VerificationPresenter: IVerificationPresenter {
    func submitTapped(code: String, phone: String?) {
        guard let lPhone = phone else {return}
        self.model?.submitPhone(code + lPhone)
    }
    
    func phoneNotValid() {
        self.view?.showPhoneInvalidView()
    }
    
    func loadingStarted() {
        self.view?.setLoadingState(.Loading)
    }
    
    func phoneCodeReceived() {
        self.view?.setLoadingState(.Done)
    }
    
    func errorOccured() {
        self.view?.setLoadingState(.Failed)
    }
}

extension VerificationPresenter: MVPPresenter {
    typealias ViewProtocol = IVerificationView
    typealias ModelProtocol = IVerificationModel
}