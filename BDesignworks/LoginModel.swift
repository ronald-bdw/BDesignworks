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
    var authData: AuthInfo?
    
    var task: DataRequest? {
        willSet {
            self.task?.cancel()
        }
    }
    
    weak var presenter: PresenterProtocol?
    
    required init() {
        self.authData = BDRealm?.objects(AuthInfo.self).first
    }
    
    fileprivate func startLogin(_ smsCode: String) {
        self.presenter?.loadingStarted()
        guard let lAuthInfo = self.authData else {
            Crashlytics.sharedInstance().recordError(LoginErrors.authDataNotFound.error)
            self.presenter?.loadingFailed(error: nil); return}
        self.task = Router.User.signIn(phone: lAuthInfo.phone, authPhoneCode: lAuthInfo.id, smsCode: smsCode).request().responseObject { [weak self] (response: DataResponse<RTUserResponse>) in
            var receivedData: ENUser?
            
            defer {
                self?.user = receivedData
            }
            
            switch response.result {
            case .success(let value):
                guard let user = value.user else {
                    Crashlytics.sharedInstance().recordError(LoginErrors.userNotMapped.error)
                    self?.presenter?.loadingFailed(error: nil); return}
                receivedData = user
                
                do {
                    guard let realm = BDRealm else {
                        Crashlytics.sharedInstance().recordError(LoginErrors.cannotInitDB.error)
                        self?.presenter?.loadingFailed(error: nil); return}
                    try realm.write({
                        realm.delete(realm.objects(ENUser.self))
                        realm.add(user, update: true)
                        realm.delete(realm.objects(AuthInfo.self))
                        
                        UserDefaults.standard.removeObject(forKey: FSUserDefaultsKey.SmsCode)
                        UserDefaults.standard.synchronize()
                    })
                    self?.presenter?.loginSuccessed(user: user)
                } catch let error {
                    Logger.error("\(error)")
                    Crashlytics.sharedInstance().recordError(error)
                    self?.presenter?.loadingFailed(error: error)
                }
            case .failure(let error):
                Crashlytics.sharedInstance().recordError(error)
                self?.presenter?.loadingFailed(error: error)
                Logger.error("\(error)")
            }
        }

    }

}

extension LoginModel: ILoginModel {
    func login(_ smsCode: String) {
        self.startLogin(smsCode)
    }
    
    func resendSmsCode() {
        guard let authInfo = self.authData else {return}
        self.presenter?.loadingStarted()
        
        let _ = Router.User.getAuthPhoneCode(phone: authInfo.phone).request().responseObject { [weak self] (response: DataResponse<RTAuthInfoResponse>) in
            
            switch response.result {
            case .success(let value):
                guard let lAuthInfo = value.authInfo else {self?.presenter?.loadingFailed(error: nil); return}
                lAuthInfo.phone = authInfo.phone
                
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
