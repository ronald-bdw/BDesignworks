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
    func showErrorView(_ title: String, content: String, errorType: BackendError)
    func showErrorView()
    func showPhoneCodeSentView()
}

class LoginView: UIViewController {
    var presenter: PresenterProtocol?
    
    @IBOutlet weak var providerLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = LoginMVP(controller: self)
        
        UIApplication.shared.statusBarStyle = .default
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter?.viewLoaded()
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
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        ShowTourAppViewController()
    }
    
    func presentConversation() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        ShowConversationViewController()
    }
    
// commented due to logo marketing reasons
//    func changeProviderLogoState(logoExist: Bool) {
//        self.providerLogo.isHidden = !logoExist
//    }
    
    func showErrorView(_ title: String, content: String, errorType: BackendError) {
        if errorType == .smsCodeExpired ||
            errorType == .smsCodeInvalid {
            ShowAlertWithHandler(title, message: content) { [weak self] (action) in
                self?.presenter?.resendPhoneCodeTapped()
            }
        }
        else {
            ShowErrorAlert(title, message: content)
        }
    }
    
    func showErrorView() {
        ShowErrorAlert()
    }
    
    func showPhoneCodeSentView() {
        ShowOKAlert("Success!", message: "Please wait for your SMS confirmation to complete the verification process.")
    }
}

extension LoginView: MVPView {
    typealias PresenterProtocol = ILoginViewPresenter
}
