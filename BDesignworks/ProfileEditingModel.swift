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
    func updateUser(user: UserEdited)
}

class ProfileEditingModel {
    weak var presenter: PresenterProtocol?
    
    required init() {}
}

extension ProfileEditingModel: IProfileEditingModel {
    func getUser() {
        guard let user = User.getMainUser() else {return}
        self.presenter?.userReceived(user)
    }
    
    func updateUser(user: UserEdited) {
        guard self.validateUser(user) else {return}
        self.presenter?.loadingStarted()
        Router.User.EditUser(user: user).request().responseObject { (response: Response<RTUserResponse,RTError>) in
            switch response.result {
            case .Success(let value):
                self.presenter?.loadingFinished()
                Logger.debug(value.user)
            case .Failure(let error):
                self.presenter?.loadingFailed()
                Logger.error(error)
            }
        }
    }
    
    func validateUser(user: UserEdited) -> Bool {
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