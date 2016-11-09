//
//  VerificationPresenter.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 19.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol IVerificationViewPresenter: class {
    func submitTapped(_ code: String?, phone: String?)
}

protocol IVerificationModelPresenter: class {
    func phoneNotValid()
    func codeNotValid()
    func phoneValid()
    func codeValid()
    func phoneCodeReceived()
    func errorOccured(error: RTError?)
    func loadingStarted()
    var shouldCheckProvider: Bool {get}
    var shouldCheckRegistration: Bool {get}
    func userHasNoProvider()
    func userNotRegistered()
}

class VerificationPresenter {
    weak var view: ViewProtocol?
    var model: ModelProtocol?
    
    required init() {}
}

extension VerificationPresenter: IVerificationViewPresenter {
    func submitTapped(_ code: String?, phone: String?) {
        guard let lCode = code else {return}
        guard var lPhone = phone else {return}
        
        guard self.model?.validateCode(lCode) == true &&
            self.model?.validatePhone(lPhone) == true else {return}
        guard let lView = self.view else {return}
        if lCode == "+61" && lPhone.substring(to: lPhone.index(after: lPhone.startIndex)) == "0" {
            lPhone = lPhone.substring(from: lPhone.index(after: lPhone.startIndex))
        }
        if lView.shouldCheckProvider || lView.shouldCheckRegistration {
            
            self.model?.checkUserStatus(phone: lCode + lPhone)
        }
        else {
            self.model?.submitPhone(lCode + lPhone)
        }
    }
}

extension VerificationPresenter: IVerificationModelPresenter {
    internal var shouldCheckProvider: Bool {
        get {
            return self.view?.shouldCheckProvider ?? false
        }
    }
    
    internal var shouldCheckRegistration: Bool {
        get {
            return self.view?.shouldCheckRegistration ?? false
        }
    }


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
        self.view?.setLoadingState(.loading)
    }
    
    func phoneCodeReceived() {
        self.view?.setLoadingState(.done)
    }
    
    func errorOccured(error: RTError?) {
        guard let lError = error else {self.view?.setLoadingState(.failed); return}
        if case .backend(let backendError) = lError {
            self.view?.showErrorView(backendError.humanDescription.title, content: backendError.humanDescription.text, errorType: backendError)
            return
        }
        self.view?.setLoadingState(.failed)
    }
    
    func userHasNoProvider() {
        self.view?.showNoProviderAlert()
    }
    
    func userNotRegistered() {
        self.view?.showNotRegisteredAlert()
    }
}

extension VerificationPresenter: MVPPresenter {
    typealias ViewProtocol = IVerificationView
    typealias ModelProtocol = IVerificationModel
}
