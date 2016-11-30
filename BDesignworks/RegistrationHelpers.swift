//
//  RegistrationHelpers.swift
//  BDesignworks
//
//  Created by Эллина Кузнецова on 23.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation


enum RegistrationCellType: Int {
    case firstName = 0
    case lastName = 2
    case email = 4
    
    var title: String {
        switch self {
        case .firstName : return "First Name"
        case .lastName  : return "Last Name"
        case .email     : return "Email"
        }
    }
    
    var validationError: String {
        switch self {
        case .firstName, .lastName : return "Shouldn't be clear"
        case .email     : return "Email not valid"
        }
    }
    
    func getStructField(_ user: RegistrationUser) -> RegistrationUserField {
        switch self {
        case .firstName : return user.firstName
        case .lastName  : return user.lastName
        case .email     : return user.email
        }
    }
}

struct RegistrationUser {
    var firstName: RegistrationUserField
    var lastName: RegistrationUserField
    var email: RegistrationUserField
    
    init() {
        self.firstName = RegistrationUserField(type: .firstName)
        self.lastName = RegistrationUserField(type: .lastName)
        self.email = RegistrationUserField(type: .email)
    }
    
    func isFieldValid(_ errorRow: Int) -> Bool {
        let dataRow = errorRow - 1
        
        guard let cellType = RegistrationCellType(rawValue: dataRow) else {fatalError()}
        return cellType.getStructField(self).isValid
    }
    
    func getStructField(_ type: RegistrationCellType) -> RegistrationUserField {
        switch type {
        case .firstName : return self.firstName
        case .lastName  : return self.lastName
        case .email     : return self.email
        }
    }
    
    mutating func updateField(type: RegistrationCellType, text: String) {
        switch type {
        case .firstName : self.firstName.content = text
        case .lastName  : self.lastName.content = text
        case .email     : self.email.content = text
        }
    }
    
    mutating func setStructField(_ type: RegistrationCellType, content: String) {
        switch type {
        case .firstName : self.firstName.content = content
        case .lastName  : self.lastName.content = content
        case .email     : self.email.content = content
        }
    }
    
    func allFields() -> [RegistrationUserField] {
        return [self.firstName, self.lastName, self.email]
    }
}

struct RegistrationUserField {
    var content: String
    let type: RegistrationCellType
    
    var isValid: Bool {
        switch self.type {
        case .firstName, .lastName: return content.fs_length > 0
        case .email: return content.fs_emailValidate()
        }
    }
    
    init(type: RegistrationCellType) {
        self.type = type
        self.content = ""
    }
}
