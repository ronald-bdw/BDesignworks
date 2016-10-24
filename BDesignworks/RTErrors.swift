//
//  RTErrors.swift
//  MarketIOS
//
//  Created by Sergey Nikolaev on 06.07.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol FSError: Swift.Error {
    var description: String {get}
}

extension FSError {
    func log () {
        Logger.error("\(self._domain)(\(self._code)): \(self.description)")
    }
}

struct ErrorHumanDescription {
    let title: String
    let text: String
    
    init (title: String? = nil, text: String) {
        self.title = title ?? "Error"
        self.text = text
    }
}

protocol HumanErrorType: FSError {
    var humanDescription: ErrorHumanDescription {get}
}

enum RTError: Swift.Error {
    case request(RequestError)
    case backend(BackendError)
    case serialize(SerializationError)
    case unknown(Swift.Error?)
}

extension RTError {
    init (request: RequestError) {
        self = .request(request)
    }
    
    init (backend: BackendError) {
        self = .backend(backend)
    }
    
    init (serialize: SerializationError) {
        self = .serialize(serialize)
    }
    
    init (error: Swift.Error?) {
        self = .unknown(error)
    }
}

enum SerializationError {
    case wrongType
    case requeriedFieldMissing
    case jsonSerializingFailed
    case unknown

    var error: RTError {return RTError(serialize: self)}
}

enum BackendError {
    case notAuthorized
    case smsCodeExpired
    case invalidPhone
    case phoneTaken
    case emainTaken
    case smsCodeNotExist
    case smsCodeInvalid
    
    var error: RTError {return RTError(backend: self)}
}

enum RequestError {
    case unknown(error: Swift.Error?)
    
    var error: RTError {return RTError(request: self)}
}
