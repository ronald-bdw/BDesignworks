//
//  TourAppUserInfoHelpers.swift
//  BDesignworks
//
//  Created by Ellina Kuznecova on 28.09.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

enum TourAppUserInfoCellType: Int {
    case firstName = 1
    case lastName = 3
    case email = 5
    
    var title: String {
        switch self {
        case .firstName : return "First Name"
        case .lastName  : return "Last Name"
        case .email     : return "Email"
        }
    }
    
    var validationError: String {
        switch self {
        case .firstName, .lastName  : return "Shouldn't be clear"
        case .email                 : return "Email not valid"
        }
    }
    
    func getStructField(_ user: TourAppUser) -> TourAppUserField {
        switch self {
        case .firstName : return user.firstName
        case .lastName  : return user.lastName
        case .email     : return user.email
        }
    }
}

struct TourAppUser {
    var firstName: TourAppUserField
    var lastName: TourAppUserField
    var email: TourAppUserField
    
    init() {
        self.firstName = TourAppUserField(type: .firstName)
        self.lastName = TourAppUserField(type: .lastName)
        self.email = TourAppUserField(type: .email)
    }
    
    func isFieldValid(_ errorRow: Int) -> Bool {
        let dataRow = errorRow - 1
        
        guard let cellType = TourAppUserInfoCellType(rawValue: dataRow) else {fatalError()}
        return cellType.getStructField(self).isValid
    }
    
    func getStructField(_ type: TourAppUserInfoCellType) -> TourAppUserField {
        switch type {
        case .firstName : return self.firstName
        case .lastName  : return self.lastName
        case .email     : return self.email
        }
    }
    
    func allFields() -> [TourAppUserField] {
        return [self.firstName, self.lastName, self.email]
    }
}

struct TourAppUserField {
    var content: String
    let type: TourAppUserInfoCellType
    
    var isValid: Bool {
        switch self.type {
        case .firstName, .lastName: return content.fs_length > 0
        case .email: return content.fs_emailValidate()
        }
    }
    
    init(type: TourAppUserInfoCellType) {
        self.content = ""
        self.type = type
    }
}
