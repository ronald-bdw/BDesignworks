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
        case sendAvatar(id: Int, image: UIImage)
        case enableNotificationOnZendesk
        case disableNotificationOnZendesk
        case checkUserStatus(phone: String)
        case sendReceipt(receipt: AnyObject)
        case sendInAppPurchaseStatus(plan: String, expirationDate: Date, isActive: Bool)
    }
}

extension Router.User: RouterProtocol {

    var settings: RTRequestSettings {
        switch self {
        case .getAuthPhoneCode(_)           :return RTRequestSettings(method: .post, encoding: URLEncoding.default)
        case .getUser                       :return RTRequestSettings(method: .get)
        case .editUser(_),
             .sendAvatar(_,_)               :return RTRequestSettings(method: .put)
        case .disableNotificationOnZendesk  :return RTRequestSettings(method: .delete)
        default                             :return RTRequestSettings(method: .post)
        }
    }

    var path: String {
        switch self {
        case .getAuthPhoneCode              : return "/auth_phone_codes"
        case .register                      : return "/users"
        case .signIn                        : return "/users/sign_in"
        case .getUser                       : return "/users/account"
        case .editUser(let user)            : return "/users/\(user.id)"
        case .sendAvatar(let id,_)          : return "/users/\(id)"
        case .enableNotificationOnZendesk   : return "/notifications"
        case .disableNotificationOnZendesk  : return "/notifications/message_push"
        case .checkUserStatus              : return "/registration_status"
        case .sendReceipt                  : return "/verifyReceipt"
        case .sendInAppPurchaseStatus       : return "/subscriptions"
        }
    }

    var parameters: [String : AnyObject]? {
        switch self {
        case .getAuthPhoneCode(let phone):  return ["phone_number": phone as AnyObject, "device_type": "ios" as AnyObject]
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
            return params as [String : AnyObject]?
        case .enableNotificationOnZendesk:

            return ["notification":["kind":"message_push"] as AnyObject]
        case .checkUserStatus(let phone):
            return ["phone_number": phone as AnyObject]
        case .sendReceipt(let receipt):
                return ["receipt-data": receipt, "password": "aa611c0d16eb42b7941b24ad380f557a" as AnyObject]
        case .sendInAppPurchaseStatus(let plan, let expirationDate, let isActive):
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "Y-MM-dd HH:mm:ss zzz"
            return ["plan_name": plan as AnyObject,
                    "expires_at": dateFormatter.string(from: expirationDate) as AnyObject,
                    "active": isActive as AnyObject]
        default:
            return nil
        }
    }

    var multipartParameters: [String: Data]? {
        switch self {
        case .sendAvatar(_, let image):
            let compressionRate = UIScreen.main.scale * 100 * 100 / (image.size.height * image.size.width)
            guard let data = UIImageJPEGRepresentation(image, compressionRate) else {return nil}
            return ["user[avatar]": data]
        default:
            return nil
        }
    }

}

class RTEmptyResponse: Mappable{
    required convenience init?(map: Map) {
        self.init()
    }
    func mapping(map: Map) {

    }
}
class RTUserResponse: Mappable {
    var user: ENUser?
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

class RTUserStatusResponse: Mappable {
    var isRegistered: Bool = false
    var provider: String = ""

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        self.isRegistered <- map["phone_registered"]
        self.provider <- map["provider"]
    }
}

class RTSubscriptionResponse: Mappable {
    var expirationDate: Date?
    var isTrial: Bool?
    var productId: String?

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        guard let latestReceiptInfo = (map.JSON["latest_receipt_info"] as? [[String: AnyObject]])?.first else {return}
        
        if let expirationDateStringWithTimeZone = latestReceiptInfo["expires_date"] as? String,
            let range = expirationDateStringWithTimeZone.range(of: "Etc/GMT") {
            let expirationDateString = expirationDateStringWithTimeZone.substring(to: range.lowerBound)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            self.expirationDate = dateFormatter.date(from: expirationDateString)
        }
        self.isTrial = Bool(latestReceiptInfo["is_trial_period"] as? String ?? "false")
        self.productId = latestReceiptInfo["product_id"] as? String
    }
}
