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
        case .SmsCodeExpired: return "Sms code has expired"
        case .InvalidPhone: return "Phone is invalid"
        case .EmainTaken: return "Emain is taken"
        case .SmsCodeNotExist: return "Sms code not saved in database"
        }
    }
    
    var humanDescription: ErrorHumanDescription {
        switch self {
        case .NotAuthorized: return ErrorHumanDescription(title: "Not authorized", text: "You must be authorized for this action")
        case .SmsCodeExpired: return ErrorHumanDescription(title: "Sms code has expired", text: "Resend sms code?")
        case .InvalidPhone: return ErrorHumanDescription(title: "Phone number is invalid", text: "You must provide valid phone number")
        case .EmainTaken: return ErrorHumanDescription(title: "Sorry", text: "Email is taken")
        case .SmsCodeNotExist: return ErrorHumanDescription(title: "Success", text: "Please, enter the link in sended sms.")
        }
    }
}
