//
//  RegistrationModel.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 18.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

class RegistrationModel {
    var user: User?
    
    private func register(firstName: String, lastName: String, email: String, phone: String, authPhoneCode: Int, smsCode: Int) {
        Router.User.Register(firstName: firstName, lastname: lastName, email: email, phone: phone, authPhoneCode: authPhoneCode, smsCode: smsCode).request().responseObject { [weak self] (response: Response<RTUserResponse, RTError>) in
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
            case .Failure(let error):
                Logger.error("\(error)")
            }
        }
    }
}