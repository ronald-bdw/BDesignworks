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
}

class LoginModel {
    var user: ENUser?
    
    weak var presenter: PresenterProtocol?
    
    required init() {}
    
    fileprivate func startLogin(_ smsCode: String) {
        self.presenter?.loginStarted()
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
                    guard let user = value.user else {return}
                    receivedData = user
                    
                    do {
                        try realm.write({
                            realm.delete(realm.objects(ENUser.self))
                            realm.add(user, update: true)
                            realm.delete(realm.objects(AuthInfo.self))
                        })
                        
                    } catch let error {
                        Logger.error("\(error)")
                    }
                    self?.presenter?.loginSuccessed()
                case .failure(let error):
                    self?.presenter?.loginFailed()
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
}

extension LoginModel: MVPModel {
    typealias PresenterProtocol = ILoginModelPresenter
}
