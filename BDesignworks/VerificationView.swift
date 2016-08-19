//
//  VerificationView.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 19.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

typealias VerificationMVP = MVPContainer<VerificationView, VerificationPresenter, VerificationModel>

protocol IVerificationView: class {
    
}

class VerificationView: UIViewController {
    
    var presenter: IVerificationPresenter?
}

extension VerificationView: IVerificationView {
    
}

extension VerificationView: MVPView {
    typealias PresenterProtocol = IVerificationPresenter
}