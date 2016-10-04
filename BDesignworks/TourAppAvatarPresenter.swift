//
//  TourAppAvatarPresenter.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 04/10/2016.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol ITourAppAvatarPresenterView {
    func imageReceived(image: UIImage)
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
    func imageReceived(image: UIImage) {
        self.model?.sendAvatar(image: image)
    }
}

extension TourAppAvatarPresenter: ITourAppAvatarPresenterModel {
    func loadingStarted() {
        self.view?.setLoadingState(.loading)
    }
    
    func loadingFinished(user: ENUser) {
        guard let url = URL(string: user.avatarUrl) else {
            self.view?.setLoadingState(.failed)
            self.view?.showErrorView()
            return
        }
        self.view?.setLoadingState(.done)
        self.view?.updateView(avatarURL: url)
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
