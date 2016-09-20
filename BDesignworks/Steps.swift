//
//  Steps.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 07.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation
import ObjectMapper

class ENSteps: Object, Mappable {
    dynamic var startDate: Date = Date(){
        didSet {
            compoundKey = compoundKeyValue()
        }
    }
    dynamic var finishDate: Date = Date().fs_tomorrow {
        didSet {
            compoundKey = compoundKeyValue()
        }
    }
    dynamic var count: Int = 0
    
    dynamic var compoundKey: String = ""
    
    override static func primaryKey() -> String? {
        return "compoundKey"
    }
    
    required convenience init?(map: ObjectMapper.Map) {
        self.init()
    }
    
    convenience init(startDate: Date, finishDate: Date, count: Int) {
        self.init()
        self.startDate = startDate
        self.finishDate = finishDate
        self.count = count
    }
    
    fileprivate func compoundKeyValue() -> String {
        return "\(startDate)-\(finishDate)"
    }
}

extension ENSteps {
    func mapping(map: ObjectMapper.Map) {
        let json = map.JSON
        if let startedAt = json["started_at"] as? String,
            let finishedAt = json["finished_at"] as? String,
            let stepsCount = json["steps_count"] as? Int {
            guard let lStartDate = Date.getDateFromISO8601(startedAt),
                let lFinishDate = Date.getDateFromISO8601(finishedAt) else {return}
            self.startDate = lStartDate
            self.finishDate = lFinishDate
            self.count = stepsCount
        }
    }
}
