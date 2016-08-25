//
//  Extensions.swift
//  BDesignworks
//
//  Created by Kruperfone on 19.11.15.
//  Copyright © 2015 Flatstack. All rights reserved.
//

import Foundation

extension UIAlertController {
    func presentOnModal() {
        guard   let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate,
            let window = appDelegate.window else {return}
        var presentedController = window.rootViewController
        var nextController = presentedController?.presentedViewController
        while nextController != nil  {
            presentedController = nextController
            nextController = presentedController?.presentedViewController
        }
        presentedController?.presentViewController(self, animated: true, completion: nil)
    }
    
    /** Presents alert only if no alert presented on view.
     */
    func presentIfNoAlertsPresented() {
        guard   let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate,
            let window = appDelegate.window else {return}
        var presentedController = window.rootViewController
        var nextController = presentedController?.presentedViewController
        while nextController != nil  {
            presentedController = nextController
            nextController = presentedController?.presentedViewController
        }
        if let _ = presentedController as? UIAlertController {return}
        presentedController?.presentViewController(self, animated: true, completion: nil)
    }
}
