//
//  RTErrors.swift
//  MarketIOS
//
//  Created by Sergey Nikolaev on 06.07.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

protocol FSError: ErrorType {
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

enum RTError: ErrorType {
    case Request(RequestError)
    case Backend(BackendError)
    case Serialize(SerializationError)
    case Unknown(NSError?)
}

extension RTError {
    init (request: RequestError) {
        self = .Request(request)
    }
    
    init (backend: BackendError) {
        self = .Backend(backend)
    }
    
    init (serialize: SerializationError) {
        self = .Serialize(serialize)
    }
    
    init (error: NSError?) {
        self = .Unknown(error)
    }
}

enum SerializationError {
    case WrongType
    case RequeriedFieldMissing
    case JSONSerializingFailed
    case Unknown
    
    var error: RTError {return RTError(serialize: self)}
}

enum BackendError {
    case NotAuthorized
    
    var error: RTError {return RTError(backend: self)}
}

enum RequestError {
    case Unknown(error: NSError?)
    
    var error: RTError {return RTError(request: self)}
}
