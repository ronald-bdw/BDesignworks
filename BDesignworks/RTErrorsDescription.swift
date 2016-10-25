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
        case .wrongType             : return "DataResponse has wrong type"
        case .requeriedFieldMissing : return "One of required fields is missing"
        case .jsonSerializingFailed : return "Serialization to JSON object was failed"
        case .unknown               : return "Unknown serialization error"
        }
    }
}

extension BackendError: HumanErrorType {
    var description: String {
        switch self {
        case .notAuthorized     : return "User is not authorized"
        case .smsCodeExpired    : return "Sms code has expired"
        case .invalidPhone      : return "Phone is invalid"
        case .phoneTaken        : return "Phone number is already taken"
        case .emainTaken        : return "Emain is taken"
        case .smsCodeNotExist   : return "Sms code not saved in database"
        case .smsCodeInvalid    : return "Sms code not valid"
        }
    }
    
    var humanDescription: ErrorHumanDescription {
        switch self {
        case .notAuthorized     : return ErrorHumanDescription(title: "Error", text: "Someone accessed your account. You will be redirected to authetication screen.")
        case .smsCodeExpired    : return ErrorHumanDescription(title: "Sms code has expired", text: "Resend sms code?")
        case .invalidPhone      : return ErrorHumanDescription(title: "Phone number is invalid", text: "You must provide valid phone number")
        case .phoneTaken        : return ErrorHumanDescription(title: "Sorry", text: "Phone number is already taken")
        case .emainTaken        : return ErrorHumanDescription(title: "Sorry", text: "Email is taken")
        case .smsCodeNotExist   : return ErrorHumanDescription(title: "Success", text: "Please, enter the link in sended sms.")
        case .smsCodeInvalid    : return ErrorHumanDescription(title: "Sms code not valid", text: "Resend sms code?")
        }
    }
}
