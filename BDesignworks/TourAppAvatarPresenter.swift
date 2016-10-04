//
//  TourAppAvatarPresenter.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 04/10/2016.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol ITourAppAvatarPresenterView {
    
}

protocol ITourAppAvatarPresenterModel: class {
    
}

class TourAppAvatarPresenter {
    weak var view: ITourAppAvatarView?
    var model: ITourAppAvatarModel?
    
    required init() {}
}

extension TourAppAvatarPresenter: ITourAppAvatarPresenterView {
    
}

extension TourAppAvatarPresenter: ITourAppAvatarPresenterModel {
    
}

extension TourAppAvatarPresenter: MVPPresenter {
    typealias ViewProtocol = ITourAppAvatarView
    typealias ModelProtocol = ITourAppAvatarModel
}
