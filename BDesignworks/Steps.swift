//
//  Steps.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 07.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation
import ObjectMapper

class Steps: Object, Mappable {
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
    
    private func compoundKeyValue() -> String {
        return "\(startDate)-\(finishDate)"
    }
}

extension Steps {
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
        
//        if let dateValue = json["dateTime"] as? String {//fitbit api
//        
//            if let intCount = (json["value"] as? NSNumber)?.integerValue {
//                self.count = intCount
//            }
//            else if let stringCount = Int(json["value"] as! String) {
//                self.count = stringCount
//            }
//            
//            let dateFormatter = NSDateFormatter()
//            dateFormatter.dateFormat = "y-MM-dd"
//            dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
//            let date = dateFormatter.dateFromString(dateValue)!
//            
//            if let timeValue = json["time"] as? String {
//                let timeFormatter = NSDateFormatter()
//                timeFormatter.dateFormat = "HH:mm:ss"
//                timeFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
//                let time = timeFormatter.dateFromString(timeValue)!
//                
//                self.startDate = self.dateFrom(date, time: time)
//                
//                let timeInterval:NSTimeInterval = self.startDate.timeIntervalSinceReferenceDate + FSTimePeriod.Minute.rawValue * NSTimeInterval(15)
//                self.endDate = NSDate(timeIntervalSinceReferenceDate: timeInterval)
//            }
//            else {
//                self.startDate = date
//                self.endDate = date.fs_tomorrow
//            }
//        }
    }
    
    
    
    func dateFrom(date: NSDate, time: NSDate) -> NSDate {
        
        let dateComponents = NSCalendar.currentCalendar().components([.Year, .Month, .Day], fromDate: date)
        
        let timeComponents = NSCalendar.currentCalendar().components([.Hour, .Minute, .Second], fromDate: time)
        
        let dateTimeComponents = NSDateComponents()
        dateTimeComponents.year = dateComponents.year
        dateTimeComponents.month = dateComponents.month
        dateTimeComponents.day = dateComponents.day
        dateTimeComponents.hour = timeComponents.hour
        dateTimeComponents.minute = timeComponents.minute
        dateTimeComponents.second = timeComponents.second
        
        return NSCalendar.currentCalendar().dateFromComponents(dateTimeComponents)!
    }
}
