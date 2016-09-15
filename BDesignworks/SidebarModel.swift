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
        if let user = User.getMainUser() {
            self.presenter?.userLoaded(user)
        }
        Router.User.GetUser.request().responseObject { (response: Response<RTUserResponse, RTError>) in
            switch response.result {
            case .Success(let value):
                guard let user = value.user else {return}
                self.presenter?.userLoaded(user)
            case .Failure(let error):
                Logger.error(error)
            }
        }
    }
}

extension SidebarModel: MVPModel {
    typealias PresenterProtocol = ISidebarPresenterModel
}