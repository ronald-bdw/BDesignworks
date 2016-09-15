//
//  SidebarPresenter.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 15.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol ISidebarPresenterModel: class {
    
}

protocol ISidebarPresenterView {
    
}


class SidebarPresenter {
    weak var view: ViewProtocol?
    var model: ModelProtocol?
    
    required init() {}
}

extension SidebarPresenter: ISidebarPresenterModel {
    
}

extension SidebarPresenter: ISidebarPresenterView {
    
}

extension SidebarPresenter: MVPPresenter {
    typealias ViewProtocol = ISidebarView
    typealias ModelProtocol = ISidebarModel
}