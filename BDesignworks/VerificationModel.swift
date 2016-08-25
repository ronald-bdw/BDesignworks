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
}

class VerificationModel {
    
    weak var presenter: PresenterProtocol?
    
    var authInfo: AuthInfo?
    
    required init() {}
    
    private func receivePhoneCode(phone: String) {
        guard self.isPhoneValid(phone) else {self.presenter?.phoneNotValid(); return}
        
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
    
    private func isPhoneValid(phone: String) -> Bool {
        return phone.fs_length == 11
    }
}

extension VerificationModel: IVerificationModel {
    func submitPhone(phone: String) {
        self.receivePhoneCode(phone)
    }
}

extension VerificationModel: MVPModel {
    typealias PresenterProtocol = IVerificationPresenter
}