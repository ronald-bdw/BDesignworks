//
//  VerificationPresenter.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 19.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol IVerificationPresenter: class {
    func submitTapped(code: String, phone: String)
    func phoneCodeReceived()
}

class VerificationPresenter {
    weak var view: ViewProtocol?
    var model: ModelProtocol?
    
    required init() {}
}

extension VerificationPresenter: IVerificationPresenter {
    func submitTapped(code: String, phone: String) {
        self.model?.submitPhone(code + phone)
    }
    
    func phoneCodeReceived() {
        self.view?.showSuccessAlert()
    }
}

extension VerificationPresenter: MVPPresenter {
    typealias ViewProtocol = IVerificationView
    typealias ModelProtocol = IVerificationModel
}