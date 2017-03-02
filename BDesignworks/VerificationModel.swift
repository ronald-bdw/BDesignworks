//
//  VerificationModel.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 18.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol IVerificationModel {
    func submitPhone(_ phone: String)
    func validatePhone(_ phone: String) -> Bool
    func validateCode(_ code: String) -> Bool
    func checkUserStatus(phone: String)
}

class VerificationModel {
    
    weak var presenter: PresenterProtocol?
    
    var authInfo: AuthInfo?
    
    required init() {}
    
    func receivePhoneCode(_ phone: String) {
        self.presenter?.loadingStarted()
        
        let _ = Router.User.getAuthPhoneCode(phone: phone).request().responseObject { [weak self] (response: DataResponse<RTAuthInfoResponse>) in
            var receivedData: AuthInfo?
            
            defer {
                self?.authInfo = receivedData
            }
            
            switch response.result {
            case .success(let value):
                guard let lAuthInfo = value.authInfo else {self?.presenter?.errorOccured(error: nil); return}
                lAuthInfo.phone = phone
                
                receivedData = lAuthInfo
                
                do {
                    let realm = try Realm()
                    try realm.write({
                        realm.delete(realm.objects(AuthInfo.self))
                        realm.delete(realm.objects(ENUser.self))
                        realm.add(lAuthInfo)
                    })
                    self?.presenter?.phoneCodeReceived()
                    
                } catch let error {
                    Logger.error("\(error)")
                    self?.presenter?.errorOccured(error: nil)
                }
            case .failure(let error):
                Logger.error("\(error)")
                self?.presenter?.errorOccured(error: error as? RTError)
            }
        }
    }
    
    func checkUserStatus(phone: String) {
        self.presenter?.loadingStarted()
        
        let _ = Router.User.checkUserStatus(phone: phone).request().responseObject { [weak self] (response: DataResponse<RTUserStatusResponse>) in
            switch response.result {
            case .success(let value):
                let shouldCheckProvider = UserDefaults.standard.bool(forKey: FSUserDefaultsKey.ShouldCheckProvider)
                let registrationValue = UserDefaults.standard.bool(forKey: FSUserDefaultsKey.RegistrationValue)
                let chosenProvider = UserDefaults.standard.string(forKey: FSUserDefaultsKey.ChosenProvider)
                if shouldCheckProvider {
                    if value.provider == "" || value.isSubscriber == true {
                        self?.presenter?.userHasNoProvider()
                        return
                    }
                    else if value.provider != chosenProvider {
                        self?.presenter?.wrongProviderSelected()
                        return
                    }
                }
                if registrationValue == value.isRegistered {
                    self?.receivePhoneCode(phone)
                } else if value.isRegistered {
                    self?.presenter?.userAlreadyRegistered(withProvider: (value.provider != "" || value.isSubscriber == false))
                } else {
                    self?.presenter?.userNotRegistered()
                }
            case .failure(let error):
                Logger.error("\(error)")
                self?.presenter?.errorOccured(error: error as? RTError)
                
            }
        }
    }
}

extension VerificationModel: IVerificationModel {
    func submitPhone(_ phone: String) {
        self.receivePhoneCode(phone)
    }
    
    func validatePhone(_ phone: String) -> Bool {
        if phone.fs_length < 5 || phone.fs_length > 15{
            self.presenter?.phoneNotValid()
            return false
        }
        self.presenter?.phoneValid()
        return true
    }
    
    func validateCode(_ code: String) -> Bool {
        if code.substring(to: code.characters.index(code.startIndex, offsetBy: 1)) != "+" {
            self.presenter?.codeNotValid()
            return false
        }
        self.presenter?.codeValid()
        return true
    }
}

extension VerificationModel: MVPModel {
    typealias PresenterProtocol = IVerificationModelPresenter
}
