//
//  LoginModel.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 18.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol ILoginModel {
    func login(smsCode: String)
}

class LoginModel {
    var user: User?
    
    weak var presenter: ILoginPresenter?
    
    required init() {}
    
    private func startLogin(smsCode: String) {
        self.presenter?.loginStarted()
        do {
            let realm = try Realm()
            //TODO: add error when there is no auth data
            guard let authData = realm.objects(AuthInfo).first else {return}
            
            Router.User.SignIn(phone: authData.phone, authPhoneCode: authData.id, smsCode: smsCode).request().responseObject { [weak self] (response: Response<RTUserResponse, RTError>) in
                var receivedData: User?
                
                defer {
                    self?.user = receivedData
                    self?.presenter?.loginSuccessed()
                }
                
                switch response.result {
                case .Success(let value):
                    guard let user = value.user else {return}
                    receivedData = user
                    
                    do {
                        try realm.write({
                            realm.add(user, update: true)
                            realm.delete(realm.objects(AuthInfo))
                        })
                        
                    } catch let error {
                        Logger.error("\(error)")
                    }
                case .Failure(let error):
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
    func login(smsCode: String) {
        self.startLogin(smsCode)
    }
}

extension LoginModel: MVPModel {
    typealias PresenterProtocol = ILoginPresenter
}