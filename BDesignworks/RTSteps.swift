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
        case Send(count: Int, startedAt: NSDate, finishedAt: NSDate)
    }
}

extension Router.Steps: RouterProtocol {
    var settings: RTRequestSettings {
        return RTRequestSettings(method: .POST)
    }
    
    var path: String {
        switch self {
        case .Send(_): return "/activities"
        }
    }
    
    var parameters: [String : AnyObject]? {
        switch self {
        case .Send(let count, let startedAt, let finishedAt):
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "Y-MM-dd HH:mm:ss zzz"
            
            let startString = dateFormatter.stringFromDate(startedAt)
            let finishString = dateFormatter.stringFromDate(finishedAt)
            
            return ["started_at": startString, "finished_at": finishString, "steps_count": count]
        }
    }
}

class RTStepsSendResponse: Mappable {
    var activity: Steps?
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        self.activity <- map["activity"]
    }
}