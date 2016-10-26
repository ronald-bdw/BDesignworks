//
//  ValidationError.swift
//  BDesignworks
//
//  Created by Эллина Кузнецова on 24.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation
import ObjectMapper

class ValidationError {
    var error: Int?
    var isPhoneValid: Bool = true
    var isSmsCodeInvalid: Bool = false
    var isSmsCodeExpired: Bool = false
    var isEmailNotTaken: Bool = true
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
}

extension ValidationError: Mappable {
    func mapping(map: ObjectMapper.Map) {
        self.error <- map["status"]
        
        guard let validations = map.JSON["validations"] as? [String: AnyObject] else {return}
        let smsCodeErrors: Array<String> = (validations["sms_code"] as? Array<String>) ?? []
        for smsCodeError in smsCodeErrors {
            if smsCodeError.contains("is invalid") {
                self.isSmsCodeInvalid = true
            }
            else if smsCodeError.contains("is expired") {
                self.isSmsCodeExpired = true
            }
        }
        self.isPhoneValid = validations["phone_number"] == nil && !"\(validations["message"])".contains("is not a valid phone number")
        self.isEmailNotTaken = validations["email"] == nil
    }
}
