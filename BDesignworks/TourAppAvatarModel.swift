//
//  TourAppAvatarModel.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 04/10/2016.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol ITourAppAvatarModel {
    func getUser() -> ENUser?
    func sendAvatar(image: UIImage)
}

class TourAppAvatarModel {
    weak var presenter: ITourAppAvatarPresenterModel?
    
    required init() {}
}

extension TourAppAvatarModel: ITourAppAvatarModel {
    func getUser() -> ENUser? {
        return ENUser.getMainUser()
    }
    
    func sendAvatar(image: UIImage) {
        guard let user = ENUser.getMainUser() else {self.presenter?.loadingFailed(RTError(backend: BackendError.notAuthorized)); return}
        self.presenter?.loadingStarted()
        Router.User.sendAvatar(id: user.id, image: image).upload(completion: { uploadRequest, error in
            guard let uploadRequest = uploadRequest else {
                self.presenter?.loadingFailed(RTError(error: error))
                return
            }
            let _ = uploadRequest.responseObject { (response: DataResponse<RTUserResponse>) in
                switch response.result {
                case .success(let value):
                    guard let user = value.user else {self.presenter?.loadingFailed(); return}
                    do {
                        let realm = try Realm()
                        try realm.write({
                            realm.add(user, update: true)
                        })
                        self.presenter?.loadingFinished(user: user)
                    }
                    catch let error {
                        Logger.error(error)
                        self.presenter?.loadingFailed()
                    }
                case .failure(let error):
                    self.presenter?.loadingFailed(error as! RTError)
                }
            }
            
        })
    }
}

extension TourAppAvatarModel: MVPModel {
    typealias PresenterProtocol = ITourAppAvatarPresenterModel
}
