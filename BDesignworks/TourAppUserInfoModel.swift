//
//  TourAppUserInfoModel.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 03/10/2016.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol ITourAppUserInfoModel {
    func getUser() -> TourAppUser
    func updateUser(user: TourAppUser)
    func sendUserIfNeeded()
}

class TourAppUserInfoModel {
    weak var presenter: PresenterProtocol?
    
    var user: TourAppUser
    var isUserUpdated: Bool = false
    
    required init() {
        self.user = ENUser.getMainUser()?.getTourAppUser() ?? TourAppUser()
    }
}

extension TourAppUserInfoModel: ITourAppUserInfoModel {
    func getUser() -> TourAppUser {
        return self.user
    }
    
    func updateUser(user: TourAppUser) {
        self.user = user
        self.isUserUpdated = true
    }
    
    func sendUserIfNeeded() {
        guard self.isUserUpdated else {self.presenter?.loadingSuccessed(); return}
        guard let id = ENUser.getMainUser()?.id else {self.presenter?.requestFailed(nil); return}
        self.presenter?.loadingStarted()
        let userEdited = UserEdited(id: id, firstName: self.user.firstName.content, lastName: self.user.lastName.content, email: self.user.email.content)
        let _ = Router.User.editUser(user: userEdited).request().responseObject { (response: DataResponse<RTUserResponse>) in
            switch response.result {
            case .success(let value):
                guard let user = value.user else {return}
                do {
                    let realm = try Realm()
                    try realm.write({
                        realm.add(user, update: true)
                    })
                    self.presenter?.loadingSuccessed()
                }
                catch let error {
                    Logger.error(error)
                    self.presenter?.requestFailed(nil)
                }
                Logger.debug(value.user)
            case .failure(let error):
                self.presenter?.requestFailed(error as? RTError)
                Logger.error(error)
            }
        }
    }
}

extension TourAppUserInfoModel: MVPModel {
    typealias PresenterProtocol = ITourAppUserInfoPresenterModel
}
