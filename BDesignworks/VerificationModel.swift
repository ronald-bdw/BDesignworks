//
//  VerificationModel.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 18.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

class VerificationModel {
    
    var user: User?
    
    private func receivePhoneCode(phone: String) {
        Router.User.GetAuthPhoneCode(phone: phone).request().responseObject { [weak self] (response: Response<RTUserResponse, RTError>) in
            var receivedData: User?
            
            defer {
                self?.user = receivedData
            }
            
            switch response.result {
            case .Success(let value):
                guard let user = value.user else {return}
                receivedData = user
                
                do {
                    let realm = try Realm()
                    try realm.write({
                        realm.add(user, update: true)
                    })
                    
                } catch let error {
                    Logger.error("\(error)")
                }
            case .Failure(let error):
                Logger.error("\(error)")
            }
        }
    }
}