//
//  LoginHelpers.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 28/11/2016.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

enum LoginErrors: Swift.Error {
    case authDataNotFound
    case userNotMapped
    case cannotInitDB
    
    var domain: String {
        let domainMainPart = "com.bdesignworks.login"
        switch self {
        case .authDataNotFound: return domainMainPart + ".authDataNotFound"
        case .userNotMapped: return domainMainPart + ".userNotMapped"
        case .cannotInitDB: return domainMainPart + ".cannotInitDB"
        }
    }
    
    var code: Int {
        let mainloginErrorCode = 1000
        switch self {
        case .authDataNotFound: return mainloginErrorCode + 1
        case .userNotMapped: return mainloginErrorCode + 2
        case .cannotInitDB: return mainloginErrorCode + 3
        }
    }
    
    var error: NSError {
        return NSError(domain: self.domain, code: self.code, userInfo: nil)
    }
}
