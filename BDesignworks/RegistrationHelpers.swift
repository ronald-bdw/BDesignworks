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
    case phone = 6
    
    var title: String {
        switch self {
        case .firstName : return "First Name"
        case .lastName  : return "Last Name"
        case .email     : return "Email"
        case .phone     : return "Phone"
        }
    }
    
    var validationError: String {
        switch self {
        case .firstName, .lastName : return "Shouldn't be clear"
        case .email     : return "Email not valid"
        case .phone     : return "Should have 11 symbols"
        }
    }
    
    func getStructField(_ user: RegistrationUser) -> RegistrationUserField {
        switch self {
        case .firstName : return user.firstName
        case .lastName  : return user.lastName
        case .email     : return user.email
        case .phone     : return user.phone
        }
    }
}

struct RegistrationUser {
    var firstName: RegistrationUserField
    var lastName: RegistrationUserField
    var email: RegistrationUserField
    var phone: RegistrationUserField
    
    init() {
        self.firstName = RegistrationUserField(type: .firstName)
        self.lastName = RegistrationUserField(type: .lastName)
        self.email = RegistrationUserField(type: .email)
        self.phone = RegistrationUserField(type: .phone)
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
        case .phone     : return self.phone
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
        case .firstName, .lastName: return content.fs_length > 0
        case .email: return content.fs_emailValidate()
        case .phone: return content.fs_length > 11
        }
    }
    
    init(type: RegistrationCellType) {
        self.type = type
        self.content = (self.type == .phone ? "+" : "")
    }
}
