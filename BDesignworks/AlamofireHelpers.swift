//
//  AlamofireHelpers.swift
//  MarketIOS
//
//  Created by Sergey Nikolaev on 03.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

extension DataRequest {
    
    func responseObject<T: Mappable>(_ completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        
        let responseSerializer = DataResponseSerializer<T> { request, response, data, error in
            guard error == nil else {
                return DataRequest.handleErrors(response, error: error!, data: data)
            }
            
            let result = Request.serializeResponseJSON(options: .allowFragments, response: response, data: data, error: error)
            
            switch result {
            case .success(let value):
                
                guard let json = value as? [String : AnyObject] else {
                    return .failure(RTError(serialize: .wrongType))
                }
                
                guard var object = T(JSON: json) else {return .failure(RTError(serialize: .requeriedFieldMissing))}
                
                object = Mapper<T>().map(JSONObject: json, toObject: object)
                
                return .success(object)
                
            case .failure(_):
                if let object = T(JSON: [:]) , data?.count == 0 {
                    return .success(object)
                }
                return .failure(RTError(serialize: .jsonSerializingFailed))
            }
        }
        
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
    
    class func handleErrors<T: Mappable>(_ response: HTTPURLResponse?, error: Swift.Error, data: Data?) -> Result<T> {
        do {
            if let nsError = error as? NSError, nsError.code == -999 {
                return .failure(RTError(request: RequestError.canceled))
            }
            guard let lData = data, let json = try JSONSerialization.jsonObject(with: lData as Data, options: []) as? [String : AnyObject] else {
                return .failure(RTError(serialize: .wrongType))
            }
            Logger.error(json)
            if response?.statusCode == 401 && response?.url?.host == NSURL(string: Router.BaseURL)?.host {
                var object = BackendErrorsContainer()
                object = Mapper<BackendErrorsContainer>().map(JSONObject: json["error"], toObject: object)
                if object.isSmsCodeExpired {
                    return .failure(RTError(backend: .smsCodeExpired))
                }
                if object.isSmsCodeInvalid {
                    return .failure(RTError(backend: .smsCodeInvalid))
                }
                if object.isTokenInvalid {
                    DataRequest.checkIsUserRegistered(completionHandler: { (isRegistered) in
                        if isRegistered {
                            ShowUnauthorizedAlert()
                        } else {
                            ShowDeletedAlert()
                        }
                    })
                    return .failure(RTError(backend: .notAuthorized))
                }
            }
            if response?.statusCode == 422 && response?.url?.host == NSURL(string: Router.BaseURL)?.host {
                var object = ValidationError()
                object = Mapper<ValidationError>().map(JSONObject: json["error"], toObject: object)
                if object.isPhoneValid == false {
                    return .failure(RTError(backend: .invalidPhone))
                }
                if object.isSmsCodeExpired {
                    return .failure(RTError(backend: .smsCodeExpired))
                }
                if object.isSmsCodeInvalid {
                    return .failure(RTError(backend: .smsCodeInvalid))
                }
                if object.isEmailNotTaken == false {
                    return .failure(RTError(backend: .emainTaken))
                }
            }

        }
        catch let error {
            Logger.error("\(error)")
        }
        return .failure(RTError(request: .unknown(error: error)))
    }
    
    class func checkIsUserRegistered(completionHandler: @escaping (Bool) -> Void) {
        guard let user = ENUser.getMainUser() else {completionHandler(false); return}
        let _ = Router.User.checkUserStatus(phone: user.phoneNumber).request().responseObject { (response: DataResponse<RTUserStatusResponse>) in
            switch response.result {
            case .success(let value):
                completionHandler(value.isRegistered)
            case .failure:
                completionHandler(false)
            }
        }
    }
}
