//
//  BackendError.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 24/10/2016.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation
import ObjectMapper

class BackendErrorsContainer {
    var error: Int?
    var isSmsCodeExpired: Bool = false
    var isSmsCodeInvalid: Bool = false
    var isTokenInvalid: Bool = false
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
}

extension BackendErrorsContainer: Mappable {
    func mapping(map: ObjectMapper.Map) {
        self.error <- map["status"]
        
        guard let error = map.JSON["error"] as? String else {return}
        self.isSmsCodeInvalid = error.contains("Sms code is invalid")
        self.isSmsCodeExpired = error.contains("expired")
        self.isTokenInvalid = error.contains("Phone number is invalid")
    }
}

