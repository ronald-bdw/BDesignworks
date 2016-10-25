//
//  RegistrationModel.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 18.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol IRegistrationModel {
    func register(smsCode: String)
    func receivePhoneCode()
    func getRegistrationUser() -> RegistrationUser
    func updateRegistrationUser(type: RegistrationCellType, text: String)
}

class RegistrationModel {
    var user: RegistrationUser
    var authData: AuthInfo?
    
    weak var presenter: PresenterProtocol?
    
    required init() {
        let realm = try? Realm()
        if let rUser = realm?.objects(ENUser.self).first {
            self.user = rUser.getRegistrationUser()
        }
        else {
            self.user = RegistrationUser()
        }
        
        self.authData = realm?.objects(AuthInfo.self).first
    }
    
    fileprivate func startRegister(smsCode: String) {
        guard let lAuthData = self.authData else {return}
        self.presenter?.updateValidationErrors()
        guard self.validateUser(user) else {return}
        self.presenter?.loadingStarted()
        let _ = Router.User.register(firstName: self.user.firstName.content, lastname: self.user.lastName.content, email: self.user.email.content, phone: lAuthData.phone ,authPhoneCode: lAuthData.id, smsCode: smsCode).request().responseObject { [weak self] (response: DataResponse<RTUserResponse>) in
            
            switch response.result {
            case .success(let value):
                guard let lUser = value.user else {self?.presenter?.requestFailed(nil); return}
                
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
    
    func receivePhoneCode() {
        guard let lAuthData = self.authData else {return}
        self.presenter?.updateValidationErrors()
        guard self.validateUser(self.user) else {return}
        self.saveUser(self.user)
        self.presenter?.loadingStarted()
        let _ = Router.User.getAuthPhoneCode(phone: lAuthData.phone).request().responseObject { [weak self] (response: DataResponse<RTAuthInfoResponse>) in
            switch response.result {
            case .success(let value):
                guard let lAuthInfo = value.authInfo else {self?.presenter?.requestFailed(nil); return}
                
                guard lAuthInfo.isRegistered == false else {self?.presenter?.requestFailed(RTError(backend: .phoneTaken)); return}
                
                lAuthInfo.phone = self?.authData?.phone ?? ""
                
                self?.authData = lAuthInfo
                
                do {
                    let realm = try Realm()
                    try realm.write({
                        realm.delete(realm.objects(AuthInfo.self))
                        realm.add(lAuthInfo)
                    })
                    
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
        for field in self.user.allFields() {
            isValid = isValid && field.isValid
        }
        return isValid
    }
}

extension RegistrationModel: IRegistrationModel {
    func register(smsCode: String) {
        self.startRegister(smsCode: smsCode)
    }
    
    func getRegistrationUser() -> RegistrationUser {
        return self.user
    }
    
    func updateRegistrationUser(type: RegistrationCellType, text: String) {
        self.user.updateField(type: type, text: text)
    }
    
    func saveUser(_ user: RegistrationUser) {
        do {
            let realm = try Realm()
            let rUser = ENUser()
            rUser.firstName = self.user.firstName.content
            rUser.lastName = self.user.lastName.content
            rUser.email = self.user.email.content
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
