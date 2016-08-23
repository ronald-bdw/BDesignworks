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
    func setLoadingState (state: LoadingState)
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
    func setLoadingState(state: LoadingState) {
        switch state {
        case .Loading:
            Logger.debug("loading")
        case .Done:
            let storyboard = UIStoryboard(name: "Main_Storyboard", bundle: NSBundle.mainBundle())
            let controller = storyboard.instantiateViewControllerWithIdentifier("ConversationScreen")
            let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
            appDelegate?.window?.rootViewController = controller
        case .Failed:
            Logger.debug("failed")
        }
    }
}

extension LoginView: MVPView {
    typealias PresenterProtocol = ILoginPresenter
}