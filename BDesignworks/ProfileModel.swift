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
    weak var presenter: PresenterProtocol?
    
    required init() {}
}

extension ProfileModel: IProfileModel {
    func getUser() {
        let _ = Router.User.getUser.request().responseObject { (response: DataResponse<RTUserResponse>) in
            switch response.result {
            case .success(let value):
                let user = value.user == nil ? User.getMainUser() : value.user
                guard let lUser = user else {return}
                self.presenter?.userReceived(lUser)
                guard let receivedUser = value.user else {return}
                do {
                    let realm = try Realm()
                    try realm.write({
                        realm.add(receivedUser, update: true)
                    })
                }
                catch let error {
                    Logger.error(error)
                }
            case .failure(let error):
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
