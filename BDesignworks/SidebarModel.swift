//
//  SidebarModel.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 15.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation


protocol ISidebarModel {
    
}

class SidebarModel {
    weak var presenter: PresenterProtocol?
    
    required init() {}
}

extension SidebarModel: ISidebarModel {
    
}

extension SidebarModel: MVPModel {
    typealias PresenterProtocol = ISidebarPresenterModel
}