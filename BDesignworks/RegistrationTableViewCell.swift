//
//  File.swift
//  BDesignworks
//
//  Created by Эллина Кузнецова on 22.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

class RegistrationTableViewCell: UITableViewCell {
    var type: RegistrationCellType = .FirstName
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTextField: UITextField!
    
    func prepareCell(type: RegistrationCellType, user: RegistrationUser?) {
        self.titleLabel.text = type.title
        
        switch type {
        case .Email : self.contentTextField.keyboardType = .EmailAddress
        case .Phone : self.contentTextField.keyboardType = .PhonePad
        default     : self.contentTextField.keyboardType = .Default
        }
        
        switch type {
        case .Phone : self.contentTextField.returnKeyType = .Done
        default     : self.contentTextField.returnKeyType = .Next
        }
        
        self.contentTextField.text = user?.getStructField(type).content
    }
}