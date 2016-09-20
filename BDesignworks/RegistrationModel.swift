//
//  RegistrationModel.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 18.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol IRegistrationModel {
    func register(_ user: RegistrationUser)
    func receivePhoneCode(_ user: RegistrationUser?)
    func getRegistrationUser() -> RegistrationUser
    func registerIfNeeded()
}

class RegistrationModel {
    var user: ENUser?
    
    weak var presenter: PresenterProtocol?
    
    required init() {}
    
    fileprivate func startRegister(_ user: RegistrationUser) {
        guard self.validateUser(user) else {self.presenter?.updateValidationErrors(); return}
        self.presenter?.registrationStarted()
        do {
            let realm = try Realm()
            //TODO: add error when there is no auth data
            guard let authData = realm.objects(AuthInfo.self).first else {self.presenter?.requestFailed(RTError(backend: .smsCodeNotExist)); return}
            
            let _ = Router.User.register(firstName: user.firstName.content, lastname: user.lastName.content, email: user.email.content, phone: user.phone.content, authPhoneCode: authData.id, smsCode: "1234").request().responseObject { [weak self] (response: DataResponse<RTUserResponse>) in
                var user: ENUser?
                
                defer {
                    self?.user = user
                }
                
                switch response.result {
                case .success(let value):
                    guard let lUser = value.user else {self?.presenter?.requestFailed();return}
                    user = lUser
                    
                    do {
                        let realm = try Realm()
                        try realm.write({
                            realm.delete(realm.objects(ENUser.self))
                            realm.delete(realm.objects(AuthInfo.self))
                            realm.add(lUser)
                        })
                        
                    } catch let error {
                        Logger.error("\(error)")
                        self?.presenter?.requestFailed();
                    }
                    self?.presenter?.registrationSuccessed()
                case .failure(let error):
                    Logger.error("\(error)")
                    self?.presenter?.requestFailed( error as? RTError)
                }
            }
        } catch let error {
            Logger.error("\(error)")
            self.presenter?.requestFailed()
        }
    }
    
    func receivePhoneCode(_ user: RegistrationUser?) {
        guard let lUser = user else {self.presenter?.requestFailed(); return}
        
        let _ = Router.User.getAuthPhoneCode(phone: lUser.phone.content).request().responseObject { [weak self] (response: DataResponse<RTAuthInfoResponse>) in
            
            switch response.result {
            case .success(let value):
                guard let lAuthInfo = value.authInfo else {self?.presenter?.requestFailed();return}
                lAuthInfo.phone = lUser.phone.content
                
                do {
                    let realm = try Realm()
                    try realm.write({
                        realm.delete(realm.objects(AuthInfo.self))
                        realm.add(lAuthInfo)
                    })
                    
                    self?.saveUser(lUser)
                    
                    self?.presenter?.phoneCodeReceived()
                    
                } catch let error {
                    Logger.error("\(error)")
                    self?.presenter?.requestFailed()
                }
            case .failure(let error):
                Logger.error("\(error)")
                self?.presenter?.requestFailed()
            }
        }
    }
    
    func validateUser(_ user: RegistrationUser) -> Bool {
        var isValid = true
        for field in user.allFields() {
            isValid = isValid && field.isValid
        }
        return isValid
    }
}

extension RegistrationModel: IRegistrationModel {
    func register(_ user: RegistrationUser) {
        self.startRegister(user)
    }
    
    func registerIfNeeded() {
        do {
            let realm = try Realm()
            guard let user = realm.objects(ENUser.self).first else {return}
            self.startRegister(user.getRegistrationUser())
        } catch let error {
            Logger.error("\(error)")
        }
    }
    
    func getRegistrationUser() -> RegistrationUser {
        var user = RegistrationUser()
        do {
            let realm = try Realm()
            if let rUser = realm.objects(ENUser.self).first {
                user = rUser.getRegistrationUser()
            }
            else {
                guard let authData = realm.objects(AuthInfo.self).first else {return user}
                
                user.phone.content = authData.phone
            }
        } catch let error {
            Logger.error("\(error)")
        }
        return user
    }
    
    func saveUser(_ user: RegistrationUser) {
        do {
            let realm = try Realm()
            let rUser = ENUser()
            rUser.firstName = user.firstName.content
            rUser.lastName = user.lastName.content
            rUser.email = user.email.content
            rUser.phoneNumber = user.phone.content
            try realm.write({
                realm.delete(realm.objects(ENUser.self))
                realm.add(rUser)
            })
        } catch let error {
            Logger.error("\(error)")
        }
    }
}

extension RegistrationModel: MVPModel {
    typealias PresenterProtocol = IRegistrationModelPresenter
}
