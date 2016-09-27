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
        if let user = ENUser.getMainUser() {
            self.presenter?.userReceived(user)
        }
    }
}

extension ProfileModel: MVPModel {
    typealias PresenterProtocol = IProfilePresenterModel
}
