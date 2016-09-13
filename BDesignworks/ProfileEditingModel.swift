//
//  ProfileEditingModel.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 13.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol IProfileEditingModel {
    
}

class ProfileEditingModel {
    weak var presenter: PresenterProtocol?
    
    required init() {}
}

extension ProfileEditingModel: MVPModel {
    typealias PresenterProtocol = IProfileEditingPresenterModel
}