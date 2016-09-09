//
//  AlamofireHelpers.swift
//  MarketIOS
//
//  Created by Sergey Nikolaev on 03.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

extension Request {
    
    func responseObject<T: Mappable>(completionHandler: Response<T, RTError> -> Void) -> Self {
        
        let responseSerializer = ResponseSerializer<T, RTError> { request, response, data, error in
            guard error == nil || response?.statusCode == 422 else {
                return .Failure(RTError(request: .Unknown(error: error)))
            }
            
            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
            
            switch result {
            case .Success(let value):
                
                guard let json = value as? [String : AnyObject] else {
                    return .Failure(RTError(serialize: .WrongType))
                }
                
                guard var object = T(JSON: json) else {return .Failure(RTError(serialize: .RequeriedFieldMissing))}
                
                object = Mapper<T>().map(json, toObject: object)
                
                return .Success(object)
                
            case .Failure(_):
                do {
                guard let lData = data, let json = try NSJSONSerialization.JSONObjectWithData(lData, options: []) as? [String : AnyObject] else {
                    return .Failure(RTError(serialize: .WrongType))
                }
                    var object = ValidationError()
                    object = Mapper<ValidationError>().map(json["error"], toObject: object)
                    if object.isPhoneValid == false {
                        return .Failure(RTError(backend: .InvalidPhone))
                    }
                    if object.isSmsCodeValid == false {
                        return .Failure(RTError(backend: .SmsCodeExpired))
                    }
                    if object.isEmailNotTaken == false {
                        return .Failure(RTError(backend: .EmainTaken))
                    }
                }
                catch let error {
                    if let object = T(JSON: [:]) where data?.length == 0 {
                        return .Success(object)
                    }
                    Logger.error("\(error)")
                }

                return .Failure(RTError(serialize: .JSONSerializingFailed))
            }
        }
        
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}
