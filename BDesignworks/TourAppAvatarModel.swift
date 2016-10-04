//
//  TourAppAvatarModel.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 04/10/2016.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol ITourAppAvatarModel {
 
}

class TourAppAvatarModel {
    weak var presenter: ITourAppAvatarPresenterModel?
    
    required init() {}
}

extension TourAppAvatarModel: ITourAppAvatarModel {
    
}

extension TourAppAvatarModel: MVPModel {
    typealias PresenterProtocol = ITourAppAvatarPresenterModel
}
