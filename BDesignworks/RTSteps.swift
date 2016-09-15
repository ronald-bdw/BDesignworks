//
//  RTSteps.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 07.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation
import ObjectMapper

extension Router {
    enum Steps {
        case Send(steps: [ENSteps], source: Source)
        case Get(day: NSDate)
        
        enum Source: String {
            case HealthKit    = "healthkit"
            case Fitbit       = "fitbit"
        }
    }
}

extension Router.Steps: RouterProtocol {
    
    var URLRequest: NSMutableURLRequest {
        if case .Get(_) = self {
            return self.defaultURLRequest("https://api.fitbit.com")
        }
        else {
            return self.defaultURLRequest()
        }
    }
    
    var settings: RTRequestSettings {
        switch self {
        case .Send(_): return RTRequestSettings(method: .POST)
        case .Get(_): return RTRequestSettings(method: .GET)
        }
    }
    
    var path: String {
        switch self {
        case .Send(_): return "/activities"
        case .Get(let day):
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "Y-MM-dd"
            
            let dayString = dateFormatter.stringFromDate(day)
            
            return "/1/user/-/activities/steps/date/\(dayString)/1d/15min.json"
        }
    }
    
    var parameters: [String : AnyObject]? {
        switch self {
        case .Send(let steps, let source):
            var jsonArray:[[String: AnyObject]] = []
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "Y-MM-dd HH:mm:ss zzz"
            for step in steps {
                let startString = dateFormatter.stringFromDate(step.startDate)
                let finishString = dateFormatter.stringFromDate(step.finishDate)
                jsonArray.append(["started_at": startString, "finished_at": finishString, "steps_count": step.count, "source": source.rawValue])
            }
            return ["activities": jsonArray]
        case .Get(_):
            return nil
        }
    }
}

class RTStepsSendResponse: Mappable {
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
    }
}

class RTStepsGetResponse: Mappable {
    var stepsPerDay: ENSteps?
    var stepsIntraday: [ENSteps] = []
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        guard let stepsPerDayJsonValue = (map.JSONDictionary["activities-steps"] as? [[String : AnyObject]])?.first else {return}
        self.stepsPerDay = Mapper<ENSteps>().map(stepsPerDayJsonValue)
        
        guard let dayString = (map.JSONDictionary["activities-steps"] as? [[String : AnyObject]])?.first?["dateTime"] else {return}
        guard var stepsIntradayJsonArray = (map.JSONDictionary["activities-steps-intraday"] as? [String: AnyObject])?["dataset"] as? [[String : AnyObject]] else {return}
        
        for i in 0..<stepsIntradayJsonArray.count {
            stepsIntradayJsonArray[i]["dateTime"] = dayString
        }
        self.stepsIntraday = Mapper<ENSteps>().mapArray(stepsIntradayJsonArray) ?? []
    }
}