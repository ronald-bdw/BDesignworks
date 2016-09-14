//
//  ProfileEditingPresenter.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 13.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol IProfileEditingPresenterModel: class {
    func userReceived(user: User)
    func loadingStarted()
    func loadingFinished()
    func loadingFailed()
    func updateInvalidView(type: UserEditedValidationField, value: Bool)
}

protocol IProfileEditingPresenterView {
    func viewLoaded()
    func donePressed(firstName: String?, lastName: String?, email: String?)
}

class ProfileEditingPresenter {
    weak var view: ViewProtocol?
    var model: ModelProtocol?
    
    required init() {}
}

extension ProfileEditingPresenter: IProfileEditingPresenterModel {
    func userReceived(user: User) {
        self.view?.updateView(user)
    }
    
    func loadingStarted() {
        self.view?.setLoadingState(.Loading)
    }
    
    func loadingFailed() {
        self.view?.setLoadingState(.Failed)
    }
    
    func loadingFinished() {
        self.view?.setLoadingState(.Done)
    }
    
    func updateInvalidView(type: UserEditedValidationField, value: Bool) {
        switch type {
        case .FirstName: self.view?.updateFirstNameErrorView(value)
        case .LastName: self.view?.updateLastNameErrorView(value)
        case .Email: self.view?.updateEmailErrorView(value)
        }
    }
}

extension ProfileEditingPresenter: IProfileEditingPresenterView {
    func viewLoaded() {
        self.model?.getUser()
    }
    
    func donePressed(firstName: String?, lastName: String?, email: String?) {
        guard let mainUser = User.getMainUser() else {return}
        let user = UserEdited(id: mainUser.id, firstName: firstName, lastName: lastName, email: email, avatar: nil)
        self.model?.updateUser(user)
    }
}

extension ProfileEditingPresenter: MVPPresenter {
    typealias ViewProtocol = IProfileEditingView
    typealias ModelProtocol = IProfileEditingModel
}