//
//  RTErrorsDescription.swift
//  MarketIOS
//
//  Created by Sergey Nikolaev on 06.07.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

extension SerializationError: FSError {
    var description: String {
        switch self {
        case .WrongType             : return "Response has wrong type"
        case .RequeriedFieldMissing : return "One of required fields is missing"
        case .JSONSerializingFailed : return "Serialization to JSON object was failed"
        case .Unknown               : return "Unknown serialization error"
        }
    }
}

extension BackendError: HumanErrorType {
    var description: String {
        switch self {
        case .NotAuthorized: return "User is not authorized"
        }
    }
    
    var humanDescription: ErrorHumanDescription {
        switch self {
        case .NotAuthorized: return ErrorHumanDescription(title: "Not authorized", text: "You must be authorized for this action")
        }
    }
}
