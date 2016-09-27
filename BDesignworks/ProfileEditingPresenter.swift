//
//  ProfileEditingPresenter.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 13.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol IProfileEditingPresenterModel: class {
    func userReceived(_ user: ENUser)
    func loadingStarted()
    func loadingFinished(isUserInfoUpdated: Bool)
    func loadingFailed(_ error: RTError)
    func updateInvalidView(_ type: UserEditedValidationField, value: Bool)
}

protocol IProfileEditingPresenterView {
    func viewLoaded()
    func donePressed(_ firstName: String?, lastName: String?, email: String?)
    func imageReceived(image: UIImage)
}

class ProfileEditingPresenter {
    weak var view: ViewProtocol?
    var model: ModelProtocol?
    
    required init() {}
}

extension ProfileEditingPresenter: IProfileEditingPresenterModel {
    func userReceived(_ user: ENUser) {
        self.view?.updateView(user)
    }
    
    func loadingStarted() {
        self.view?.setLoadingState(.loading)
    }
    
    func loadingFailed(_ error: RTError) {
        self.view?.setLoadingState(.failed)
        if case let .backend(backendError) = error {
            self.view?.showBackendErrorView(backendError.humanDescription)
        }
        else {
            self.view?.showErrorView()
        }
    }
    
    func loadingFinished(isUserInfoUpdated: Bool) {
        self.view?.setLoadingState(.done)
        if isUserInfoUpdated {
            self.view?.userInfoUpdated()
        }
    }
    
    func updateInvalidView(_ type: UserEditedValidationField, value: Bool) {
        switch type {
        case .firstName: self.view?.updateFirstNameErrorView(value)
        case .lastName: self.view?.updateLastNameErrorView(value)
        case .email: self.view?.updateEmailErrorView(value)
        }
    }
}

extension ProfileEditingPresenter: IProfileEditingPresenterView {
    func viewLoaded() {
        self.model?.getUser()
    }
    
    func donePressed(_ firstName: String?, lastName: String?, email: String?) {
        guard let mainUser = ENUser.getMainUser() else {return}
        let user = UserEdited(id: mainUser.id, firstName: firstName, lastName: lastName, email: email)
        self.model?.updateUser(user)
    }
    
    func imageReceived(image: UIImage) {
        self.model?.sendAvatar(image: image)
    }
}

extension ProfileEditingPresenter: MVPPresenter {
    typealias ViewProtocol = IProfileEditingView
    typealias ModelProtocol = IProfileEditingModel
}
