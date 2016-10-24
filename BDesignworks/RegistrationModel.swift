//
//  RegistrationModel.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 18.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol IRegistrationModel {
    func register(_ user: RegistrationUser, authData: AuthInfo, smsCode: String)
    func receivePhoneCode(_ user: RegistrationUser)
    func getRegistrationUser() -> RegistrationUser
    func registerIfNeeded()
}

class RegistrationModel {
    var user: ENUser?
    
    weak var presenter: PresenterProtocol?
    
    required init() {}
    
    fileprivate func startRegister(_ user: RegistrationUser, authData: AuthInfo, smsCode: String) {
        self.presenter?.updateValidationErrors()
        guard self.validateUser(user) else {return}
        self.presenter?.loadingStarted()
        let _ = Router.User.register(firstName: user.firstName.content, lastname: user.lastName.content, email: user.email.content, phone: user.phone.content, authPhoneCode: authData.id, smsCode: smsCode).request().responseObject { [weak self] (response: DataResponse<RTUserResponse>) in
            var user: ENUser?
            
            defer {
                self?.user = user
            }
            
            switch response.result {
            case .success(let value):
                guard let lUser = value.user else {self?.presenter?.requestFailed(nil); return}
                user = lUser
                
                do {
                    let realm = try Realm()
                    try realm.write({
                        realm.delete(realm.objects(ENUser.self))
                        realm.delete(realm.objects(AuthInfo.self))
                        realm.add(lUser)
                        
                        UserDefaults.standard.removeObject(forKey: FSUserDefaultsKey.SmsCode)
                        UserDefaults.standard.synchronize()
                    })
                    self?.presenter?.loadingSuccessed(user: lUser)
                } catch let error {
                    Logger.error("\(error)")
                    self?.presenter?.requestFailed(error as? RTError);
                }
            case .failure(let error):
                Logger.error("\(error)")
                self?.presenter?.requestFailed( error as? RTError)
            }
        }
    }
    
    func receivePhoneCode(_ user: RegistrationUser) {
        self.presenter?.updateValidationErrors()
        guard self.validateUser(user) else {return}
        self.presenter?.loadingStarted()
        let _ = Router.User.getAuthPhoneCode(phone: user.phone.content).request().responseObject { [weak self] (response: DataResponse<RTAuthInfoResponse>) in
            
            switch response.result {
            case .success(let value):
                guard let lAuthInfo = value.authInfo else {self?.presenter?.requestFailed(nil); return}
                
                guard lAuthInfo.isRegistered == false else {self?.presenter?.requestFailed(RTError(backend: .phoneTaken)); return}
                lAuthInfo.phone = user.phone.content
                
                do {
                    let realm = try Realm()
                    try realm.write({
                        realm.delete(realm.objects(AuthInfo.self))
                        realm.add(lAuthInfo)
                    })
                    
                    self?.saveUser(user)
                    
                    self?.presenter?.phoneCodeReceived()
                    
                } catch let error {
                    Logger.error("\(error)")
                    self?.presenter?.requestFailed(nil)
                }
            case .failure(let error):
                Logger.error("\(error)")
                self?.presenter?.requestFailed(error as? RTError)
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
    func register(_ user: RegistrationUser, authData: AuthInfo, smsCode: String) {
        self.startRegister(user, authData: authData, smsCode: smsCode)
    }
    
    func registerIfNeeded() {
//        do {
//            let realm = try Realm()
//            guard let user = realm.objects(ENUser.self).first,
//                let authData = realm.objects(AuthInfo.self).first else {return}
//            self.startRegister(user.getRegistrationUser(), authData: authData)
//        } catch let error {
//            Logger.error("\(error)")
//        }
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
