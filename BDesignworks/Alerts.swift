//
//  File.swift
//  BDesignworks
//
//  Created by Эллина Кузнецова on 24.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

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

func ShowOKAlert (_ title: String? = nil, message: String?) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    
    let alertButton = UIAlertAction(title: "OK", style: .default) { (alertAction: UIAlertAction) -> Void in
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

func ShowNoProviderAlert() {
    let alertController = UIAlertController(title: "Verification is unsuccessful", message: "You don't have a provider.", preferredStyle: UIAlertControllerStyle.alert)
    
    let alertButton = UIAlertAction(title: "OK", style: .default) { (alertAction: UIAlertAction) -> Void in
        ShowInitialViewController()
    }
    alertController.addAction(alertButton)
    
    alertController.presentIfNoAlertsPresented()
}

func ShowNotRegisteredAlert() {
    let alertController = UIAlertController(title: "Verification is unsuccessful", message: "You are not registered with Pair Up. Please sign up first.", preferredStyle: UIAlertControllerStyle.alert)
    
    let alertButton = UIAlertAction(title: "OK", style: .default) { (alertAction: UIAlertAction) -> Void in
        ShowInitialViewController()
    }
    alertController.addAction(alertButton)
    
    alertController.presentIfNoAlertsPresented()
}

func ShowAlreadyRegisteredAlert(withProvider: Bool = false) {
    let alertController = UIAlertController(title: "Verification is unsuccessful",
                                            message: "You are already registered with Pair Up" + (withProvider ? " and have a provider." : "."),
                                            preferredStyle: UIAlertControllerStyle.alert)
    
    let alertButton = UIAlertAction(title: "OK", style: .default) { (alertAction: UIAlertAction) -> Void in
        ShowInitialViewController()
    }
    alertController.addAction(alertButton)
    
    alertController.presentIfNoAlertsPresented()
}

func ShowInAppAlert() {
    let alertController = UIAlertController(title: "Choose your plan", message: "1 month trial period available for all plans.", preferredStyle: .actionSheet)
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
