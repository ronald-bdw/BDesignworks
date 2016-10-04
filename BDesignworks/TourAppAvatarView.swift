//
//  TourAppAvatarView.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 04/10/2016.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

typealias TourAppAvatarMVP = MVPContainer<TourAppAvatarView, TourAppAvatarPresenter, TourAppAvatarModel>

protocol ITourAppAvatarView: class {
    
}

class TourAppAvatarView: UIViewController {
    var presenter: ITourAppAvatarPresenterView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = TourAppAvatarMVP(controller: self)
    }
}

extension TourAppAvatarView: ITourAppAvatarView {
    
}

extension TourAppAvatarView: MVPView {
    typealias PresenterProtocol = ITourAppAvatarPresenterView
}
