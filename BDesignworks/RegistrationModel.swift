//
//  RegistrationModel.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 18.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol IRegistrationModel {
    func register(user: RegistrationUser)
    func receivePhoneCode()
    func getRegistrationUser() -> RegistrationUser
}

class RegistrationModel {
    var user: User?
    
    weak var presenter: PresenterProtocol?
    
    required init() {}
    
    private func startRegister(user: RegistrationUser) {
        guard self.validateUser(user) else {self.presenter?.userNotValid(); return}
        self.presenter?.registrationStarted()
        do {
            let realm = try Realm()
            //TODO: add error when there is no auth data
            guard let authData = realm.objects(AuthInfo).first else {return}
            
            Router.User.Register(firstName: user.firstName.content, lastname: user.lastName.content, email: user.email.content, phone: user.phone.content, authPhoneCode: authData.id, smsCode: "1234").request().responseObject { [weak self] (response: Response<RTUserResponse, RTError>) in
                var user: User?
                
                defer {
                    self?.user = user
                }
                
                switch response.result {
                case .Success(let value):
                    guard let lUser = value.user else {self?.presenter?.requestFailed();return}
                    user = lUser
                    
                    do {
                        let realm = try Realm()
                        try realm.write({
                            realm.delete(realm.objects(User))
                            realm.add(lUser)
                        })
                        
                    } catch let error {
                        Logger.error("\(error)")
                        self?.presenter?.requestFailed();
                    }
                    self?.presenter?.registrationSuccessed()
                case .Failure(let error):
                    Logger.error("\(error)")
                    self?.presenter?.requestFailed(error)
                }
            }
        } catch let error {
            Logger.error("\(error)")
            self.presenter?.requestFailed()
        }
    }
    
    func receivePhoneCode() {
        do {
            let realm = try Realm()
            //TODO: add error when there is no auth data
            guard let authData = realm.objects(AuthInfo).first else {return}
            
            Router.User.GetAuthPhoneCode(phone: authData.phone).request().responseObject { [weak self] (response: Response<RTAuthInfoResponse, RTError>) in
                var receivedData: AuthInfo?
                
                defer {
                    self?.presenter?.phoneCodeReceived()
                }
                
                switch response.result {
                case .Success(let value):
                    guard let lAuthInfo = value.authInfo else {self?.presenter?.requestFailed();return}
                    lAuthInfo.phone = authData.phone
                    
                    receivedData = lAuthInfo
                    
                    do {
                        let realm = try Realm()
                        try realm.write({
                            realm.delete(realm.objects(AuthInfo))
                            realm.add(lAuthInfo)
                        })
                        
                    } catch let error {
                        Logger.error("\(error)")
                        self?.presenter?.requestFailed()
                    }
                case .Failure(let error):
                    Logger.error("\(error)")
                    self?.presenter?.requestFailed()
                }
            }
        } catch let error {
            Logger.error("\(error)")
            self.presenter?.requestFailed()
        }
    }
    
    func validateUser(user: RegistrationUser) -> Bool {
        var isValid = true
        for field in user.allFields() {
            isValid = isValid && field.isValid
        }
        return isValid
    }
}

extension RegistrationModel: IRegistrationModel {
    func register(user: RegistrationUser) {
        self.startRegister(user)
    }
    
    func getRegistrationUser() -> RegistrationUser {
        var user = RegistrationUser()
        do {
            let realm = try Realm()
            guard let phone = realm.objects(AuthInfo).first?.phone else {return user}
            user.phone.content = phone
        } catch let error {
            Logger.error("\(error)")
        }
        return user
    }
}

extension RegistrationModel: MVPModel {
    typealias PresenterProtocol = IRegistrationPresenter
}