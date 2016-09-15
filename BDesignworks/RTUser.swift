//
//  RTUser.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 18.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation
import ObjectMapper

extension Router {
    enum User {
        case GetAuthPhoneCode(phone: String)
        case Register(firstName: String, lastname: String, email: String, phone: String, authPhoneCode: Int, smsCode: String)
        case SignIn(phone: String, authPhoneCode: Int, smsCode: String)
        case GetUser
        case EditUser(user: UserEdited)
    }
}

extension Router.User: RouterProtocol {
    var settings: RTRequestSettings {
        switch self {
        case .GetAuthPhoneCode(_)   :return RTRequestSettings(method: .POST, encoding: .URL)
        case .GetUser               :return RTRequestSettings(method: .GET)
        case .EditUser(_)           :return RTRequestSettings(method: .PUT)
        default                     :return RTRequestSettings(method: .POST)
        }
    }
    
    var path: String {
        switch self {
        case .GetAuthPhoneCode(_)   : return "/auth_phone_codes"
        case .Register              : return "/users"
        case .SignIn                : return "/users/sign_in"
        case .GetUser               : return "/users/account"
        case .EditUser(let user)    : return "/users/\(user.id)"
        }
    }
    
    var parameters: [String : AnyObject]? {
        switch self {
        case .GetAuthPhoneCode(let phone):  return ["phone_number": phone]
        case .Register(let firstName, let lastname, let email, let phone, let authPhoneCode, let smsCode):
            return ["first_name" : firstName,
                    "last_name" : lastname,
                    "email" : email,
                    "phone_number" : phone,
                    "auth_phone_code_id" : authPhoneCode,
                    "sms_code": smsCode]
        case .SignIn(let phone, let authPhoneCode, let smsCode):
            return ["phone_number": phone,
                    "auth_phone_code_id" : authPhoneCode,
                    "sms_code" : smsCode]
        case .EditUser(let user):
            var params :[String: String] = [:]
            params.updateIfNotDefault(user.firstName, forKey: "first_name", defaultValue: "")
            params.updateIfNotDefault(user.lastName, forKey: "last_name", defaultValue: "")
            params.updateIfNotDefault(user.email, forKey: "email", defaultValue: "")
            params.updateIfNotDefault(user.avatar, forKey: "avatar", defaultValue: "")
            return params
        case .GetUser:
            return nil
        }
    }
}

class RTUserResponse: Mappable {
    var user: User?
    var error: ValidationError?
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        self.user <- map["user"]
    }
}

class RTAuthInfoResponse: Mappable {
    var authInfo: AuthInfo?
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        self.authInfo <- map["auth_phone_code"]
    }
}
