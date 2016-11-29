//
//  Router.swift
//  MarketIOS
//
//  Created by Sergey Nikolaev on 06.07.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

enum Router {
    static let BaseURL = "https://pairup-api.herokuapp.com/v1"
    static var OAuthToken: String?
    
    //MARK: -
    static let manager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        
        var headers: [AnyHashable: Any] = [:]
        for header in SessionManager.defaultHTTPHeaders {
            headers.updateValue(header.1, forKey: header.0)
        }
        configuration.httpAdditionalHeaders = headers
        
        let manager = SessionManager(configuration: configuration)
        return manager
    }()
    
    static let networkReachabilityManager: NetworkReachabilityManager? = {
        let networkReachabilityManager = NetworkReachabilityManager()
        networkReachabilityManager?.startListening()
        return networkReachabilityManager
    }()
    
    static var extendHeaders: [String : String] {
        var headers: [String : String] = [:]
        
        headers.updateValue("no-cache", forKey: "Cache-Control")
        
        if let user = ENUser.getMainUser(), let token = user.token {
            headers = ["X-User-Token": token, "X-User-Phone-Number": user.phoneNumber]
        }
        
        return headers
    }

}

protocol RouterProtocol {
    var settings: RTRequestSettings {get}
    var path: String {get}
    var parameters: [String : AnyObject]? {get}
    
    var multipartParameters: [String: Data]? {get}
}

extension RouterProtocol {
    var multipartParameters: [String: Data]? {
        get {
            return nil
        }
    }
}

extension RouterProtocol {
    
    func request () -> DataRequest {
        let path = "\(Router.BaseURL)\(self.path)"
        
        let headers = Router.extendHeaders
        
        let request = Router.manager.request(path, method: self.settings.method, parameters: self.parameters, encoding: self.settings.encoding, headers: headers).validate()
        
        return request
    }
    
    func upload(completion: @escaping (UploadRequest?, Swift.Error?) -> Void) {
        let path = "\(Router.BaseURL)\(self.path)"
        
        let headers = Router.extendHeaders
        
        Router.manager.upload(multipartFormData: { (multipartFormData) in
            if let multipartParameters = self.multipartParameters {
                for multipartParameter in multipartParameters {
                    multipartFormData.append(multipartParameter.value, withName: multipartParameter.key, fileName: "avatar.jpeg", mimeType: "image/jpeg")
                }
            }
            }, to: URL(string: path)!, method: self.settings.method, headers: headers, encodingCompletion: { (result) in
                switch result {
                case .success(let upload, _, _):
                    completion(upload.validate(), nil)
                case .failure(let encodingError):
                    completion(nil, encodingError)
                }
                
        })
    }
}

struct RTRequestSettings {
    let method: HTTPMethod
    let encoding: ParameterEncoding
    
    init (method: HTTPMethod, encoding: ParameterEncoding? = nil) {
        self.method = method
        self.encoding = encoding ?? method.encoding
    }
}

extension HTTPMethod {
    var encoding: ParameterEncoding {
        switch self {
        case .get                   : return URLEncoding.default
        case .post, .put, .patch    : return JSONEncoding.default
        default                     : return URLEncoding.default
        }
    }
}
