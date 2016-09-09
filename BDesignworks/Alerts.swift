//
//  File.swift
//  BDesignworks
//
//  Created by Эллина Кузнецова on 24.08.16.
//  Copyright © 2016 Flatstack. All rights reserved.
//

import Foundation

func ShowAlert (message: String, delay: Double, onViewController viewController: UIViewController?) {
    let alertView = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    viewController?.presentViewController(alertView, animated: true, completion: nil)
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
        alertView.dismissViewControllerAnimated(true, completion: nil)
    }
}

/// Add Alert with UIAlertAction button, actionButton REQUIRED!
func ShowAlertWithHandler (title: String? = nil, message: String?, handler: ((UIAlertAction) -> Void)?){
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    let alertButton = UIAlertAction(title: "OK", style: .Default, handler: handler)
    alertController.addAction(alertButton)
    
    alertController.presentOnModal()
}

func ShowOKAlert (title: String? = nil, message: String?) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    
    let alertButton = UIAlertAction(title: "OK", style: .Default) { (alertAction: UIAlertAction) -> Void in
        alertController.dismissViewControllerAnimated(true, completion: nil)
    }
    alertController.addAction(alertButton)
    
    alertController.presentOnModal()
}

func ShowErrorAlert(title: String? = "Sorry", message: String? = "Something went wrong") {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    
    let alertButton = UIAlertAction(title: "OK", style: .Default) { (alertAction: UIAlertAction) -> Void in
        alertController.dismissViewControllerAnimated(true, completion: nil)
    }
    alertController.addAction(alertButton)
    
    alertController.presentIfNoAlertsPresented()
}

func ShowFitbitTokenErrorAlert(description: ErrorHumanDescription) {
    let alertController = UIAlertController(title: description.title, message: description.text, preferredStyle: UIAlertControllerStyle.Alert)
    
    let alertOKButton = UIAlertAction(title: "OK", style: .Default) { (alertAction: UIAlertAction) -> Void in
        FitBitManager.sharedInstance.signIn()
    }
    let alertCancelButton = UIAlertAction(title: "Cancel", style: .Cancel) { (alertAction) in
        alertController.dismissViewControllerAnimated(true, completion: nil)
    }
    alertController.addAction(alertOKButton)
    alertController.addAction(alertCancelButton)
    
    alertController.presentIfNoAlertsPresented()
}
