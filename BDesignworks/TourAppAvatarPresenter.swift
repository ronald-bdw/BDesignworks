//
//  TourAppAvatarPresenter.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 04/10/2016.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol ITourAppAvatarPresenterView {
    func viewLoaded()
    func imageReceived(image: UIImage)
    func submitPressed()
}

protocol ITourAppAvatarPresenterModel: class {
    func loadingStarted()
    func loadingFinished(user: ENUser)
    func loadingFailed(_ error: RTError)
    func loadingFailed()
}

class TourAppAvatarPresenter {
    weak var view: ITourAppAvatarView?
    var model: ITourAppAvatarModel?
    
    required init() {}
}

extension TourAppAvatarPresenter: ITourAppAvatarPresenterView {
    func viewLoaded() {
        guard let user = self.model?.getUser(),
            let avatarUrl = URL(string: user.avatarThumbUrl) else {return}
        self.view?.updateView(avatarURL: avatarUrl)
        
        if user.isSubscriber == true {
            self.view?.updateView(title: "Step 2 of 3")
        }
        else {
            self.view?.updateView(title: "Step 2 of 2")
        }
    }
    
    func imageReceived(image: UIImage) {
        self.model?.sendAvatar(image: image)
    }
    
    func submitPressed() {
        guard let user = self.model?.getUser() else {return}
        
        if user.isSubscriber == true {
            self.view?.showPurchasesView()
        }
        else {
            self.view?.showConversationView()
        }
    }
}

extension TourAppAvatarPresenter: ITourAppAvatarPresenterModel {
    func loadingStarted() {
        self.view?.setLoadingState(.loading)
    }
    
    func loadingFinished(user: ENUser) {
        guard let _ = URL(string: user.avatarThumbUrl) else {
            self.view?.setLoadingState(.failed)
            self.view?.showErrorView()
            return
        }
        self.view?.setLoadingState(.done)
    }
    
    func loadingFailed(_ error: RTError) {
        self.view?.setLoadingState(.failed)
        if case let .backend(backendError) = error {
            self.view?.showBackendErrorView(backendError.humanDescription)
        }
        else {
            self.view?.showErrorView()
        }
    }
    
    func loadingFailed() {
        self.view?.setLoadingState(.failed)
        self.view?.showErrorView()
    }
}

extension TourAppAvatarPresenter: MVPPresenter {
    typealias ViewProtocol = ITourAppAvatarView
    typealias ModelProtocol = ITourAppAvatarModel
}
