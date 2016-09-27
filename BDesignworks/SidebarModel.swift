//
//  SidebarModel.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 15.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation


protocol ISidebarModel {
    func loadUser()
}

class SidebarModel {
    weak var presenter: PresenterProtocol?
    
    required init() {}
}

extension SidebarModel: ISidebarModel {
    func loadUser() {
        if let user = ENUser.getMainUser() {
            self.presenter?.userLoaded(user)
        }
    }
}

extension SidebarModel: MVPModel {
    typealias PresenterProtocol = ISidebarPresenterModel
}
