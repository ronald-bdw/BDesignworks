//
//  ProfilePresenter.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 13.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol IProfilePresenterView {
    func viewLoaded()
}

protocol IProfilePresenterModel: class {
    func userReceived(user: User)
}

class ProfilePresenter {
    weak var view: ViewProtocol?
    var model: ModelProtocol?
    
    required init() {}
}

extension ProfilePresenter: IProfilePresenterView {
    func viewLoaded() {
        self.model?.getUser()
    }
}

extension ProfilePresenter: IProfilePresenterModel {
    func userReceived(user: User) {
        self.view?.updateView(user)
    }
}

extension ProfilePresenter: MVPPresenter {
    typealias ViewProtocol = IProfileView
    typealias ModelProtocol = IProfileModel
}