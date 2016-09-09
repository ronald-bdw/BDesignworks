//
//  FitbitError.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 12.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation
import ObjectMapper

class FitbitError {
    var isTokenExpired: Bool = false
    var isTokenInvalid: Bool = false
    
    required convenience init?(_ map: ObjectMapper.Map) {
        self.init()
    }
}

extension FitbitError: Mappable {
    func mapping(map: ObjectMapper.Map) {
        self.isTokenExpired = map.JSONDictionary["errorType"] as? String == "expired_token"
        self.isTokenInvalid = map.JSONDictionary["errorType"] as? String == "invalid_token"
    }
}