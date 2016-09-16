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
        
        enum Source: String {
            case HealthKit    = "healthkit"
            case Fitbit       = "fitbit"
        }
    }
}

extension Router.Steps: RouterProtocol {
    
    var settings: RTRequestSettings {
        switch self {
        case .Send(_): return RTRequestSettings(method: .POST)
        }
    }
    
    var path: String {
        switch self {
        case .Send(_): return "/activities"
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