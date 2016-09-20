//
//  ProfileEditingModel.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 13.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol IProfileEditingModel {
    func getUser()
    func updateUser(_ user: UserEdited)
}

class ProfileEditingModel {
    weak var presenter: PresenterProtocol?
    
    required init() {}
}

extension ProfileEditingModel: IProfileEditingModel {
    func getUser() {
        guard let user = ENUser.getMainUser() else {return}
        self.presenter?.userReceived(user)
    }
    
    func updateUser(_ user: UserEdited) {
        guard self.validateUser(user) else {return}
        self.presenter?.loadingStarted()
        let _ = Router.User.editUser(user: user).request().responseObject { (response: DataResponse<RTUserResponse>) in
            switch response.result {
            case .success(let value):
                self.presenter?.loadingFinished()
                guard let user = value.user else {return}
                do {
                    let realm = try Realm()
                    try realm.write({
                        realm.add(user, update: true)
                    })
                }
                catch let error {
                    Logger.error(error)
                }
                Logger.debug(value.user)
            case .failure(let error):
                self.presenter?.loadingFailed(error as! RTError)
                Logger.error(error)
            }
        }
    }
    
    func validateUser(_ user: UserEdited) -> Bool {
        var areFieldsValid = true
        for type in UserEditedValidationField.allCases {
            self.presenter?.updateInvalidView(type, value: user.isValid(type))
            areFieldsValid = areFieldsValid && user.isValid(type)
        }
        return areFieldsValid
    }
}

extension ProfileEditingModel: MVPModel {
    typealias PresenterProtocol = IProfileEditingPresenterModel
}
