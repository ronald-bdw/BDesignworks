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
func ShowAlertWithHandler (_ title: String? = nil, message: String?, handler: ((UIAlertAction) -> Void)?){
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
    let alertButton = UIAlertAction(title: "OK", style: .default, handler: handler)
    alertController.addAction(alertButton)
    
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
    
    alertController.presentIfNoAlertsPresented()
}
