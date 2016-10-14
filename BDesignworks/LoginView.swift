//
//  LoginView.swift
//  BDesignworks
//
//  Created by Ellina Kuznetcova on 19.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

typealias LoginMVP = MVPContainer<LoginView, LoginPresenter, LoginModel>

protocol ILoginView: class {
    func setLoadingState (_ state: LoadingState)
    func presentTourApp()
    func presentConversation()
}

class LoginView: UIViewController {
    var presenter: PresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = LoginMVP(controller: self)
        
        self.presenter?.login()
    }
}

extension LoginView: ILoginView {
    func setLoadingState(_ state: LoadingState) {
        switch state {
        case .loading:
            Logger.debug("loading")
        case .done:
            Logger.debug("done")
        case .failed:
            Logger.debug("failed")
        }
    }
    
    func presentTourApp() {
        ShowTourAppViewController()
    }
    
    func presentConversation() {
        ShowConversationViewController()
    }
}

extension LoginView: MVPView {
    typealias PresenterProtocol = ILoginViewPresenter
}
