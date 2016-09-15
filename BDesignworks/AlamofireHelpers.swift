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
            guard error == nil else {
                return Request.handleErrors(response, error: error!, data: data)
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
                if let object = T(JSON: [:]) where data?.length == 0 {
                    return .Success(object)
                }
                return .Failure(RTError(serialize: .JSONSerializingFailed))
            }
        }
        
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
    
    class func handleErrors<T: Mappable>(response: NSHTTPURLResponse?, error: NSError, data: NSData?) -> Result<T, RTError> {
        do {
            guard let lData = data, let json = try NSJSONSerialization.JSONObjectWithData(lData, options: []) as? [String : AnyObject] else {
                return .Failure(RTError(serialize: .WrongType))
            }
            if response?.statusCode == 422 && response?.URL?.host == NSURL(string: Router.BaseURL)?.host {
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

        }
        catch let error {
            Logger.error("\(error)")
        }
        return .Failure(RTError(request: .Unknown(error: error)))
    }
}
