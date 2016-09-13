//
//  ProfileModel.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 13.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol IProfileModel {
    func getUser()
}

class ProfileModel {
    var presenter: PresenterProtocol?
    
    required init() {}
}

extension ProfileModel: IProfileModel {
    func getUser() {
        Router.User.GetUser.request().responseObject { (response: Response<RTUserResponse, RTError>) in
            switch response.result {
            case .Success(let value):
                let user = value.user == nil ? User.getMainUser() : value.user
                guard let lUser = user else {return}
                self.presenter?.userReceived(lUser)
            case .Failure(let error):
                Logger.error(error)
                guard let lUser = User.getMainUser() else {return}
                self.presenter?.userReceived(lUser)
            }
        }
    }
}

extension ProfileModel: MVPModel {
    typealias PresenterProtocol = IProfilePresenterModel
}