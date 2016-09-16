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
    dynamic var lastStepsHealthKitUpdateDate: NSDate?
    
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
    
    var fitbitToken: String? {
        get {
            guard let ssToken = SAMKeychain.passwordForService(FSKeychainKey.FitbitToken, account: FSKeychainKey.AccountName) else {return self._fitbitToken}
            return ssToken
        }
        set(newToken) {
            if newToken == nil {
                self._fitbitToken = nil
                SAMKeychain.deletePasswordForService(FSKeychainKey.FitbitToken, account: FSKeychainKey.AccountName)
            } else {
                self._fitbitToken = newToken
                SAMKeychain.setPassword(newToken, forService: FSKeychainKey.FitbitToken, account: FSKeychainKey.AccountName)
            }
        }
    }
    var _fitbitToken: String?
    
    var fullname: String {
        return firstName + " " + lastName
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["token", "_token", "fitbitToken", "_fitbitToken", "fullname"]
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
    
    static func getMainUser() -> User? {
        do {
            let realm = try Realm()
            return realm.objects(User).first
        }
        catch let error {
            Logger.error("\(error)")
            return nil
        }
    }
    
    static func createTestUser() {
        do {
            let realm = try Realm()
            let user = User()
            guard realm.objects(User).count == 0 else {return}
            user.id = 1
            user.firstName = "Ellina"
            user.lastName = "K"
            user.email = "ekd@t.t"
            user.phoneNumber = "+79377709988"
            user.token = "iYW5v84__UDNLYdnPjkj"
            try realm.write({
                realm.add(user)
            })
        }
        catch let error {
            Logger.error("\(error)")
        }
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