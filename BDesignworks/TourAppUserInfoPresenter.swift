//
//  TourAppUserInfoPresenter.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 03/10/2016.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol ITourAppUserInfoPresenterView {
    func fieldsUpdated(cellType: TourAppUserInfoCellType, content: String)
    func getUser() -> TourAppUser?
    func showNextView()
}

protocol ITourAppUserInfoPresenterModel: class {
    func loadingStarted()
    func loadingSuccessed()
    func requestFailed(_ error: RTError?)
    func updateValidationErrors()
}

class TourAppUserInfoPresenter {
    weak var view: ViewProtocol?
    var model: ModelProtocol?
    
    required init() {}
}

extension TourAppUserInfoPresenter: ITourAppUserInfoPresenterView {
    func showNextView() {
        self.model?.sendUserIfNeeded()
    }

    func fieldsUpdated(cellType: TourAppUserInfoCellType, content: String) {
        
        guard var user = self.model?.getUser() else {return}
        switch cellType {
        case .firstName: user.firstName.content = content
        case .lastName: user.lastName.content = content
        case .email: user.email.content = content
        }
        self.model?.updateUser(user: user)
    }
    
    func getUser() -> TourAppUser? {
        return self.model?.getUser()
    }
}

extension TourAppUserInfoPresenter: ITourAppUserInfoPresenterModel {
    func loadingStarted() {
        self.view?.setLoadingState(.loading)
    }
    
    func loadingSuccessed() {
        self.view?.setLoadingState(.done)
    }
    
    func requestFailed(_ error: RTError?) {
        guard let lError = error else {self.view?.setLoadingState(.failed); return}
        if case .backend(let backendError) = lError {
            self.view?.showErrorView(backendError.humanDescription.title, content: backendError.humanDescription.text, errorType: backendError)
            return
        }
        self.view?.setLoadingState(.failed)
    }
    
    func updateValidationErrors() {
        self.view?.updateValidationErrors()
    }
}

extension TourAppUserInfoPresenter: MVPPresenter {
    typealias ViewProtocol = ITourAppUserInfoView
    typealias ModelProtocol = ITourAppUserInfoModel
}
