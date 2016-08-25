//
//  File.swift
//  BDesignworks
//
//  Created by Эллина Кузнецова on 23.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

class ValidationErrorCell: UITableViewCell {
    @IBOutlet weak var errorView: VerificationErrorView!
    
    func prepareCell(type: RegistrationCellType) {
        self.errorView.setLabel(type.validationError)
    }
}