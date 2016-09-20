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
        case getAuthPhoneCode(phone: String)
        case register(firstName: String, lastname: String, email: String, phone: String, authPhoneCode: Int, smsCode: String)
        case signIn(phone: String, authPhoneCode: Int, smsCode: String)
        case getUser
        case editUser(user: UserEdited)
    }
}

extension Router.User: RouterProtocol {

    var settings: RTRequestSettings {
        switch self {
        case .getAuthPhoneCode(_)   :return RTRequestSettings(method: .post, encoding: URLEncoding.default)
        case .getUser               :return RTRequestSettings(method: .get)
        case .editUser(_)           :return RTRequestSettings(method: .put)
        default                     :return RTRequestSettings(method: .post)
        }
    }
    
    var path: String {
        switch self {
        case .getAuthPhoneCode(_)   : return "/auth_phone_codes"
        case .register              : return "/users"
        case .signIn                : return "/users/sign_in"
        case .getUser               : return "/users/account"
        case .editUser(let user)    : return "/users/\(user.id)"
        }
    }
    
    var parameters: [String : AnyObject]? {
        switch self {
        case .getAuthPhoneCode(let phone):  return ["phone_number": phone as AnyObject]
        case .register(let firstName, let lastname, let email, let phone, let authPhoneCode, let smsCode):
            return ["first_name" : firstName as AnyObject,
                    "last_name" : lastname as AnyObject,
                    "email" : email as AnyObject,
                    "phone_number" : phone as AnyObject,
                    "auth_phone_code_id" : authPhoneCode as AnyObject,
                    "sms_code": smsCode as AnyObject]
        case .signIn(let phone, let authPhoneCode, let smsCode):
            return ["phone_number": phone as AnyObject,
                    "auth_phone_code_id" : authPhoneCode as AnyObject,
                    "sms_code" : smsCode as AnyObject]
        case .editUser(let user):
            var params :[String: String] = [:]
            params.updateIfNotDefault(user.firstName, forKey: "first_name", defaultValue: "")
            params.updateIfNotDefault(user.lastName, forKey: "last_name", defaultValue: "")
            params.updateIfNotDefault(user.email, forKey: "email", defaultValue: "")
            params.updateIfNotDefault(user.avatar, forKey: "avatar", defaultValue: "")
            return params as [String : AnyObject]?
        case .getUser:
            return nil
        }
    }
}

class RTUserResponse: Mappable {
    var user: User?
    var error: ValidationError?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        self.user <- map["user"]
    }
}

class RTAuthInfoResponse: Mappable {
    var authInfo: AuthInfo?
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        self.authInfo <- map["auth_phone_code"]
    }
}
