//
//  VerificationErrorView.swift
//  BDesignworks
//
//  Created by Эллина Кузнецова on 22.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import UIKit

final class VerificationErrorView: BaseView {
    
    struct Constants {
        static let triangleLeadingOffset : CGFloat = 49
        static let triangleSize          : CGSize  = CGSize(width: 13, height: 11)
        static let errorContainerHeight  : CGFloat = 49
    }
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorTriangle: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    func setLabel(errorText: String) {
        self.errorLabel.text = errorText
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.errorTriangle.frame = CGRect(x: Constants.triangleLeadingOffset,
                                          y: 0,
                                          width: Constants.triangleSize.width,
                                          height: Constants.triangleSize.height)
        self.containerView.frame = CGRect(x: 0,
                                          y: self.errorTriangle.fs_bottom,
                                          width: self.fs_width,
                                          height: Constants.errorContainerHeight)
        self.errorLabel.frame = self.containerView.bounds
    }
}