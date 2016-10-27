//
//  FitbitInfo.swift
//  BDesignworks
//
//  Created by Ildar Zalyalov on 27.10.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation
import ObjectMapper

class FitbitInfo: Object {
    
    dynamic var id: Int = 0
    dynamic var userId: Int = 0
    dynamic var token: String = ""
    dynamic var source: String = ""
    dynamic var refreshToken: String = ""
//    dynamic var createdAt: String = ""
//    dynamic var updatedAt: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init?(map: ObjectMapper.Map) {
        guard let _ = map.JSON["id"] as? Int else {return nil}
        self.init()
    }
    
}

extension FitbitInfo: Mappable {
    func mapping(map: ObjectMapper.Map) {
        self.id <- map["id"]
        self.userId <- map["user_id"]
        self.token <- map["token"]
        self.source <- map["source"]
        self.refreshToken <- map["refresh_token"]
    }
}
