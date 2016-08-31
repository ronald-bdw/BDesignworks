//
//  VerificationModel.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 18.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol IVerificationModel {
    func submitPhone(phone: String)
    func validatePhone(phone: String) -> Bool
    func validateCode(code: String) -> Bool
}

class VerificationModel {
    
    weak var presenter: PresenterProtocol?
    
    var authInfo: AuthInfo?
    
    required init() {}
    
    private func receivePhoneCode(phone: String) {
        self.presenter?.loadingStarted()
        
        Router.User.GetAuthPhoneCode(phone: phone).request().responseObject { [weak self] (response: Response<RTAuthInfoResponse, RTError>) in
            var receivedData: AuthInfo?
            
            defer {
                self?.authInfo = receivedData
            }
            
            switch response.result {
            case .Success(let value):
                guard let lAuthInfo = value.authInfo else {self?.presenter?.errorOccured(); return}
                lAuthInfo.phone = phone
                
                receivedData = lAuthInfo
                
                do {
                    let realm = try Realm()
                    try realm.write({
                        realm.delete(realm.objects(AuthInfo))
                        realm.delete(realm.objects(User))
                        realm.add(lAuthInfo)
                    })
                    self?.presenter?.phoneCodeReceived()
                    
                } catch let error {
                    Logger.error("\(error)")
                    self?.presenter?.errorOccured()
                }
            case .Failure(let error):
                Logger.error("\(error)")
                self?.presenter?.errorOccured()
            }
        }
    }
}

extension VerificationModel: IVerificationModel {
    func submitPhone(phone: String) {
        self.receivePhoneCode(phone)
    }
    
    func validatePhone(phone: String) -> Bool {
        if phone.fs_length != 10 {
            self.presenter?.phoneNotValid()
            return false
        }
        self.presenter?.phoneValid()
        return true
    }
    
    func validateCode(code: String) -> Bool {
        if code.substringToIndex(code.startIndex.advancedBy(1)) != "+" {
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