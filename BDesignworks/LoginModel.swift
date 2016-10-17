//
//  LoginModel.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 18.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol ILoginModel {
    func login(_ smsCode: String)
    func resendSmsCode()
}

class LoginModel {
    var user: ENUser?
    
    weak var presenter: PresenterProtocol?
    
    required init() {}
    
    fileprivate func startLogin(_ smsCode: String) {
        self.presenter?.loadingStarted()
        do {
            let realm = try Realm()
            //TODO: add error when there is no auth data
            guard let authData = realm.objects(AuthInfo.self).first else {return}
            
            let _ = Router.User.signIn(phone: authData.phone, authPhoneCode: authData.id, smsCode: smsCode).request().responseObject { [weak self] (response: DataResponse<RTUserResponse>) in
                var receivedData: ENUser?
                
                defer {
                    self?.user = receivedData
                }
                
                switch response.result {
                case .success(let value):
                    guard let user = value.user else {self?.presenter?.loadingFailed(error: nil); return}
                    receivedData = user
                    
                    do {
                        try realm.write({
                            realm.delete(realm.objects(ENUser.self))
                            realm.add(user, update: true)
                            realm.delete(realm.objects(AuthInfo.self))
                        })
                        self?.presenter?.loginSuccessed(user: user)
                    } catch let error {
                        Logger.error("\(error)")
                        self?.presenter?.loadingFailed(error: error)
                    }
                case .failure(let error):
                    self?.presenter?.loadingFailed(error: error)
                    Logger.error("\(error)")
                }
            }
            
        } catch let error {
            Logger.error("\(error)")
        }

    }

}

extension LoginModel: ILoginModel {
    func login(_ smsCode: String) {
        self.startLogin(smsCode)
    }
    
    func resendSmsCode() {
        guard let authInfo = AuthInfo.getMainAuthInfo() else {return}
        self.presenter?.loadingStarted()
        
        let _ = Router.User.getAuthPhoneCode(phone: authInfo.phone).request().responseObject { [weak self] (response: DataResponse<RTAuthInfoResponse>) in
            
            switch response.result {
            case .success(let value):
                guard let lAuthInfo = value.authInfo else {self?.presenter?.loadingFailed(error: nil); return}
                
                do {
                    let realm = try Realm()
                    try realm.write({
                        realm.delete(realm.objects(AuthInfo.self))
                        realm.delete(realm.objects(ENUser.self))
                        realm.add(lAuthInfo)
                    })
                    self?.presenter?.phoneCodeSent()
                    
                } catch let error {
                    Logger.error("\(error)")
                    self?.presenter?.loadingFailed(error: error)
                }
            case .failure(let error):
                Logger.error("\(error)")
                self?.presenter?.loadingFailed(error: error)
            }
        }
    }
}

extension LoginModel: MVPModel {
    typealias PresenterProtocol = ILoginModelPresenter
}
