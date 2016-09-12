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
    dynamic var startDate: NSDate = NSDate(){
        didSet {
            compoundKey = compoundKeyValue()
        }
    }
    dynamic var finishDate: NSDate = NSDate().fs_tomorrow {
        didSet {
            compoundKey = compoundKeyValue()
        }
    }
    dynamic var count: Int = 0
    
    dynamic var compoundKey: String = ""
    
    override static func primaryKey() -> String? {
        return "compoundKey"
    }
    
    required convenience init?(_ map: ObjectMapper.Map) {
        self.init()
    }
    
    convenience init(startDate: NSDate, finishDate: NSDate, count: Int) {
        self.init()
        self.startDate = startDate
        self.finishDate = finishDate
        self.count = count
    }
    
    private func compoundKeyValue() -> String {
        return "\(startDate)-\(finishDate)"
    }
}

extension ENSteps {
    func mapping(map: ObjectMapper.Map) {
        let json = map.JSONDictionary
        if let startedAt = json["started_at"] as? String,
            let finishedAt = json["finished_at"] as? String,
            let stepsCount = json["steps_count"] as? Int {
            guard let lStartDate = NSDate.getDateFromISO8601(startedAt),
                let lFinishDate = NSDate.getDateFromISO8601(finishedAt) else {return}
            self.startDate = lStartDate
            self.finishDate = lFinishDate
            self.count = stepsCount
        }
        
        //FitBit API
        if let dateValue = json["dateTime"] as? String {
        
            if let intCount = (json["value"] as? NSNumber)?.integerValue {
                self.count = intCount
            }
            else if let valueString = json["value"] as? String,
                let stringCount = Int(valueString) {
                self.count = stringCount
            }
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "y-MM-dd"
            dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
            guard let date = dateFormatter.dateFromString(dateValue) else {return}
            
            if let timeValue = json["time"] as? String {
                let timeFormatter = NSDateFormatter()
                timeFormatter.dateFormat = "HH:mm:ss"
                timeFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
                guard let time = timeFormatter.dateFromString(timeValue) else {return}
                
                self.startDate = date.dateByAddingTime(time)
                self.finishDate = self.startDate.dateByAddingMinutes(15)
            }
            else {
                self.startDate = date
                self.finishDate = date.fs_tomorrow
            }
        }
    }
}
