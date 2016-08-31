//
//  VerificationPresenter.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 19.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol IVerificationViewPresenter: class {
    func submitTapped(code: String?, phone: String?)
}

protocol IVerificationModelPresenter: class {
    func phoneNotValid()
    func codeNotValid()
    func phoneValid()
    func codeValid()
    func phoneCodeReceived()
    func errorOccured()
    func loadingStarted()
}

class VerificationPresenter {
    weak var view: ViewProtocol?
    var model: ModelProtocol?
    
    required init() {}
}

extension VerificationPresenter: IVerificationViewPresenter {
    func submitTapped(code: String?, phone: String?) {
        guard let lCode = code else {return}
        guard let lPhone = phone else {return}
        
        guard self.model?.validateCode(lCode) == true &&
            self.model?.validatePhone(lPhone) == true else {return}
        
        self.model?.submitPhone(lCode + lPhone)
    }
}

extension VerificationPresenter: IVerificationModelPresenter {
    func phoneNotValid() {
        self.view?.showPhoneInvalidView()
    }
    
    func codeNotValid() {
        self.view?.showCodeInvalidView()
    }
    
    func phoneValid() {
        self.view?.dismissPhoneInvalidView()
    }
    
    func codeValid() {
        self.view?.dismissCodeInvalidView()
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