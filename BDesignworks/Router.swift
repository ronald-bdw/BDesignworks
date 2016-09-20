//
//  Router.swift
//  MarketIOS
//
//  Created by Sergey Nikolaev on 06.07.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

enum Router {
    static let BaseURL = "https://b-designworks.herokuapp.com/v1"
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
        
        //TODO: rename entity User
//        do {
//            let realm = try Realm()
//            if let user = realm.objects(User.self).first {
//                headers = ["X-User-Token": user.token!, "X-User-Phone-Number": user.phoneNumber]
//            }
//        }
//        catch let error {
//            Logger.debug("\(error)")
//        }

        
        return headers
    }

}

protocol RouterProtocol {
    var settings: RTRequestSettings {get}
    var path: String {get}
    var parameters: [String : AnyObject]? {get}
}

extension RouterProtocol {
    
    func request () -> DataRequest {
        let path = "\(Router.BaseURL)\(self.path)"
        
        let headers = Router.extendHeaders
        
        let request = Router.manager.request(path, method: self.settings.method, parameters: self.parameters, encoding: self.settings.encoding, headers: headers)
        
        return request
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
