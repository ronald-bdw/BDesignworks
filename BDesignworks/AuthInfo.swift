//
//  AuthInfo.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 19.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation
import ObjectMapper

class AuthInfo: Object {
    dynamic var id: Int = 0
    dynamic var isRegistered: Bool = false
    dynamic var phone: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init?(map: ObjectMapper.Map) {
        guard let _ = map.JSON["id"] as? Int else {return nil}
        self.init()
    }
    
    static func getMainAuthInfo() -> AuthInfo? {
        do {
            let realm = try Realm()
            return realm.objects(AuthInfo.self).first
        }
        catch {
            return nil
        }
    }
}



extension AuthInfo: Mappable {
    func mapping(map: ObjectMapper.Map) {
        self.id <- map["id"]
        self.isRegistered <- map["phone_registered"]
    }
}
