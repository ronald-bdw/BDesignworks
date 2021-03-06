//
//  File.swift
//  BDesignworks
//
//  Created by Эллина Кузнецова on 24.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation
import MessageUI

//MARK: Helpers

fileprivate func getContactUsAction(delegate: IMailAppDelegate) -> UIAlertAction {
    let contactUsAction = UIAlertAction(title: "Contact Pair Up team", style: .default) { (action) in
        let composeVC = MFMailComposeViewController()
        
        composeVC.setToRecipients([SupportAddress])
        composeVC.setSubject(SupportMailSubject)
        composeVC.setMessageBody(GetTechnicalInfo(), isHTML: false)
        
        delegate.showComposedController(composeVC)
    }
    return contactUsAction
}

//MARK: Alerts

func ShowAlert (_ message: String, delay: Double, onViewController viewController: UIViewController?) {
    let alertView = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
    viewController?.present(alertView, animated: true, completion: nil)
    let delayTime = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: delayTime) {
        alertView.dismiss(animated: true, completion: nil)
    }
}

/// Add Alert with UIAlertAction button, actionButton REQUIRED!
func ShowAlertWithHandler (_ title: String? = nil, message: String?, useCancelButton: Bool = false, cancelButtonHandler: (((UIAlertAction) -> Void)?) = nil, handler: ((UIAlertAction) -> Void)?){
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    let alertButton = UIAlertAction(title: "OK", style: .default, handler: handler)
    alertController.addAction(alertButton)
    
    if useCancelButton {
        let cancelButton = UIAlertAction(title: "Cancel", style: .destructive, handler: cancelButtonHandler)
        alertController.addAction(cancelButton)
    }
    
    alertController.presentOnModal()
}

func ShowOKAlert (_ title: String? = nil, message: String?, completionBlock: (() -> Void)? = nil) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    
    let alertButton = UIAlertAction(title: "OK", style: .default) { (alertAction: UIAlertAction) -> Void in
        completionBlock?()
        alertController.dismiss(animated: true, completion: nil)
    }
    alertController.addAction(alertButton)
    
    alertController.presentOnModal()
}

func ShowErrorAlert(_ title: String? = "Sorry", message: String? = "Something went wrong") {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    
    let alertButton = UIAlertAction(title: "OK", style: .default) { (alertAction: UIAlertAction) -> Void in
        alertController.dismiss(animated: true, completion: nil)
    }
    alertController.addAction(alertButton)
    
    alertController.presentOnModal()
}

func ShowUnauthorizedAlert() {
    let errorDescription = BackendError.notAuthorized.humanDescription
    let alertController = UIAlertController(title: errorDescription.title, message: errorDescription.text, preferredStyle: UIAlertControllerStyle.alert)
    
    let alertButton = UIAlertAction(title: "OK", style: .default) { (alertAction: UIAlertAction) -> Void in
        ENUser.logout()
        ShowInitialViewController()
        alertController.dismiss(animated: true, completion: nil)
    }
    alertController.addAction(alertButton)
    
    DispatchQueue.main.async {
        alertController.presentIfNoAlertsPresented()
    }
}

func ShowDeletedAlert() {
    let alertController = UIAlertController(title: "Error", message: "Your account have been deleted. Please sign up with Pair Up to use the app.", preferredStyle: UIAlertControllerStyle.alert)
    
    let alertButton = UIAlertAction(title: "OK", style: .default) { (alertAction: UIAlertAction) -> Void in
        ENUser.logout()
        ShowInitialViewController()
        alertController.dismiss(animated: true, completion: nil)
    }
    alertController.addAction(alertButton)
    
    DispatchQueue.main.async {
        alertController.presentIfNoAlertsPresented()
    }
}

func ShowNoProviderAlert(delegate: IMailAppDelegate) {
    let alertController = UIAlertController(title: "Verification is unsuccessful", message: "You don't have a provider. Please try again or contact us at support@pairup.im", preferredStyle: UIAlertControllerStyle.alert)
    
    let tryAgainAction = UIAlertAction(title: "Try again", style: .default) { (alertAction: UIAlertAction) -> Void in
        ShowInitialViewController()
    }
    alertController.addAction(tryAgainAction)
    
    let contactUsAction = getContactUsAction(delegate: delegate)
    
    alertController.addAction(contactUsAction)
    
    alertController.presentIfNoAlertsPresented()
    
    AnalyticsManager.shared.detectWrongFlow(type: .noProvider)
}


func ShowWrongProviderAlert(delegate: IMailAppDelegate) {
    let alertController = UIAlertController(title: "Verification is unsuccessful", message: "You selected wrong provider. Please try again or contact us at support@pairup.im", preferredStyle: UIAlertControllerStyle.alert)
    
    let tryAgainAction = UIAlertAction(title: "Try again", style: .default) { (alertAction: UIAlertAction) -> Void in
        ShowInitialViewController()
    }
    alertController.addAction(tryAgainAction)
    
    let contactUsAction = getContactUsAction(delegate: delegate)
    
    alertController.addAction(contactUsAction)
    
    alertController.presentIfNoAlertsPresented()
    
    AnalyticsManager.shared.detectWrongFlow(type: .wrongProvider)
}

func ShowNotRegisteredAlert(delegate: IMailAppDelegate) {
    let alertController = UIAlertController(title: "Verification is unsuccessful", message: "You are not registered with Pair Up. Please sign up first or contact us at support@pairup.im", preferredStyle: UIAlertControllerStyle.alert)
    
    let tryAgainAction = UIAlertAction(title: "Try again", style: .default) { (alertAction: UIAlertAction) -> Void in
        ShowInitialViewController()
    }
    alertController.addAction(tryAgainAction)
    
    let contactUsAction = getContactUsAction(delegate: delegate)
    
    alertController.addAction(contactUsAction)
    
    alertController.presentIfNoAlertsPresented()
    
    AnalyticsManager.shared.detectWrongFlow(type: .notRegistered)
}

func ShowAlreadyRegisteredAlert(delegate: IMailAppDelegate, withProvider: Bool = false) {
    let alertController = UIAlertController(title: "Verification is unsuccessful",
                                            message: "You are already registered with Pair Up" + (withProvider ? " and have a provider." : ".") + " Please try again or contact us at support@pairup.im",
                                            preferredStyle: UIAlertControllerStyle.alert)
    
    let tryAgainAction = UIAlertAction(title: "Try again", style: .default) { (alertAction: UIAlertAction) -> Void in
        ShowInitialViewController()
    }
    alertController.addAction(tryAgainAction)
    
    let contactUsAction = getContactUsAction(delegate: delegate)
    
    alertController.addAction(contactUsAction)
    
    alertController.presentIfNoAlertsPresented()
    
    AnalyticsManager.shared.detectWrongFlow(type: .alreadyRegistered)
}

func ShowInAppAlert() {
    let alertController = UIAlertController(title: "Choose your auto-renewable subscription plan", message: "2 week trial period available for all plans.", preferredStyle: .actionSheet)
    alertController.view.tintColor = UIColor(fs_hexString: "29537C")
    
    for type in ProductType.all {
        let action = UIAlertAction(title: type.description, style: .default, handler: { (alertAction) in
            InAppManager.shared.purchaseProduct(productType: type)
        })
        alertController.addAction(action)
    }
    
    let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
    alertController.addAction(cancelButton)
    
    alertController.presentOnModal()
}
