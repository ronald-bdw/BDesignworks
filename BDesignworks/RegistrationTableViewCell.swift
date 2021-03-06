//
//  File.swift
//  BDesignworks
//
//  Created by Эллина Кузнецова on 22.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

class RegistrationTableViewCell: UITableViewCell {
    var type: RegistrationCellType = .firstName
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTextField: UITextField!
    
    func prepareCell(_ type: RegistrationCellType, user: RegistrationUser?) {
        self.titleLabel.text = type.title
        
        switch type {
        case .email : self.contentTextField.keyboardType = .emailAddress
        default     : self.contentTextField.keyboardType = .default
        }
        
        switch type {
        case .email : self.contentTextField.returnKeyType = .done
        default     : self.contentTextField.returnKeyType = .next
        }
        
        self.contentTextField.text = user?.getStructField(type).content
    }
    
    func prepareCell(_ type: TourAppUserInfoCellType, user: TourAppUser?) {
        self.titleLabel.text = type.title
        
        switch type {
        case .email : self.contentTextField.keyboardType = .emailAddress
        default     : self.contentTextField.keyboardType = .default
        }
        
        switch type {
        case .email : self.contentTextField.returnKeyType = .done
        default     : self.contentTextField.returnKeyType = .next
        }
        
        self.contentTextField.text = user?.getStructField(type).content
    }
}
