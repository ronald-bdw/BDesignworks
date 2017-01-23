//
//  Provider.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 05/01/2017.
//  Copyright © 2017 Flatstack. All rights reserved.
//

import Foundation
import ObjectMapper

class ENProvider: Object {
    dynamic var id: Int = 0
    dynamic var name: String = ""
    dynamic var priority: Int = 1
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init?(map: ObjectMapper.Map) {
        guard let _ = map.JSON["id"] as? Int else {return nil}
        self.init()
    }
}

extension ENProvider: Mappable {
    func mapping(map: Map) {
        self.id <- map["id"]
        self.name <- map["name"]
        self.priority <- map["priority"]
    }
}
