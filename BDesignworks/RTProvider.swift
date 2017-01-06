//
//  RTProvider.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 05/01/2017.
//  Copyright © 2017 Flatstack. All rights reserved.
//

import Foundation
import ObjectMapper

extension Router {
    enum Provider {
        case getProviders
    }
}

extension Router.Provider: RouterProtocol {
    
    var settings: RTRequestSettings {
        switch self {
        default : return RTRequestSettings(method: .get)
        }
    }
    
    var path: String {
        switch self {
        case .getProviders : return "/providers"
        }
    }
    
    var parameters: [String : AnyObject]? {
        return nil
    }
}

class RTProvidersResponse: Mappable {
    
    var providers: [ENProvider] = []
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        self.providers <- map["providers"]
    }
}
