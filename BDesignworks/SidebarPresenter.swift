//
//  SidebarPresenter.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 15.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol ISidebarPresenterModel: class {
    func userLoaded(user: User)
}

protocol ISidebarPresenterView {
    func viewLoaded()
}


class SidebarPresenter {
    weak var view: ViewProtocol?
    var model: ModelProtocol?
    
    required init() {}
}

extension SidebarPresenter: ISidebarPresenterModel {
    func userLoaded(user: User) {
        self.view?.updateView(user)
    }
}

extension SidebarPresenter: ISidebarPresenterView {
    func viewLoaded() {
        self.model?.loadUser()
    }
}

extension SidebarPresenter: MVPPresenter {
    typealias ViewProtocol = ISidebarView
    typealias ModelProtocol = ISidebarModel
}