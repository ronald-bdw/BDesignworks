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
    dynamic var email: String = ""
    dynamic var phoneNumber: String = ""
    dynamic var authCode: Int = 0
    dynamic var isRegistered: Bool = false
    
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
}

extension User: Mappable {
    func mapping(map: ObjectMapper.Map) {
        self.id     <- map["user"]["id"]
        self.email   <- map["user"]["email"]
        self.phoneNumber <- map["user"]["phone_number"]
        self.token <- map["user"]["authentication_token"]
        
        self.authCode  <- map["auth_phone_code"]["id"]
        self.isRegistered  <- map["auth_phone_code"]["phone_registered"]
    }
}

protocol IUser {
    var id: Int {get}
    var email: String {get}
    var authCode: Int {get}
    var isRegistered: Bool {get}
}