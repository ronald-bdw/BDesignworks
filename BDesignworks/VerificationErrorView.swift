//
//  VerificationErrorView.swift
//  BDesignworks
//
//  Created by Эллина Кузнецова on 22.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

class VerificationErrorView: BaseView {
    
    @IBOutlet weak var errorLabel: UILabel!
    
    func setLabel(errorText: String) {
        self.errorLabel.text = errorText
    }
}