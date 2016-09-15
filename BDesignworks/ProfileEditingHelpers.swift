//
//  ProfileEditingHelpers.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 14.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

enum UserEditedValidationField: Int {
    case FirstName
    case LastName
    case Email
    
    var validationText: String {
        switch self {
        case .FirstName : return "First name shouldn't be empty"
        case .LastName  : return "Last name shouldn't be empty"
        case .Email     : return "Email not valid"
        }
    }
    func isValid(content: String?) -> Bool {
        switch self {
        case .FirstName, .LastName: return content?.fs_length > 0
        case .Email: return content?.fs_emailValidate() ?? false
        }
    }
}

struct UserEdited {
    var id: Int
    var firstName: String?
    var lastName: String?
    var email: String?
    var avatar: String?
    
    func isValid(type: UserEditedValidationField) -> Bool {
        switch type {
        case .FirstName : return type.isValid(self.firstName)
        case .LastName  : return type.isValid(self.lastName)
        case .Email     : return type.isValid(self.email)
        }
    }
}