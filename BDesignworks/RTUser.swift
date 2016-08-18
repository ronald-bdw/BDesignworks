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
        case Register(firstName: String, lastname: String, email: String, phone: String, authPhoneCode: Int, smsCode: Int)
        case SignIn(phone: String, authPhoneCode: Int, smsCode: Int)
    }
}

extension Router.User: RouterProtocol {
    var settings: RTRequestSettings {
        return RTRequestSettings(method: .POST)
    }
    
    var path: String {
        switch self {
        case .GetAuthPhoneCode(_): return "/auth_phone_codes"
        case .Register:         return "/users"
        case .SignIn:           return "/users/sign_in"
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
                    "auth_phone_code" : authPhoneCode,
                    "sms_code": smsCode]
        case .SignIn(let phone, let authPhoneCode, let smsCode):
            return ["phone_number": phone,
                    "auth_phone_code" : authPhoneCode,
                    "sms_code" : smsCode]
        }
    }
}

class RTUserResponse: Mappable {
    var user: User?
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        self.user <- map
    }
}
