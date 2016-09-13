//
//  ProfileEditingPresenter.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 13.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol IProfileEditingPresenterModel: class {
    
}

protocol IProfileEditingPresenterView {
    
}

class ProfileEditingPresenter {
    weak var view: ViewProtocol?
    var model: ModelProtocol?
    
    required init() {}
}

extension ProfileEditingPresenter: MVPPresenter {
    typealias ViewProtocol = IProfileEditingView
    typealias ModelProtocol = IProfileEditingModel
}