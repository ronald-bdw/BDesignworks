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
    var isSmsCodeValid: Bool = true
    
    required convenience init?(_ map: ObjectMapper.Map) {
        self.init()
    }
}

extension ValidationError: Mappable {
    func mapping(map: ObjectMapper.Map) {
        self.error <- map["status"]
        
        guard let validations = map.JSONDictionary["validations"] as? [String: AnyObject] else {return}
        self.isSmsCodeValid = validations["sms_code"] == nil
        self.isPhoneValid = validations["phone_number"] == nil
    }
}