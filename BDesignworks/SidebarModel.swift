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
        let _ = Router.User.getUser.request().responseObject { (response: DataResponse<RTUserResponse>) in
            switch response.result {
            case .success(let value):
                guard let user = value.user else {return}
                self.presenter?.userLoaded(user)
            case .failure(let error):
                Logger.error(error)
            }
        }
    }
}

extension SidebarModel: MVPModel {
    typealias PresenterProtocol = ISidebarPresenterModel
}
