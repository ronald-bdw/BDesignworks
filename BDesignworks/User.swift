//
//  File.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 18.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation
import ObjectMapper

class ENUser: Object, IUser {
    dynamic var id: Int = 0
    dynamic var firstName: String = ""
    dynamic var lastName: String = "" 
    dynamic var email: String = ""
    dynamic var phoneNumber: String = ""
    dynamic var lastStepsHealthKitUpdateDate: Date?
    dynamic var avatarUrl: String = ""
    dynamic var avatarThumbUrl: String = ""
    dynamic var provider: String = ""
    
    var token: String? {
        get {
            guard let ssToken = SAMKeychain.password(forService: FSKeychainKey.APIToken, account: FSKeychainKey.AccountName) else {return self._token}
            return ssToken
        }
        set(newToken) {
            if newToken == nil {
                self._token = nil
                SAMKeychain.deletePassword(forService: FSKeychainKey.APIToken, account: FSKeychainKey.AccountName)
            } else {
                self._token = newToken
                SAMKeychain.setPassword(newToken, forService: FSKeychainKey.APIToken, account: FSKeychainKey.AccountName)
            }
        }
    }
    var _token: String?
    
    var fullname: String {
        return firstName + " " + lastName
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["token", "_token", "fullname"]
    }
    
    required convenience init?(map: ObjectMapper.Map) {
        guard let _ = map.JSON["id"] as? Int else {return nil}
        self.init()
    }
    
    func getRegistrationUser() -> RegistrationUser {
        var user = RegistrationUser()
        user.firstName.content = self.firstName
        user.lastName.content = self.lastName
        user.email.content = self.email
        return user
    }
    
    func getTourAppUser() -> TourAppUser {
        var user = TourAppUser()
        user.firstName.content = self.firstName
        user.lastName.content = self.lastName
        user.email.content = self.email
        return user
    }
    
    static func getMainUser() -> ENUser? {
        do {
            let realm = try Realm()
            return realm.objects(ENUser.self).first
        }
        catch let error {
            Logger.error("\(error)")
            return nil
        }
    }
    
    static func createTestUser() {
        do {
            let realm = try Realm()
            guard realm.objects(ENUser.self).count == 0 else {
                if let user = realm.objects(ENUser.self).first {
                    SmoochHelper.sharedInstance.startWithParameters(user)
                }
                return
            }
            let user = ENUser()
            user.id = 1//14
            user.firstName = "Ellina"
            user.lastName = "K"
            user.email = "ekd@t.t"
            user.phoneNumber = "+79377709988" // +79377709988
            user.token = "zvse9EpyymXBuQ5Zfx1g" //nxZsbQc3e_jVSbMDDsFS
            try realm.write({
                realm.add(user)
            })
            SmoochHelper.sharedInstance.startWithParameters(user)
        }
        catch let error {
            Logger.error("\(error)")
        }
    }
    
    static func logout() {
        FitbitManager.sharedInstance.removeFitBitTokenFromServer()
        guard let user = ENUser.getMainUser() else {return}
        user.token = nil
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(realm.objects(ENUser.self))
            }
            UIApplication.shared.applicationIconBadgeNumber = 0
//            Smooch.setPushToken(Data())
            Smooch.logout()
            HealthKitManager.sharedInstance.stopSendingData()
            UserDefaults.standard.removeObject(forKey: FSUserDefaultsKey.IsProviderChosen)
        }
        catch let error {
            Logger.error(error)
        }
    }
}

extension ENUser: Mappable {
    func mapping(map: ObjectMapper.Map) {
        self.id     <- map["id"]
        self.firstName <- map["first_name"]
        self.lastName <- map["last_name"]
        self.email   <- map["email"]
        self.phoneNumber <- map["phone_number"]
        self.token <- map["authentication_token"]
        var lastUpdateDate: String = ""
        lastUpdateDate <- map["last_healthkit_activity.started_at"]
        self.lastStepsHealthKitUpdateDate = Date.getDateFromISO8601(lastUpdateDate)
        self.avatarUrl <- map["avatar.original"]
        self.avatarThumbUrl <- map["avatar.thumb"]
        self.provider <- map["provider.name"]
    }
}

protocol IUser {
    var id: Int {get}
    var email: String {get}
}
