//
//  ProfileEditingHelpers.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 14.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

enum UserEditedValidationField: Int {
    case firstName
    case lastName
    case email
    
    var validationText: String {
        switch self {
        case .firstName : return "First name shouldn't be empty"
        case .lastName  : return "Last name shouldn't be empty"
        case .email     : return "Email not valid"
        }
    }
    func isValid(_ content: String?) -> Bool {
        switch self {
        case .firstName, .lastName: return (content?.fs_length)! > 0
        case .email: return content?.fs_emailValidate() ?? false
        }
    }
}

struct UserEdited {
    var id: Int
    var firstName: String?
    var lastName: String?
    var email: String?
    
    func isValid(_ type: UserEditedValidationField) -> Bool {
        switch type {
        case .firstName : return type.isValid(self.firstName)
        case .lastName  : return type.isValid(self.lastName)
        case .email     : return type.isValid(self.email)
        }
    }
}
