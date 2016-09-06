//
//  File.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 18.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation
import ObjectMapper

class User: Object, IUser {
    dynamic var id: Int = 0
    dynamic var firstName: String = ""
    dynamic var lastName: String = ""
    dynamic var email: String = ""
    dynamic var phoneNumber: String = ""
    
    var token: String? {
        get {
            guard let ssToken = SAMKeychain.passwordForService(FSKeychainKey.APIToken, account: FSKeychainKey.AccountName) else {return self._token}
            return ssToken
        }
        set(newToken) {
            if newToken == nil {
                self._token = nil
                SAMKeychain.deletePasswordForService(FSKeychainKey.APIToken, account: FSKeychainKey.AccountName)
            } else {
                self._token = newToken
                SAMKeychain.setPassword(newToken, forService: FSKeychainKey.APIToken, account: FSKeychainKey.AccountName)
            }
        }
    }
    var _token: String?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init?(_ map: ObjectMapper.Map) {
        guard let _ = map.JSONDictionary["id"] as? Int else {return nil}
        self.init()
    }
    
    func getRegistrationUser() -> RegistrationUser {
        var user = RegistrationUser()
        user.firstName.content = self.firstName
        user.lastName.content = self.lastName
        user.email.content = self.email
        user.phone.content = self.phoneNumber
        return user
    }
}

extension User: Mappable {
    func mapping(map: ObjectMapper.Map) {
        self.id     <- map["id"]
        self.firstName <- map["first_name"]
        self.lastName <- map["last_name"]
        self.email   <- map["email"]
        self.phoneNumber <- map["phone_number"]
        self.token <- map["authentication_token"]
    }
}

protocol IUser {
    var id: Int {get}
    var email: String {get}
}