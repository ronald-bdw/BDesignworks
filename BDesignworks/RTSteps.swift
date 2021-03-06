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
        case send(steps: [ENSteps], source: Source)
        case sendFitbitCode(code: String)
        case deleteFitBitToken(tokenId: String)
        enum Source: String {
            case HealthKit    = "healthkit"
            case Fitbit       = "fitbit"
        }
    }
}

extension Router.Steps: RouterProtocol {

    
    var settings: RTRequestSettings {
        switch self {
        case .deleteFitBitToken(_): return RTRequestSettings(method: .delete)
        default: return RTRequestSettings(method: .post)
        }
    }
    
    var path: String {
        switch self {
        case .send(_)            : return "/activities"
        case .sendFitbitCode(_)  : return "/fitness_tokens"
        case .deleteFitBitToken(let tokenId): return "/fitness_tokens/\(tokenId)"
        }
    }
    
    var parameters: [String : AnyObject]? {
        switch self {
        case .send(let steps, let source):
            var jsonArray:[[String: AnyObject]] = []
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "Y-MM-dd HH:mm:ss zzz"
            for step in steps {
                let startString = dateFormatter.string(from: step.startDate as Date)
                let finishString = dateFormatter.string(from: step.finishDate as Date)
                jsonArray.append(["started_at": startString as AnyObject, "finished_at": finishString as AnyObject, "steps_count": step.count as AnyObject, "source": source.rawValue as AnyObject])
            }
            return ["activities": jsonArray as AnyObject]
        case .sendFitbitCode(let code):
            return ["source": Source.Fitbit.rawValue as AnyObject, "authorization_code": code as AnyObject]
        
        default: return nil
            
        }
    }
}
class RTFitbitResponse: Mappable{
    var fitbitInfo: FitbitInfo = FitbitInfo()
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
//        self.fitbitInfo
        Mapper().map(JSON: map.JSON, toObject: self.fitbitInfo)
    }
}

class RTStepsSendResponse: Mappable {
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
    }
}
