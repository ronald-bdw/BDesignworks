//
//  File.swift
//  BDesignworks
//
//  Created by Эллина Кузнецова on 22.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

enum RegistrationCellType: Int {
    case FirstName
    case LastName
    case Email
    case Phone
    
    var title: String {
        switch self {
        case .FirstName : return "First Name"
        case .LastName  : return "Last Name"
        case .Email     : return "Email"
        case .Phone     : return "Phone"
        }
    }
}

class RegistrationTableViewCell: UITableViewCell {
    var type: RegistrationCellType = .FirstName
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTextField: UITextField!
    
    func prepareCell(type: RegistrationCellType) {
        self.titleLabel.text = type.title
        
        if type == .Phone {
            do {
                let realm  = try Realm()
                let authInfo = realm.objects(AuthInfo).first
                self.contentTextField.text = authInfo?.phone
            }
            catch let error {
                Logger.error("\(error)")
            }
        }
    }
}