//
//  RegistrationModel.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 18.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol IRegistrationModel {
    func register(firstName: String, lastName: String, email: String, phone: String)
}

class RegistrationModel {
    var user: User?
    
    weak var presenter: IRegistrationPresenter?
    
    required init() {}
    
    private func startRegister(firstName: String, lastName: String, email: String, phone: String) {
        self.presenter?.registrationStarted()
        do {
            let realm = try Realm()
            //TODO: add error when there is no auth data
            guard let authData = realm.objects(AuthInfo).first else {return}
            
            Router.User.Register(firstName: firstName, lastname: lastName, email: email, phone: phone, authPhoneCode: authData.id, smsCode: "1234").request().responseObject { [weak self] (response: Response<RTUserResponse, RTError>) in
                var user: User?
                
                defer {
                    self?.user = user
                }
                
                switch response.result {
                case .Success(let value):
                    guard let lUser = value.user else {return}
                    user = lUser
                    
                    do {
                        let realm = try Realm()
                        try realm.write({
                            realm.add(lUser)
                        })
                        
                    } catch let error {
                        Logger.error("\(error)")
                    }
                    self?.presenter?.registrationSuccessed()
                case .Failure(let error):
                    Logger.error("\(error)")
                    self?.presenter?.registrationFailed()
                }
            }
        } catch let error {
            Logger.error("\(error)")
            self.presenter?.registrationFailed()
        }
        
    }
}

extension RegistrationModel: IRegistrationModel {
    func register(firstName: String, lastName: String, email: String, phone: String) {
        self.register(firstName, lastName: lastName, email: email, phone: phone)
    }
}

extension RegistrationModel: MVPModel {
    typealias PresenterProtocol = IRegistrationPresenter
}