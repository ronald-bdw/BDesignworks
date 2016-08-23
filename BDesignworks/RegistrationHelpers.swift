//
//  RegistrationHelpers.swift
//  BDesignworks
//
//  Created by Эллина Кузнецова on 23.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation


enum RegistrationCellType: Int {
    case FirstName = 0
    case LastName = 2
    case Email = 4
    case Phone = 6
    
    var title: String {
        switch self {
        case .FirstName : return "First Name"
        case .LastName  : return "Last Name"
        case .Email     : return "Email"
        case .Phone     : return "Phone"
        }
    }
    
    var validationError: String {
        switch self {
        case .FirstName, .LastName : return "Shouldn't be clear"
        case .Email     : return "Email not valid"
        case .Phone     : return "Should have 11 symbols"
        }
    }
    
    func getStructField(user: RegistrationUser) -> RegistrationUserField {
        switch self {
        case .FirstName : return user.firstName
        case .LastName  : return user.lastName
        case .Email     : return user.email
        case .Phone     : return user.phone
        }
    }
}

struct RegistrationUser {
    var firstName: RegistrationUserField
    var lastName: RegistrationUserField
    var email: RegistrationUserField
    var phone: RegistrationUserField
    
    init() {
        self.firstName = RegistrationUserField(type: .FirstName)
        self.lastName = RegistrationUserField(type: .LastName)
        self.email = RegistrationUserField(type: .Email)
        self.phone = RegistrationUserField(type: .Phone)
    }
    
    func isFieldValid(errorRow: Int) -> Bool {
        let dataRow = errorRow - 1
        
        guard let cellType = RegistrationCellType(rawValue: dataRow) else {fatalError()}
        return cellType.getStructField(self).isValid
    }
    
    func getStructField(type: RegistrationCellType) -> RegistrationUserField {
        switch type {
        case .FirstName : return self.firstName
        case .LastName  : return self.lastName
        case .Email     : return self.email
        case .Phone     : return self.phone
        }
    }
    
    func allFields() -> [RegistrationUserField] {
        return [self.firstName, self.lastName, self.email, self.phone]
    }
}

struct RegistrationUserField {
    var content: String
    let type: RegistrationCellType
    
    var isValid: Bool {
        switch self.type {
        case .FirstName, .LastName: return content.fs_length > 0
        case .Email: return content.fs_emailValidate()
        case .Phone: return content.fs_length == 11
        }
    }
    
    init(type: RegistrationCellType) {
        self.content = ""
        self.type = type
    }
}